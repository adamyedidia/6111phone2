`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   20:45:48 11/25/2014
// Design Name:   randomnessExtractor
// Module Name:   /afs/athena.mit.edu/user/a/d/adamy/Desktop/6.111/final_project/6111phone2/6111phone/ise/randomnessExtractor_tb.v
// Project Name:  6111phone2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: randomnessExtractor
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module randomnessExtractor_tb;

	// Inputs
	reg clock;
	reg [7:0] from_ac97_data;
	reg ready;

	// Outputs
	wire [255:0] buffer;

	// Instantiate the Unit Under Test (UUT)
	randomnessExtractor uut (
		.clock(clock), 
		.from_ac97_data(from_ac97_data), 
		.ready(ready), 
		.buffer(buffer)
	);

	always #5 clock = !clock;

	initial begin
		// Initialize Inputs
		clock = 0;
		from_ac97_data = 0;
		ready = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here
		
		ready = 1;
		from_ac97_data = 45;
		
		#30;
		
		ready = 0;
		
		#30;
		
		ready = 1;
		from_ac97_data = 103;
		
		#30;
		
		ready = 0;
		
		#30;
		
		ready = 1;
		from_ac97_data = 2;
	end
      
endmodule

