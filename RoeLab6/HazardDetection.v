`timescale 1ns/1ps

module HazardDetection
#(parameter REGW = 5)
(
    input  wire              id_ex_MemRead,
    input  wire [REGW-1:0]   id_ex_Rt,

    input  wire [REGW-1:0]   if_id_Rs,
    input  wire [REGW-1:0]   if_id_Rt,

    input  wire              ex_mem_RegWrite,
    input  wire [REGW-1:0]   ex_mem_Rd,

    input  wire              mem_wb_RegWrite,
    input  wire [REGW-1:0]   mem_wb_Rd,

    input  wire              id_isBranch,
    input  wire              id_isJR,
    input  wire              ex_branchTaken,  // in this design: branch taken in MEM (PCSrc)
    input  wire              id_isJump,

    output reg               PCWrite,
    output reg               IF_ID_Write,
    output reg               ControlMuxSel,
    output reg               IF_Flush,
    output reg               ID_Flush
);

    // Dependencies for branch/JR analysis
    wire dep_exmem_rs = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rs);
    wire dep_exmem_rt = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rt);

    wire dep_memwb_rs = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rs);
    wire dep_memwb_rt = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rt);

    // Classic load-use hazard: load in ID/EX, consumer in IF/ID
    wire load_use_hazard =
        id_ex_MemRead &&
        ( (id_ex_Rt == if_id_Rs) || (id_ex_Rt == if_id_Rt) ) &&
        (id_ex_Rt != 0);

    // Branch depends on registers that aren't written yet
    wire branch_dep_hazard = id_isBranch &&
                             ( dep_exmem_rs || dep_exmem_rt ||
                               dep_memwb_rs || dep_memwb_rt );

    // JR depends on Rs not yet written
    wire jr_dep_hazard = id_isJR && (dep_exmem_rs || dep_memwb_rs);

    // Redirect / flush conditions
    wire redirect_taken = ex_branchTaken || id_isJump;

    always @(*) begin
        // Defaults: no stall, no flush, normal controls
        PCWrite       = 1'b1;
        IF_ID_Write   = 1'b1;
        ControlMuxSel = 1'b1;  // pass real controls to ID/EX
        IF_Flush      = 1'b0;
        ID_Flush      = 1'b0;

        // Highest priority: control flow redirect
        if (redirect_taken) begin
            // Flush IF on any redirect; flush ID when branch is taken
            IF_Flush = 1'b1;
            ID_Flush = ex_branchTaken;
        end
        // Stalls for hazards
        else if (load_use_hazard || branch_dep_hazard || jr_dep_hazard) begin
            PCWrite       = 1'b0; // hold PC
            IF_ID_Write   = 1'b0; // hold IF/ID
            ControlMuxSel = 1'b0; // zero control signals into ID/EX (insert bubble)
        end
    end

endmodule
