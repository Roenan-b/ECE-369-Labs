`timescale 1ns / 1ps
  
//Percent Effort
// Roes: 33% Evan: 33% Noah: 33%

module RegisterID_EX(
    input             Clk,
    input             Reset,
    input             Flush,        // NEW: flush bubble into ID/EX

    // EX control
    input             ALUSrcIn,
    input      [5:0]  ALUopIn,
    input             RegDstIn,     // 1-bit (rt vs rd)
    input             UseShamtIn,
    input      [4:0]  shamtIn,
    input      [1:0]  MemSizeIn,
    input             MemUnsignedIn,

    output reg        ALUSrcOut,
    output reg [5:0]  ALUopOut,
    output reg        RegDstOut,
    output reg        UseShamtOut,
    output reg [4:0]  shamtOut,

    // MEM control
    input             BranchIn,
    input             MemWriteIn,
    input             MemReadIn,

    output reg        BranchOut,
    output reg        MemWriteOut,
    output reg        MemReadOut,

    // WB control
    input      [1:0]  MemtoRegIn,
    input             RegWriteIn,
    output reg [1:0]  MemtoRegOut,
    output reg        RegWriteOut,

    // Data for EX
    input      [31:0] ReadData1In,
    input      [31:0] ReadData2In,
    input      [31:0] PCAddResultIn,
    input      [31:0] signResultIn,

    input      [4:0]  RTRegdestIn,
    input      [4:0]  RDRegdestIn,

    output reg [31:0] ReadData1Out,
    output reg [31:0] ReadData2Out,
    output reg [31:0] PCAddResultOut,
    output reg [31:0] signResultOut,
    output reg [4:0]  RTRegdestOut,
    output reg [4:0]  RDRegdestOut,

    // memory mode
    output reg [1:0]  MemSizeOut,
    output reg        MemUnsignedOut,

    // RegDstSel (2-bit for write-reg selection in EX)
    input      [1:0]  RegDstSelIn,
    output reg [1:0]  RegDstSelOut,

    // rs/rt numbers for forwarding/hazards
    input      [4:0]  RsIn,
    input      [4:0]  RtIn,
    output reg [4:0]  RsOut,
    output reg [4:0]  RtOut
);

    always @(posedge Clk) begin
        if (Reset || Flush) begin
            // EX
            ALUSrcOut      <= 1'b0;
            ALUopOut       <= 6'b000000;
            RegDstOut      <= 1'b0;
            UseShamtOut    <= 1'b0;
            shamtOut       <= 5'b00000;

            // MEM
            BranchOut      <= 1'b0;
            MemWriteOut    <= 1'b0;
            MemReadOut     <= 1'b0;

            // WB
            MemtoRegOut    <= 2'b00;
            RegWriteOut    <= 1'b0;

            // Data
            ReadData1Out   <= 32'b0;
            ReadData2Out   <= 32'b0;
            PCAddResultOut <= 32'b0;
            signResultOut  <= 32'b0;
            RTRegdestOut   <= 5'b00000;
            RDRegdestOut   <= 5'b00000;

            MemSizeOut     <= 2'b10;   // default: word
            MemUnsignedOut <= 1'b0;

            RegDstSelOut   <= 2'b00;
            RsOut          <= 5'b00000;
            RtOut          <= 5'b00000;
        end else begin
            // EX
            ALUSrcOut      <= ALUSrcIn;
            ALUopOut       <= ALUopIn;
            RegDstOut      <= RegDstIn;
            UseShamtOut    <= UseShamtIn;
            shamtOut       <= shamtIn;

            // MEM
            BranchOut      <= BranchIn;
            MemWriteOut    <= MemWriteIn;
            MemReadOut     <= MemReadIn;

            // WB
            MemtoRegOut    <= MemtoRegIn;
            RegWriteOut    <= RegWriteIn;

            // Data
            ReadData1Out   <= ReadData1In;
            ReadData2Out   <= ReadData2In;
            PCAddResultOut <= PCAddResultIn;
            signResultOut  <= signResultIn;
            RTRegdestOut   <= RTRegdestIn;
            RDRegdestOut   <= RDRegdestIn;

            MemSizeOut     <= MemSizeIn;
            MemUnsignedOut <= MemUnsignedIn;

            RegDstSelOut   <= RegDstSelIn;
            RsOut          <= RsIn;
            RtOut          <= RtIn;

            $display("[%0t] IDEX : MemSizeOut=%b UnsOut=%b",
                     $time, MemSizeOut, MemUnsignedOut);
        end
    end

endmodule
