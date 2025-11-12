// ---------------------------------------------
// Hazard Detection Unit (MIPS 5-stage)
// ---------------------------------------------
// Inputs:
//   id_ex_MemRead   : 1 if the ID/EX instruction is a load (will read from data mem)
//   id_ex_Rt        : Rt field of the ID/EX instruction (load destination reg)
//
//   if_id_Rs, if_id_Rt : source regs of the IF/ID instruction (the one decoding)
//
//   ex_mem_RegWrite : 1 if EX/MEM will write a register
//   ex_mem_Rd       : destination reg in EX/MEM
//
//   mem_wb_RegWrite : 1 if MEM/WB will write a register
//   mem_wb_Rd       : destination reg in MEM/WB
//
//   id_isBranch     : 1 when IF/ID is a branch (beq/bne)
//   id_isJR         : 1 when IF/ID is jr (uses Rs)
//   ex_branchTaken  : 1 when branch resolves as taken in EX stage
//   id_isJump       : 1 when IF/ID is an unconditional jump (j, jal)
//
// Outputs:
//   PCWrite         : gate Program Counter write (0 to stall PC)
//   IF_ID_Write     : gate IF/ID pipeline reg write (0 to hold IF/ID)
//   ControlMuxSel   : 1 = normal controls to ID/EX; 0 = zero controls (insert NOP bubble)
//   IF_Flush        : flush instruction in IF on redirect (taken branch/jump)
//   ID_Flush        : optional: flush instruction in ID on redirect (taken branch)
//
// Notes:
//   - Zero register (r0) is ignored as a true dependency.
//   - Prioritization: flush on redirect has priority over stalls to avoid deadlock.
// ---------------------------------------------
module HazardDetectionUnit
#(parameter REGW = 5)
(
    input  wire        id_ex_MemRead,
    input  wire [REGW-1:0] id_ex_Rt,

    input  wire [REGW-1:0] if_id_Rs,
    input  wire [REGW-1:0] if_id_Rt,

    input  wire        ex_mem_RegWrite,
    input  wire [REGW-1:0] ex_mem_Rd,

    input  wire        mem_wb_RegWrite,
    input  wire [REGW-1:0] mem_wb_Rd,

    input  wire        id_isBranch,
    input  wire        id_isJR,
    input  wire        ex_branchTaken,
    input  wire        id_isJump,

    output reg         PCWrite,
    output reg         IF_ID_Write,
    output reg         ControlMuxSel,
    output reg         IF_Flush,
    output reg         ID_Flush
);

    // -----------------------------
    // Basic dependency helpers
    // -----------------------------
    wire dep_exmem_rs = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rs);
    wire dep_exmem_rt = ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == if_id_Rt);

    wire dep_memwb_rs = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rs);
    wire dep_memwb_rt = mem_wb_RegWrite && (mem_wb_Rd != 0) && (mem_wb_Rd == if_id_Rt);

    // Load-use hazard (the classic one)
    wire load_use_hazard = id_ex_MemRead &&
                           ( (id_ex_Rt == if_id_Rs) || (id_ex_Rt == if_id_Rt) ) &&
                           (id_ex_Rt != 0);

    // Branch/JR needs correct register operands in ID stage.
    // Stall if the branch depends on results still in EX/MEM or MEM/WB (i.e., not forwarded into ID).
    wire branch_dep_hazard = id_isBranch &&
                             ( dep_exmem_rs || dep_exmem_rt || dep_memwb_rs || dep_memwb_rt );

    // JR only reads Rs; stall if its Rs not yet written.
    wire jr_dep_hazard = id_isJR && (dep_exmem_rs || dep_memwb_rs);

    // Redirect / flush conditions
    // - If branch resolves taken in EX → flush IF and ID (kill younger wrong-path instrs)
    // - If an unconditional jump in ID → flush IF (kill the one being fetched)
    wire redirect_taken = ex_branchTaken || id_isJump;

    // -----------------------------
    // Output logic
    // -----------------------------
    always @(*) begin
        // Defaults: no stall, no flush, normal controls
        PCWrite       = 1'b1;
        IF_ID_Write   = 1'b1;
        ControlMuxSel = 1'b1; // pass real controls
        IF_Flush      = 1'b0;
        ID_Flush      = 1'b0;

        // Highest priority: redirect flushes
        if (redirect_taken) begin
            // Flush IF on any redirect; Flush ID when branch taken from EX
            IF_Flush      = 1'b1;
            ID_Flush      = ex_branchTaken;

            // No additional stalls purely because of the redirect.
            // (PC will be written with the redirect target in your PC mux logic.)
        end
        // Stalls for hazards (mutually inclusive OR)
        else if (load_use_hazard || branch_dep_hazard || jr_dep_hazard) begin
            PCWrite       = 1'b0; // hold PC
            IF_ID_Write   = 1'b0; // hold IF/ID
            ControlMuxSel = 1'b0; // send zeros to ID/EX control (insert bubble)
        end
    end

endmodule
