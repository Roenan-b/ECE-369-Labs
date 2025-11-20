`timescale 1ns/1ps
 
module ForwardingUnit(
    input  [4:0] id_ex_rs,
    input  [4:0] id_ex_rt,
    input        ex_mem_reg_write,
    input  [4:0] ex_mem_rd,
    input        mem_wb_reg_write,
    input  [4:0] mem_wb_rd,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @* begin
    forward_a = 2'b00;
    forward_b = 2'b00;

    // EX/MEM has highest priority (most recent data)
    if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rs)) begin
        forward_a = 2'b10;
    end
    else if (mem_wb_reg_write && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rs)) begin
        forward_a = 2'b01;
    end

    if (ex_mem_reg_write && (ex_mem_rd != 0) && (ex_mem_rd == id_ex_rt)) begin
        forward_b = 2'b10;
    end
    else if (mem_wb_reg_write && (mem_wb_rd != 0) && (mem_wb_rd == id_ex_rt)) begin
        forward_b = 2'b01;
    end
end
endmodule
 
