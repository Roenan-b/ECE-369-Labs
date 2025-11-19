
//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%
module DataMemory(
  input  [31:0] Address,
  input  [31:0] WriteData,
  input         Clk,
  input         MemWrite,
  input         MemRead,
  input  [1:0]  MemSize,      // 00=byte, 01=half, 10=word
  input         MemUnsigned,  // 1=zero-extend (for loads)
  output reg [31:0] ReadData
);

  // 1K words (4KB)
  reg [31:0] memory [0:1023];

  initial begin
    $readmemh("data_memory.mem", memory);
  end

  // Address breakdown
  wire [9:0]  idx  = Address[11:2];   // word index
  wire [1:0]  offs = Address[1:0];    // byte offset within the word

  // --------- STORE (masked) ----------
  wire is_sw = MemWrite && (MemSize==2'b10);
  wire is_sh = MemWrite && (MemSize==2'b01);
  wire is_sb = MemWrite && (MemSize==2'b00);

  // Byte enables
  wire [3:0] be_sb =
      (offs==2'd0) ? 4'b0001 :
      (offs==2'd1) ? 4'b0010 :
      (offs==2'd2) ? 4'b0100 :
                     4'b1000;

  wire [3:0] be_sh =
      (offs[1]==1'b0) ? 4'b0011 :  // bytes 0-1
                        4'b1100;   // bytes 2-3

  wire [3:0] byte_en =
      is_sw ? 4'b1111 :
      is_sh ? be_sh   :
      is_sb ? be_sb   :
              4'b0000;

  // Word-aligned write payloads
  wire [31:0] w_sb =
      (offs==2'd0) ? {24'h0, WriteData[7:0]} :
      (offs==2'd1) ? {16'h0, WriteData[7:0], 8'h00} :
      (offs==2'd2) ? {8'h00, WriteData[7:0], 16'h0} :
                     {WriteData[7:0], 24'h0};

  wire [31:0] w_sh =
      (offs[1]==1'b0) ? {16'h0, WriteData[15:0]} :
                        {WriteData[15:0], 16'h0};

  wire [31:0] w_data =
      is_sw ? WriteData :
      is_sh ? w_sh      :
      is_sb ? w_sb      :
              32'h00000000;

  // Build next word combinationally, then commit on clock
  reg [31:0] cur_word, new_word;

  always @* begin
    cur_word = memory[idx];
    new_word = cur_word;  // default: keep old bytes

    if (MemWrite) begin
      if (byte_en[0]) new_word[7:0]   = w_data[7:0];
      if (byte_en[1]) new_word[15:8]  = w_data[15:8];
      if (byte_en[2]) new_word[23:16] = w_data[23:16];
      if (byte_en[3]) new_word[31:24] = w_data[31:24];
    end
  end

  always @(posedge Clk) begin
    if (MemWrite) begin
      memory[idx] <= new_word;
      // Debug after computing new_word
      $display("[%0t] STORE  addr=%h size=%b data=%h offs=%0d be=%b cur(before)=%h new=%h",
               $time, Address, MemSize, WriteData, offs, byte_en, cur_word, new_word);
    end
  end

  // --------- LOAD (extract + extend) ----------
  wire [31:0] r_raw  = memory[idx];

  wire [7:0]  r_byte =
      (offs==2'd0) ? r_raw[7:0]   :
      (offs==2'd1) ? r_raw[15:8]  :
      (offs==2'd2) ? r_raw[23:16] :
                     r_raw[31:24];

  wire [15:0] r_half =
      (offs[1]==1'b0) ? r_raw[15:0] : r_raw[31:16];

  wire [31:0] r_b_ext = MemUnsigned ? {24'h0,  r_byte} : {{24{r_byte[7]}},  r_byte};
  wire [31:0] r_h_ext = MemUnsigned ? {16'h0,  r_half} : {{16{r_half[15]}}, r_half};

  wire [31:0] r_data =
      (MemSize==2'b10) ? r_raw   :
      (MemSize==2'b01) ? r_h_ext :
                         r_b_ext;

  always @(*) begin
    ReadData = MemRead ? r_data : 32'h00000000;
  end

  // Optional load debug
  always @(*) begin
    if (MemRead) begin
      $display("[%0t] LOAD   addr=%h size=%b unsigned=%b -> r_raw=%h offs=%0d",
               $time, Address, MemSize, MemUnsigned, r_raw, offs);
    end
  end

endmodule
