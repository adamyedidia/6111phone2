`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:51:08 11/30/2014 
// Design Name: 
// Module Name:    sending_fsm 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module sending_fsm #(parameter
	SECRET_KEY_SIZE=255,
   PUBLIC_KEY_SIZE=256,
	WIDTH=16, 
	LOG_PUBLIC_KEY_SIZE = 8,
	LOGSIZE = 4) (
		input wire clock,
		
		input wire start,
		input wire [SECRET_KEY_SIZE-1:0] secret_key_seed,
		
		input wire curve_done,
		
		input wire incoming_packet_new,
		output reg [LOGSIZE-1:0] incoming_packet_read_index,
		input wire [WIDTH-1:0] incoming_packet_read_data,
		
		output reg [LOGSIZE-1:0] outgoing_packet_write_index,
		output reg [WIDTH-1:0] outgoing_packet_write_data,
		output wire outgoing_packet_write_enable,
		output wire outgoing_packet_sending,
		
		output wire [PUBLIC_KEY_SIZE-1:0] shared_key,
		output wire done
    );
	
	reg keygen;
	
	localparam [PUBLIC_KEY_SIZE-1:0] basepoint = 9;
	reg [PUBLIC_KEY_SIZE-1:0] their_pk;
	
	wire [254:0] secret_key = {1'b1, secret_key_seed[0+:251], 3'b000};
	curve25519 curve25519(
		.clock(clock),
		.start(curve_start), // 1-cycle pulse
		.n(secret_key),
		.q(keygen ? basepoint : their_pk),
		.done(curve_done),
		.out(shared_key)
	);

	parameter WAITING_FOR_PK_GENERATION_STATE = 0;
	parameter SENDING_PK_NO_ACK_STATE = 1;
	parameter SENDING_PK_WITH_ACK_STATE = 2;
	parameter READING_THEIR_PK_STATE = 3;
	parameter GENERATING_SHARED_KEY_STATE = 4;
	parameter DONE_STATE = 5;
	
	parameter NO_ACK_MESSAGE = 16'h5555;
	parameter ACK_MESSAGE = 16'hAAAA;
	
	reg [2:0] state = WAITING_FOR_PK_GENERATION_STATE;
	
	reg [7:0] pk_index;
	reg [7:0] their_pk_index;
	
	always @(posedge clock) begin
		if (start) begin
			state <= WAITING_FOR_PK_GENERATION_STATE;
			outgoing_packet_write_index <= 0;
			incoming_packet_read_index <= 0;
			pk_index <= 0;
			curve_start <= 1;
			keygen <= 1;
			their_pk_index <= WIDTH-1;
		end
			
		case (state)
			WAITING_FOR_PK_GENERATION_STATE: begin
				if (curve_start) curve_start <= 0; 
				if (curve_done) begin
					state <= SENDING_PK_NO_ACK_STATE;
					outgoing_packet_sending <= 0;
				end
			end
			
			SENDING_PK_NO_ACK_STATE: begin
				if (~outgoing_packet_sending) begin
					if (outgoing_packet_write_index == 0) begin
						outgoing_packet_write_enable <= 1;
						outgoing_packet_write_data <= NO_ACK_MESSAGE;
					end
					
					else begin
						pk_index <= pk_index + WIDTH;
						
						if (pk_index == -WIDTH) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
						end
						
						outgoing_packet_write_data <= shared_key[pk_index-1-:WIDTH];
					end
					
					outgoing_packet_write_index <= outgoing_packet_write_index + 1;
				end
				
				if ((incoming_packet_read_data == ACK_MESSAGE) | 
					(incoming_packet_read_data == NO_ACK_MESSAGE)) begin
					state <= SENDING_PK_WITH_ACK_STATE;
					outgoing_packet_sending <= 0;
					outgoing_packet_write_index <= 0;
				end	
			end
			
			SENDING_PK_WITH_ACK_STATE: begin
				if (~outgoing_packet_sending) begin
					if (outgoing_packet_write_index == 0) begin
						outgoing_packet_write_enable <= 1;
						outgoing_packet_write_data <= ACK_MESSAGE;
					end
					
					else begin
						pk_index <= pk_index + WIDTH;
						 
						if (pk_index == -WIDTH) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
						end
						
					end
					
					outgoing_packet_write_index <= outgoing_packet_write_index + 1;
				end
				
				if (incoming_packet_read_data == ACK_MESSAGE) begin
					state <= READING_THEIR_PK_STATE;
					outgoing_packet_sending <= 0;
					incoming_packet_read_index <= 1;
				end
			end
			
			READING_THEIR_PK_STATE: begin
				their_pk[their_pk_index-:WIDTH] <= incoming_packet_read_data;
				incoming_packet_read_index <= incoming_packet_read_index + 1;
				their_pk_index <= their_pk_index + WIDTH;
				
				if (their_pk_index == PUBLIC_KEY_SIZE-1) begin
					state <= GENERATING_SHARED_KEY_STATE;
					keygen <= 0;
					curve_start <= 1;
				end
			end
			
			GENERATING_SHARED_KEY_STATE: begin
				if (curve_start) curve_start <= 0;
				if (curve_done) begin
					state <= DONE_STATE;
					done <= 1;
				end
			end
		endcase
	end
			
				
	
/*	reg [LOG_PUBLIC_KEY_SIZE-1+1:0] data_index = 0;
	
	always @(posedge clock) begin
		
		if (state == WAITING_FOR_PK_GENERATION_STATE) begin
			if (curve_done) state <= SENDING_PK_NO_ACK_STATE;
			
			recordAddr <= 0;
		end
		
		if (state == SENDING_PK_NO_ACK_STATE) begin
			recordAddr <= recordAddr + 1;
			
			if (data_index == 0) recordData <= NO_ACK_MESSAGE; // in this case send whether or not we're acking
			else recordData <= curve_out[data_index-1-:WIDTH];
			
			//else recordData <= curve_out[data_index:data_index-WIDTH]; // in this case send the PK
			
			// increment data_index with loop-around
			// I assume PUBLIC_KEY_SIZE is a multiple of WIDTH!
			if (data_index >= PUBLIC_KEY_SIZE) data_index <= 0 ;
			else data_index <= data_index + WIDTH;
			
			if ((incoming_packet_header == ACK_MESSAGE) | (incoming_packet_header == NO_ACK_MESSAGE)) begin
				state <= SENDING_PK_WITH_ACK_STATE;
			end
		end
		
		if (state == SENDING_PK_WITH_ACK_STATE) begin
			recordAddr <= recordAddr + 1;
			
			if (data_index == 0) recordData <= ACK_MESSAGE;
			else recordData <= curve_out[data_index-1-:WIDTH];
			
			// increment data_index with loop-around
			// I assume PUBLIC_KEY_SIZE is a multiple of WIDTH!
			if (data_index >= PUBLIC_KEY_SIZE) data_index <= 0;
			else data_index <= data_index + WIDTH;
			
			if (incoming_packet_header == ACK_MESSAGE) begin
				state <= SENDING_DATA_STATE;
			end
		end
			
/*		if (state == SENDING_DATA_STATE) begin
			recordingToB <= 1;
			recordAddr <= recordAddr + 1;
			
			recordData <= soudata_input[data_index+:WIDTH];
			
			data_index <= data_index + WIDTH;
		end*/
/*	end
	
	assign done = (state == SENDING_DATA_STATE); */
endmodule