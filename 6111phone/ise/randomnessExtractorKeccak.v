`timescale 1ns / 1ps


module randomnessExtractorKeccak (
	 input wire clock,
    input wire [31:0] n_samples, // 2.7e6
	 
    input wire [31:0] entropy, // ac97_data[0+:16]
	 input wire [1:0] entropy_bytes, // 2
    input wire entropy_ready, // ready
	 
	 output wire ready,
    output wire [511:0] out
    );
	 
	 wire hash_buffer_full;
	 reg [31:0] sample_count;
	 
	 always @(posedge clock) begin
		if (entropy_ready && !hash_buffer_full) sample_count <= sample_count + 1;
	 end
	 
	 keccak hash(.clk(clock), .reset(ready), .in(entropy), .in_ready(entropy_ready),
	                .is_last(sample_count == n_samples), .byte_num(entropy_bytes),
						 .buffer_full(hash_buffer_full), .out(out), .out_ready(ready));
endmodule