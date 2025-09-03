`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// ECE369A - Computer Architecture
// Laboratory 1 
// Module - PCAdder_tb.v
// Description - Test the 'PCAdder.v' module.
////////////////////////////////////////////////////////////////////////////////

module PCAdder_tb();

    reg [31:0] PCResult;

    wire [31:0] PCAddResult;

    PCAdder u0(
        .PCResult(PCResult), 
        .PCAddResult(PCAddResult)
    );

	initial begin
	
    /* Please fill in the implementation here... */
	PCResult <= 0;
	//PCAddResult <= 0;

	#100
	#100
	#100
/*		$display(PCResult,PCAddResult);
	PCResult <= 5;

	$display(PCResult, PCAddResult);	
		
	*/
	end

endmodule

