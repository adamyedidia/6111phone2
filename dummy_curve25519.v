`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    22:30:27 12/03/2014 
// Design Name: 
// Module Name:    dummy_curve25519 
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
module dummy_curve25519(input wire clock, start,
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

endmodule
