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
   PUBLIC_KEY_SIZE=255,
	WIDTH=16, 
	LOG_PUBLIC_KEY_SIZE = 8,
	LOGSIZE = 4) (
		input wire clock,
		
		input wire start,
		input wire [SECRET_KEY_SIZE-1:0] secret_key_seed,
				
		input wire incoming_packet_new,
		output reg [LOGSIZE-1:0] incoming_packet_read_index,
		input wire [WIDTH-1:0] incoming_packet_read_data,
		
		output reg [LOGSIZE-1:0] outgoing_packet_write_index,
		output reg [WIDTH-1:0] outgoing_packet_write_data,
		output reg outgoing_packet_write_enable,
		output reg outgoing_packet_sending,
		
		output wire [PUBLIC_KEY_SIZE-1:0] shared_key,
		output wire done
    );
	
	reg keygen;
	reg curve_start;
	
	wire curve_done;
	
	localparam [PUBLIC_KEY_SIZE-1:0] BASEPOINT = 9;
	reg [PUBLIC_KEY_SIZE-1:0] their_pk;
	
	wire [254:0] secret_key = {1'b1, secret_key_seed[0+:251], 3'b000};
	curve25519 curve25519(
		.clock(clock),
		.start(curve_start), // 1-cycle pulse
		.n(secret_key),
		.q(keygen ? BASEPOINT : their_pk),
		// ?? SOMETHING IS BIZARRE, their_pk is 256 bits but q is a 255-bit input
		// andres: their_pk is 255 bits (255-1:0)
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
	
	reg just_entered_state;
	
	always @(posedge clock) begin
		if (start) begin
			state <= WAITING_FOR_PK_GENERATION_STATE;
			outgoing_packet_write_index <= 0;
			incoming_packet_read_index <= 0;
			pk_index <= WIDTH-1;
			curve_start <= 1;
			keygen <= 1;
			their_pk_index <= WIDTH-1;
			outgoing_packet_write_enable <= 0;
		end
			
		case (state)
			WAITING_FOR_PK_GENERATION_STATE: begin
				if (curve_start) curve_start <= 0; 
				if (curve_done) begin
					state <= SENDING_PK_NO_ACK_STATE;
					outgoing_packet_sending <= 0;
					just_entered_state <= 1;
				end
			end
			
			SENDING_PK_NO_ACK_STATE: begin
				if (~outgoing_packet_sending) begin
					if (just_entered_state) begin
						outgoing_packet_write_enable <= 1;
						outgoing_packet_write_data <= NO_ACK_MESSAGE;
						just_entered_state <= 0;
					end
					
					else begin
						pk_index <= pk_index + WIDTH;
						
						if (&outgoing_packet_write_index) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
						end
						
						outgoing_packet_write_data <= shared_key[pk_index-:WIDTH];
						outgoing_packet_write_index <= outgoing_packet_write_index + 1;
					end
				end
				
				else if ((incoming_packet_read_data == ACK_MESSAGE) | 
					(incoming_packet_read_data == NO_ACK_MESSAGE)) begin
					state <= SENDING_PK_WITH_ACK_STATE;
					outgoing_packet_sending <= 0;
					outgoing_packet_write_index <= 0;
					pk_index <= WIDTH - 1;
					just_entered_state <= 1;
				end	
			end
			
			SENDING_PK_WITH_ACK_STATE: begin
				if (~outgoing_packet_sending) begin
					if (just_entered_state) begin
						outgoing_packet_write_enable <= 1;
						outgoing_packet_write_data <= ACK_MESSAGE;
						just_entered_state <= 0;
					end
					
					else begin
						pk_index <= pk_index + WIDTH;
						 
						if (&outgoing_packet_write_index) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
						end
						
						
						outgoing_packet_write_data <= shared_key[pk_index-:WIDTH];
						outgoing_packet_write_index <= outgoing_packet_write_index + 1;
					end
				end
				
				else if (incoming_packet_read_data == ACK_MESSAGE) begin
					state <= READING_THEIR_PK_STATE;
					outgoing_packet_sending <= 0;
					incoming_packet_read_index <= 1;
				end
			end
			
			READING_THEIR_PK_STATE: begin
				their_pk[their_pk_index-:WIDTH] <= incoming_packet_read_data;
				incoming_packet_read_index <= incoming_packet_read_index + 1;
				their_pk_index <= their_pk_index + WIDTH;
				
				if (&their_pk_index) begin
					state <= GENERATING_SHARED_KEY_STATE;
					keygen <= 0;
					curve_start <= 1;
				end
			end
			
			GENERATING_SHARED_KEY_STATE: begin
				if (curve_start) curve_start <= 0;
				if (curve_done) state <= DONE_STATE;
			end
		endcase
	end
			
	assign done = (state == DONE_STATE);
endmodule
