`timescale 1ns/1ps

module HazardDetection
#(parameter REGW = 5)
(
    // Pipeline register inputs
    input  wire [REGW-1:0]   if_id_Rs,
    input  wire [REGW-1:0]   if_id_Rt,
    input  wire [REGW-1:0]   id_ex_Rt,
    
    // Control signals from ID/EX
    input  wire              id_ex_MemRead,   // LW in EX

    // Control flow signals
    input  wire              id_isBranch,     // BEQ/BNE/etc in ID
    input  wire              id_isJR,         // JR in ID
    input  wire              id_isJump,       // J/JAL in ID
    input  wire              ex_branchTaken,  // Branch resolved in MEM

    // Dest regs from later stages for forwarding-related flushes (not used for stalls)
    input  wire              ex_mem_RegWrite,
    input  wire [REGW-1:0]   ex_mem_Rd,
    input  wire              mem_wb_RegWrite,
    input  wire [REGW-1:0]   mem_wb_Rd,

    // Outputs
    output reg               PCWrite,
    output reg               IF_ID_Write,
    output reg               ControlMuxSel,   // 0 = bubble
    output reg               IF_Flush,
    output reg               ID_Flush
);

    wire id_uses_rt =
        id_isBranch ||      // beq, bne
        1'b0;               // You can expand this if you add more instructions

    wire load_use_hazard =
        id_ex_MemRead &&
        (id_ex_Rt != 0) &&
        (
            (id_ex_Rt == if_id_Rs) ||                     // Rs dependency
            (id_uses_rt && (id_ex_Rt == if_id_Rt))        // Rt dependency when applicable
        );

    //----------------------------------------------------------------------
    // Default outputs (normal pipeline operation)
    //----------------------------------------------------------------------
    always @(*) begin
        PCWrite       = 1'b1;
        IF_ID_Write   = 1'b1;
        ControlMuxSel = 1'b1;  // normal control signals
        IF_Flush      = 1'b0;
        ID_Flush      = 1'b0;

        //------------------------------------------------------------------
        // Priority 1: Branch resolved in MEM
        //------------------------------------------------------------------
        if (ex_branchTaken) begin
            IF_Flush = 1'b1;
            ID_Flush = 1'b1;
        end

        //------------------------------------------------------------------
        // Priority 2: Jumps and JR resolved in ID
        //------------------------------------------------------------------
        else if (id_isJump || id_isJR) begin
            IF_Flush = 1'b1;   // flush IF only
            ID_Flush = 1'b0;
        end

        //------------------------------------------------------------------
        // Priority 3: TRUE Load-use hazard (stall 1 cycle)
        //------------------------------------------------------------------
        else if (load_use_hazard) begin
            PCWrite       = 1'b0;  // freeze PC
            IF_ID_Write   = 1'b0;  // freeze IF/ID reg
            ControlMuxSel = 1'b0;  // insert bubble into ID/EX
        end
    end

endmodule
