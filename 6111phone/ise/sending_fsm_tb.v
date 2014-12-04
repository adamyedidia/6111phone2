`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   22:03:28 12/03/2014
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
	reg start;
	reg [254:0] secret_key_seed;
	reg incoming_packet_new;
	reg [15:0] incoming_packet_read_data;

	// Outputs
	wire [3:0] incoming_packet_read_index;
	wire [3:0] outgoing_packet_write_index;
	wire [15:0] outgoing_packet_write_data;
	wire outgoing_packet_write_enable;
	wire outgoing_packet_sending;
	wire [254:0] shared_key;
	wire done;

	// Instantiate the Unit Under Test (UUT)
	sending_fsm uut (
		.clock(clock), 
		.start(start), 
		.secret_key_seed(secret_key_seed), 
		.incoming_packet_new(incoming_packet_new), 
		.incoming_packet_read_index(incoming_packet_read_index), 
		.incoming_packet_read_data(incoming_packet_read_data), 
		.outgoing_packet_write_index(outgoing_packet_write_index), 
		.outgoing_packet_write_data(outgoing_packet_write_data), 
		.outgoing_packet_write_enable(outgoing_packet_write_enable), 
		.outgoing_packet_sending(outgoing_packet_sending), 
		.shared_key(shared_key), 
		.done(done)
	);

	always #5 clock = !clock;

	initial begin
		// Initialize Inputs
		clock = 0;
		start = 0;
		secret_key_seed = 0;
		incoming_packet_new = 0;
		incoming_packet_read_data = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

		start = 1;
		
		#10;
		
		start = 0;

		#100;
		
		incoming_packet_read_data = 16'h5555;
		
		#600;
		
		incoming_packet_read_data = 16'hAAAA;

	end
      
endmodule

