`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:51:00 11/30/2014
// Design Name:   sending_fsm
// Module Name:   /afs/athena.mit.edu/user/a/d/adamy/Desktop/6.111/final_project/6111phone2/6111phone/ise/sending_fsm_tb.v
// Project Name:  6111phone2
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: sending_fsm
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module sending_fsm_tb;

	// Inputs
	reg clock;
	reg [255:0] curve_out;
	reg curve_done;
	reg [15:0] incoming_packet_header;

	// Outputs
	wire recordingToB;
	wire [3:0] recordAddr;
	wire [15:0] recordData;

	// Instantiate the Unit Under Test (UUT)
	sending_fsm uut (
		.clock(clock), 
		.curve_out(curve_out), 
		.curve_done(curve_done), 
		.incoming_packet_header(incoming_packet_header), 
		.recordingToB(recordingToB), 
		.recordAddr(recordAddr), 
		.recordData(recordData),
		.done(done)
	);

	always #5 clock = !clock;

	initial begin
		// Initialize Inputs
		clock = 0;
		curve_out = 0;
		curve_done = 0;
		incoming_packet_header = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		curve_out = 256'h5555555555555555555555555555555555555555555555555555555555555555; 
		
		#50;
		
		curve_done = 1;
		  
		#50;
		
		incoming_packet_header = 1;
		
		  
		// Add stimulus here

	end
      
endmodule

