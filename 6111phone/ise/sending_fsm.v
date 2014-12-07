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
	WIDTH=8,
	// careful about changing width due to array
	LOG_PUBLIC_KEY_SIZE = 8,
	LOGSIZE = 6) (
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
		output wire done,
		
		output reg [2:0] state = 0
    );
	
	reg keygen;
	reg curve_start;
	
	wire curve_done;
	
	localparam [PUBLIC_KEY_SIZE-1:0] BASEPOINT = 9;	
	
	reg [WIDTH-1:0] their_pk[31:0];
	
	wire [254:0] secret_key = {1'b1, secret_key_seed[0+:251], 3'b000};
	curve25519 curve25519(
		.clock(clock),
		.start(curve_start), // 1-cycle pulse
		.n(secret_key),
		.q(keygen ? BASEPOINT : {their_pk[31], their_pk[30], their_pk[29],
			their_pk[28], their_pk[27], their_pk[26], their_pk[25], their_pk[24],
			their_pk[23], their_pk[22], their_pk[21], their_pk[20], their_pk[19],
			their_pk[18], their_pk[17], their_pk[16], their_pk[15], their_pk[14],
			their_pk[13], their_pk[12], their_pk[11], their_pk[10], their_pk[9],
			their_pk[8], their_pk[7], their_pk[6], their_pk[5], their_pk[4],
			their_pk[3], their_pk[2], their_pk[1], their_pk[0]}),
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
	
	parameter NO_ACK_MESSAGE = 8'h55;
	parameter ACK_MESSAGE = 8'hAA;
	
//	reg [2:0] state = WAITING_FOR_PK_GENERATION_STATE;
	
	reg [8:0] pk_index;
	reg [4:0] their_pk_index;
	
	reg just_entered_state;
	
	always @(posedge clock) begin
		if (start) begin
			state <= WAITING_FOR_PK_GENERATION_STATE;
			outgoing_packet_write_index <= 0;
			incoming_packet_read_index <= 0;
			pk_index <= WIDTH-1;
			curve_start <= 1;
			keygen <= 1;
			their_pk_index <= 0;
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
						
						if (&pk_index[WIDTH:3]) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
							outgoing_packet_write_data <= {1'b0, shared_key[pk_index-1-:WIDTH-1]};
						end
						
						else outgoing_packet_write_data <= shared_key[pk_index-:WIDTH];
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
						 
						if (&pk_index[WIDTH:3]) begin
							outgoing_packet_write_enable <= 0;
							outgoing_packet_sending <= 1;
							outgoing_packet_write_data <= {1'b0, shared_key[pk_index-1-:WIDTH-1]};
						end
						
						else outgoing_packet_write_data <= shared_key[pk_index-:WIDTH];
						outgoing_packet_write_index <= outgoing_packet_write_index + 1;
					end
				end
				
				else if (incoming_packet_read_data == ACK_MESSAGE) begin
					state <= READING_THEIR_PK_STATE;
//					outgoing_packet_sending <= 0;
					incoming_packet_read_index <= 1;
					their_pk_index <= 0;
					just_entered_state <= 1;
				end
			end
			
			READING_THEIR_PK_STATE: begin
				
				if (just_entered_state) begin
					just_entered_state <= 0;
					incoming_packet_read_index <= incoming_packet_read_index + 1;
				end

				else begin
					their_pk[their_pk_index] <= incoming_packet_read_data;
	//				their_pk[their_pk_index-:WIDTH] <= incoming_packet_read_data;
					incoming_packet_read_index <= incoming_packet_read_index + 1;
					their_pk_index <= their_pk_index + 1;
				
					if (their_pk_index == 0) begin
						state <= GENERATING_SHARED_KEY_STATE;
						keygen <= 0;
						curve_start <= 1;
					end
				end
			end
			
			GENERATING_SHARED_KEY_STATE: begin
				if (curve_start) curve_start <= 0;
				else if (curve_done) state <= DONE_STATE;
			end
		endcase
	end
			
//	assign their_pk = their_pk_substitute;
	assign done = (state == DONE_STATE);
endmodule


/*module dummy_curve25519(input wire clock, start,
                  input wire [254:0] n, // scalar
                  input wire [254:0] q, // point
                  output reg done = 0,
                  output wire [254:0] out);
						
	reg future_done;
	reg future_future_done;
	reg future_future_future_done;
	
	always @(posedge clock) begin
	 
	 
		done <= future_done;
		future_done <= future_future_done;
		future_future_done <= future_future_future_done;
		
		if (start) future_future_future_done <= 1;
		else future_future_future_done <= 0;
	end	
			
	assign out = (q == 9) ? 255'h3333333333333333333333333333333333333333333333333333333333333333 
										 : 255'h2222222222222222222222222222222222222222222222222222222222222222;

endmodule*/