`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory  1
// Module - InstructionMemory.v
// Description - 32-Bit wide instruction memory.
//
// INPUT:-
// Address: 32-Bit address input port.
//
// OUTPUT:-
// Instruction: 32-Bit output port.
//
// FUNCTIONALITY:-
// Similar to the DataMemory, this module should also be byte-addressed
// (i.e., ignore bits 0 and 1 of 'Address'). All of the instructions will be 
// hard-coded into the instruction memory, so there is no need to write to the 
// InstructionMemory.  The contents of the InstructionMemory is the machine 
// language program to be run on your MIPS processor.
//
//
//we will store the machine code for a code written in C later. for now initialize 
//each entry to be its index * 3 (memory[i] = i * 3;)
//all you need to do is give an address as input and read the contents of the 
//address on your output port. 
// 
//Using a 32bit address you will index into the memory, output the contents of that specific 
//address. for data memory we are using 1K word of storage space. for the instruction memory 
//you may assume smaller size for practical purpose. you can use 128 words as the size and 
//hardcode the values.  in this case you need 7 bits to index into the memory. 
//
//be careful with the least two significant bits of the 32bit address. those help us index 
//into one of the 4 bytes in a word. therefore you will need to use bit [8-2] of the input address. 


////////////////////////////////////////////////////////////////////////////////

module InstructionMemory(Address, Instruction); 

    input [31:0] Address;                  // 32-bit input address coming from the Program Counter (PC)
    integer i;                             // Loop iterator used for initializing memory
    output reg [31:0] Instruction;         // 32-bit instruction output from the memory
    reg [31:0] memory [1023:0];             // Instruction memory: 128 words, each 32 bits wide
    
    // Initial block runs once at simulation start
    initial begin
        // Fill memory with simple test values (each location = index * 3)
        // This mimics "hard-coded" machine instructions for testing
        
        $readmemh("instruction_memory.mem", memory);
    end

    // Always block triggers whenever Address changes
    always @ (*) begin
        // Use bits [8:2] of Address as the word index:
        // - Instructions are word-aligned (32-bit = 4 bytes)
        // - Ignore bits [1:0] since they represent byte offsets
        // - Bits [8:2] provide a 7-bit index (0â€“127) into memory
        Instruction = memory[Address];
    end
endmodule
