`timescale 1ns/1ps

module tb_DataMemory;

  // DUT ports
  reg  [31:0] Address;
  reg  [31:0] WriteData;
  reg         Clk;
  reg         MemWrite;
  reg         MemRead;
  wire [31:0] ReadData;

  // Instantiate DUT
  DataMemory dut (
    .Address(Address),
    .WriteData(WriteData),
    .Clk(Clk),
    .MemWrite(MemWrite),
    .MemRead(MemRead),
    .ReadData(ReadData)
  );

  // Clock: 10ns period
  initial Clk = 0;
  always #5 Clk = ~Clk;

  // Simple tasks
  task do_write(input [31:0] addr, input [31:0] data);
    begin
      @(negedge Clk);
      Address   = addr;
      WriteData = data;
      MemWrite  = 1'b1;
      MemRead   = 1'b0; // read is combinational, keep low during write
      @(posedge Clk);   // commit on posedge
      @(negedge Clk);
      MemWrite  = 1'b0;
    end
  endtask

  task do_read_and_check(input [31:0] addr, input [31:0] expected);
    begin
      // Read path is combinational
      Address  = addr;
      MemRead  = 1'b1;
      MemWrite = 1'b0;
      #1; // small delta to allow combinational settle
      if (ReadData !== expected) begin
        $display("[%0t] ERROR: Read @0x%08h got 0x%08h, expected 0x%08h",
                 $time, addr, ReadData, expected);
        $fatal;
      end else begin
        $display("[%0t] OK: Read @0x%08h = 0x%08h",
                 $time, addr, ReadData);
      end
      // Also check gating: when MemRead=0, output must be 0
      MemRead = 1'b0;
      #1;
      if (ReadData !== 32'h0000_0000) begin
        $display("[%0t] ERROR: MemRead=0 but ReadData != 0 (0x%08h)", $time, ReadData);
        $fatal;
      end
    end
  endtask

  // Helper to compute same word with different byte offsets
  function [31:0] set_byte_offset(input [31:0] base_addr, input [1:0] byte_off);
    begin
      set_byte_offset = {base_addr[31:2], byte_off};
    end
  endfunction

  // Test sequence
  initial begin
    // Wave dump
    $dumpfile("tb_DataMemory.vcd");
    $dumpvars(0, tb_DataMemory);

    // Defaults
    Address   = 32'd0;
    WriteData = 32'd0;
    MemWrite  = 1'b0;
    MemRead   = 1'b0;

    // Wait a couple cycles
    repeat (2) @(posedge Clk);

    // ------------------------------------------------------------
    // 1) Basic writes & reads at different indices
    // Address index uses Address[11:2]; choose addresses far apart in that field.
    // idx = Address[11:2]
    // Let's pick indices: 0x000, 0x001, 0x123, 0x3FF (max)
    // Form addresses with arbitrary byte offsets (lower 2 bits), they should map to same index.
    // ------------------------------------------------------------
    do_write(32'h0000_0004, 32'hDEAD_BEEF); // idx=1
    do_write(32'h0000_1000, 32'hA5A5_5A5A); // idx=0x400 (but only bits 11:2 used => 0x100)
    do_write(32'h0000_48CC, 32'h0123_4567); // idx=(0x48CC >> 2) & 0x3FF = 0x233
    do_write(32'h0000_FFFC, 32'hCAFEBABE);  // idx=(0x3FFF >> 2) & 0x3FF = 0x3FF (since only 11:2)

    // Read back exactly those addresses (same lower bits)
    do_read_and_check(32'h0000_0004, 32'hDEAD_BEEF);
    do_read_and_check(32'h0000_1000, 32'hA5A5_5A5A);
    do_read_and_check(32'h0000_48CC, 32'h0123_4567);
    do_read_and_check(32'h0000_FFFC, 32'hCAFEBABE);

    // ------------------------------------------------------------
    // 2) Byte addressing sanity: different byte offsets should land on same word index
    // Use a base whose [11:2] is known; vary [1:0].
    // ------------------------------------------------------------
    // Choose base with idx = 0x155 (binary distinct). Let base_addr have 00, 01, 10, 11 offsets.
    // All four addresses should index the SAME memory word.
    reg [31:0] base_idx_addr;
    base_idx_addr = 32'h0000_5540; // [11:2] = 0x155, lower 2 bits 00
    do_write(set_byte_offset(base_idx_addr, 2'b00), 32'h1111_1111);
    // Overwrite same word using different byte offset: should replace the same location
    do_write(set_byte_offset(base_idx_addr, 2'b01), 32'h2222_2222);
    do_write(set_byte_offset(base_idx_addr, 2'b10), 32'h3333_3333);
    do_write(set_byte_offset(base_idx_addr, 2'b11), 32'h4444_4444);

    // Now reading from any byte offset at that base should yield the LAST written word (0x4444_4444)
    do_read_and_check(set_byte_offset(base_idx_addr, 2'b00), 32'h4444_4444);
    do_read_and_check(set_byte_offset(base_idx_addr, 2'b01), 32'h4444_4444);
    do_read_and_check(set_byte_offset(base_idx_addr, 2'b10), 32'h4444_4444);
    do_read_and_check(set_byte_offset(base_idx_addr, 2'b11), 32'h4444_4444);

    // ------------------------------------------------------------
    // 3) MemWrite gating: attempt a write with MemWrite=0 and confirm memory unchanged
    // ------------------------------------------------------------
    // Write a known value, then attempt a "write" with MemWrite=0 to a different value
    do_write(32'h0000_2000, 32'hFACE_0FF0);
    // Attempt blocked write
    @(negedge Clk);
      Address   = 32'h0000_2000;
      WriteData = 32'hBAD0_BAD0;
      MemWrite  = 1'b0; // blocked
      MemRead   = 1'b0;
    @(posedge Clk);
    // Confirm content unchanged
    do_read_and_check(32'h0000_2000, 32'hFACE_0FF0);

    // ------------------------------------------------------------
    // 4) MemRead gating already checked inside task (ReadData->0 when MemRead=0)
    // ------------------------------------------------------------

    $display("All DataMemory tests PASSED ✅");
    #10;
    $finish;
  end

endmodule
