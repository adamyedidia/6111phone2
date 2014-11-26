`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    19:55:23 11/25/2014 
// Design Name: 
// Module Name:    randomnessExtractor 
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
module randomnessExtractor(
	 input wire clock,
    input wire [7:0] from_ac97_data,
    input wire ready,
    output reg [255:0] buffer = 0
    );
	 
	 parameter BUFFER_LOGSIZE = 8;
	 
	 reg [BUFFER_LOGSIZE-1:0] buffer_index_counter = 0;
	 reg old_ready;
	 
	 always @(posedge clock) begin
		  if (ready & (~old_ready)) begin
				 buffer[buffer_index_counter] <= buffer[buffer_index_counter] ^ (^from_ac97_data);
				 buffer_index_counter <= buffer_index_counter + 1;
		  end
		  
		  old_ready <= ready;
	 end

endmodule

