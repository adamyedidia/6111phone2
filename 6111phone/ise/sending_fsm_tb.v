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

	reg clock;

	// Inputs
	reg alice_clock;
	reg alice_start;
	reg [254:0] alice_secret_key_seed;
	reg alice_incoming_packet_new;
	reg [7:0] alice_incoming_packet_read_data;
	
	reg [7:0] alice_send_array[63:0];
//	reg [4:0] alice_sending_index;

	// Outputs
	wire [5:0] alice_incoming_packet_read_index;
	wire [5:0] alice_outgoing_packet_write_index;
	wire [7:0] alice_outgoing_packet_write_data;
	wire alice_outgoing_packet_write_enable;
	wire alice_outgoing_packet_sending;
	wire [254:0] alice_shared_key;
	wire alice_done;

	// Instantiate the Unit Under Test (UUT)
	sending_fsm alice_sf (
		.clock(alice_clock), 
		.start(alice_start), 
		.secret_key_seed(alice_secret_key_seed), 
		.incoming_packet_new(alice_incoming_packet_new), 
		.incoming_packet_read_index(alice_incoming_packet_read_index), 
		.incoming_packet_read_data(alice_incoming_packet_read_data), 
		.outgoing_packet_write_index(alice_outgoing_packet_write_index), 
		.outgoing_packet_write_data(alice_outgoing_packet_write_data), 
		.outgoing_packet_write_enable(alice_outgoing_packet_write_enable), 
		.outgoing_packet_sending(alice_outgoing_packet_sending), 
		.shared_key(alice_shared_key), 
		.done(alice_done)
	);
	
	reg bob_clock;
	reg bob_start;
	reg [254:0] bob_secret_key_seed;
	reg bob_incoming_packet_new;
	reg [7:0] bob_incoming_packet_read_data;

	reg [7:0] bob_send_array[63:0];
//	reg [4:0] bob_sending_index;

	// Outputs
	wire [5:0] bob_incoming_packet_read_index;
	wire [5:0] bob_outgoing_packet_write_index;
	wire [7:0] bob_outgoing_packet_write_data;
	wire bob_outgoing_packet_write_enable;
	wire bob_outgoing_packet_sending;
	wire [254:0] bob_shared_key;
	wire bob_done;
	
	sending_fsm bob_sf (
		.clock(bob_clock), 
		.start(bob_start), 
		.secret_key_seed(bob_secret_key_seed), 
		.incoming_packet_new(bob_incoming_packet_new), 
		.incoming_packet_read_index(bob_incoming_packet_read_index), 
		.incoming_packet_read_data(bob_incoming_packet_read_data), 
		.outgoing_packet_write_index(bob_outgoing_packet_write_index), 
		.outgoing_packet_write_data(bob_outgoing_packet_write_data), 
		.outgoing_packet_write_enable(bob_outgoing_packet_write_enable), 
		.outgoing_packet_sending(bob_outgoing_packet_sending), 
		.shared_key(bob_shared_key), 
		.done(bob_done)
	);

	always #5 clock = !clock;

	always @(posedge clock) begin
		alice_clock <= !alice_clock;
	end
	
	always @(negedge clock) begin
		bob_clock <= !bob_clock;
	end
	
/*	always @(posedge alice_clock) begin
		alice_send_buffer[alice_outgoing_packet_write_index-:4] <= */

	always @(posedge alice_clock) begin
		if (alice_outgoing_packet_write_enable)
			alice_send_array[alice_outgoing_packet_write_index] <= 
				alice_outgoing_packet_write_data;
		
		if (bob_outgoing_packet_sending)
			alice_incoming_packet_read_data <= bob_send_array[alice_incoming_packet_read_index];
	end
		
	always @(posedge bob_clock) begin
		if (bob_outgoing_packet_write_enable)
			bob_send_array[bob_outgoing_packet_write_index] <= 
				bob_outgoing_packet_write_data;
		
		if (alice_outgoing_packet_sending)
			bob_incoming_packet_read_data <= alice_send_array[bob_incoming_packet_read_index];
	end
		
	initial begin
		clock = 0;
		// Initialize Inputs
		alice_clock = 0;
		bob_clock = 0;
		
		
		
		alice_start = 1;
		alice_secret_key_seed = 1;
		
		#20;
		
		alice_start = 0;

		// Wait 100 ns for global reset to finish
		#10000;
        
		bob_start = 1;
		bob_secret_key_seed = 2;
		
		#20;
		
		bob_start = 0;
		
		// Add stimulus here

	end
      
endmodule
