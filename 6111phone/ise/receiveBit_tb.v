`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:43:42 11/25/2014
// Design Name:   receiveBit
// Module Name:   /afs/athena.mit.edu/user/a/d/adamy/Desktop/6.111/final_project/6111phone2/6111phone/ise/receiveBit_tb.v
// Project Name:  6111phone2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: receiveBit
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module receiveBit_tb;

	// Inputs
	reg clock;
	reg serialClock;
	reg serialData;

	// Outputs
	wire ready;
	wire data;

	// Instantiate the Unit Under Test (UUT)
	receiveBit uut (
		.clock(clock), 
		.serialClock(serialClock), 
		.serialData(serialData), 
		.ready(ready), 
		.data(data)
	);

	always #5 clock = !clock;
	initial begin
		// Initialize Inputs
		clock = 0;
		serialClock = 0;
		serialData = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		serialClock = 1;
		serialData = 1;
		
		#10;
		
		serialData = 0;
		
		#10;
		
		serialData = 0;
		
		#50;
		
		serialClock = 0;
		
		#100;
		
		serialClock = 1;
		serialData = 1;
		
		#10;
		
		serialData = 0;
		
		#10;
		
		serialData = 1;
		
		#10;
		
		serialData = 0;
		
		#10;
		
		serialData = 1;
		
		#10;
		
		serialData = 0;
		
		#10;
		
		serialData = 1;
		
		#10;
		
		serialData = 0;
		
		#10;
		
		serialData = 1;
		  
		// Add stimulus here

	end
      
endmodule

