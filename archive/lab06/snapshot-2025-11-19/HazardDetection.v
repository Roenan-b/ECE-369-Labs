`timescale 1ns/1ps
  
module HazardDetection
#(parameter REGW = 5)
(
    // Pipeline register inputs
    input  wire [REGW-1:0]   if_id_Rs,
    input  wire [REGW-1:0]   if_id_Rt,
    input  wire [REGW-1:0]   id_ex_Rt,
    input  wire [REGW-1:0]   id_ex_Rd,
    
    // Control signals
    input  wire              id_ex_MemRead,    // LW instruction in EX
    input  wire              id_ex_RegWrite,   // Instruction in EX writes reg
    input  wire              ex_mem_RegWrite,  // Instruction in MEM writes reg  
    input  wire              mem_wb_RegWrite,  // Instruction in WB writes reg
    
    // Branch/Jump information
    input  wire              id_isBranch,      // BEQ, BNE, etc.
    input  wire              id_isJR,          // JR instruction
    input  wire              id_isJump,        // J, JAL
    input  wire              ex_branchTaken,   // Branch resolved in MEM stage
    
    // Destination registers
    input  wire [REGW-1:0]   ex_mem_Rd,
    input  wire [REGW-1:0]   mem_wb_Rd,
    
    // Output control signals
    output reg               PCWrite,          // Freeze PC if 0
    output reg               IF_ID_Write,      // Freeze IF/ID if 0  
    output reg               ControlMuxSel,    // 0 = insert bubble
    output reg               IF_Flush,         // Flush IF stage
    output reg               ID_Flush          // Flush ID stage
);

    // Dependency checks for branch/JR instructions
    wire rs_dep_ex_mem = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rs);
    wire rt_dep_ex_mem = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rt);
    wire rs_dep_mem_wb = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rs);
    wire rt_dep_mem_wb = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rt);
    
    // Load-Use Hazard: LW followed by dependent instruction
    wire load_use_hazard = 
        id_ex_MemRead && 
        (id_ex_Rt != 0) &&
        ((id_ex_Rt == if_id_Rs) || (id_ex_Rt == if_id_Rt));
    
    // Load-to-Branch Hazard: LW whose result is needed by branch in ID
    // Forwarding can't help here because data isn't available until MEM stage
    wire load_to_branch_hazard =
        id_isBranch &&
        id_ex_MemRead &&
        (id_ex_Rt != 0) &&
        ((id_ex_Rt == if_id_Rs) || (id_ex_Rt == if_id_Rt));
    
    // Load-to-JR Hazard: LW whose result is needed by JR in ID  
    // Same issue - data not available until MEM stage
    wire load_to_jr_hazard =
        id_isJR &&
        id_ex_MemRead &&
        (id_ex_Rt != 0) &&
        (id_ex_Rt == if_id_Rs);
    
    // Control flow redirect conditions
    wire jump_happening = id_isJump || id_isJR;
    wire branch_happening = ex_branchTaken;

    always @(*) begin
        // Default values: no stall, no flush, normal operation
        PCWrite       = 1'b1;
        IF_ID_Write   = 1'b1;
        ControlMuxSel = 1'b1;  // Pass normal control signals
        IF_Flush      = 1'b0;
        ID_Flush      = 1'b0;

        // Priority 1: Control flow changes (highest priority)
        if (branch_happening) begin
            // Branch taken in MEM stage - flush IF and ID
            IF_Flush = 1'b1;
            ID_Flush = 1'b1;
            PCWrite  = 1'b1;   // PC gets new address from branch
            IF_ID_Write = 1'b1; // Allow IF/ID to update with new instruction
        end
        else if (jump_happening) begin
            // Jump in ID stage - flush IF only
            IF_Flush = 1'b1;
            ID_Flush = 1'b0;
            PCWrite  = 1'b1;   // PC gets new address from jump
            IF_ID_Write = 1'b1; // Allow IF/ID to update
        end
        // Priority 2: Hazard conditions (stall pipeline)
        else if (load_use_hazard || load_to_branch_hazard || load_to_jr_hazard) begin
            // Stall the pipeline for 1 cycle
            PCWrite       = 1'b0;  // Freeze PC
            IF_ID_Write   = 1'b0;  // Freeze IF/ID register
            ControlMuxSel = 1'b0;  // Insert NOP bubble into EX stage
            
            // No flushing during stalls
            IF_Flush = 1'b0;
            ID_Flush = 1'b0;
        end
        // Note: Regular RAW hazards for branches/JR are handled by forwarding
        // We only stall when the data isn't available yet (load instructions)
    end

endmodule