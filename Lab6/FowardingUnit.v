module ForwardingUnit
#(parameter REGW = 5)
(
    input  wire        ex_mem_RegWrite,
    input  wire [REGW-1:0] ex_mem_Rd,
    input  wire        mem_wb_RegWrite,
    input  wire [REGW-1:0] mem_wb_Rd,
    input  wire [REGW-1:0] id_ex_Rs,
    input  wire [REGW-1:0] id_ex_Rt,
    output reg  [1:0]  ForwardA, // 00: ID/EX, 10: EX/MEM, 01: MEM/WB
    output reg  [1:0]  ForwardB
);
    always @(*) begin
        // defaults
        ForwardA = 2'b00;
        ForwardB = 2'b00;

        // EX hazard
        if (ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == id_ex_Rs))
            ForwardA = 2'b10;
        if (ex_mem_RegWrite && (ex_mem_Rd != 0) && (ex_mem_Rd == id_ex_Rt))
            ForwardB = 2'b10;

        // MEM hazard (lower priority)
        if (mem_wb_RegWrite && (mem_wb_Rd != 0) &&
            (mem_wb_Rd == id_ex_Rs) && (ForwardA == 2'b00))
            ForwardA = 2'b01;

        if (mem_wb_RegWrite && (mem_wb_Rd != 0) &&
            (mem_wb_Rd == id_ex_Rt) && (ForwardB == 2'b00))
            ForwardB = 2'b01;
    end
endmodule
