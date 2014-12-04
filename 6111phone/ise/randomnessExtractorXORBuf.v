`timescale 1ns / 1ps

module randomnessExtractorXORBuf (
	 input wire clock,
    input wire [31:0] n_samples, // 2.7e6
	 
    input wire [31:0] entropy, // ac97_data[0+:16]
	 input wire [1:0] entropy_bytes, // 2
    input wire entropy_ready, // ready
	 
	 output reg ready,
    output reg [511:0] out
    );
	 
	 parameter BUFFER_LOGSIZE = 8;
	 
	 reg [31:0] sample_count = 0;
	 reg [BUFFER_LOGSIZE-1:0] buffer_index_counter = 0;
	 reg old_entropy_ready;
	 
	 always @(posedge clock) begin
		  if (entropy_ready & (~old_entropy_ready)) begin
				 out[buffer_index_counter] <= out[buffer_index_counter] ^ (^entropy);
				 buffer_index_counter <= buffer_index_counter + 1;
				 sample_count <= sample_count + 1;
		  end
		  if (sample_count == n_samples) ready <= 1;
		  if (ready) ready <= 0;
		  
		  old_entropy_ready <= entropy_ready;
	 end
endmodule

