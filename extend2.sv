module extend2(input logic [7:0] byt,
	output logic [31:0] ExtImm);

	assign ExtImm = {24'b0, byt[7:0]};

endmodule
