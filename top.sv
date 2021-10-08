module top(input logic clk, reset,
	output logic [31:0] WriteData, Adr,
	output logic MemWrite);

logic [31:0]  Instr, ReadData;

arm arm(clk, reset, MemWrite, Adr,
	WriteData, ReadData);
	
mem mem(clk, MemWrite, Adr, WriteData, ReadData);

endmodule

module testbench();
	logic clk;
	logic reset;
	logic [31:0] WriteData, Adr;
	logic MemWrite;
	// instantiate device to be tested
	top dut(clk, reset, WriteData, Adr, MemWrite);
// initialize test
initial begin
		reset <= 1; # 22; reset <= 0;
	end
// generate clock to sequence tests
always
	begin
	clk <= 1; # 5; clk <= 0; # 5;
	end
// check that 7 gets written to address 0x64
// at end of program
always @(negedge clk)
begin
	if(MemWrite) begin
		if(Adr === 100 & WriteData === 7) begin
			$display("Simulation succeeded");
			$stop;
		end 
	//if(Adr === 128 & WriteData === 32'b11111110) begin
	//		$display("Simulation succeeded");
	//		$stop;
	//	end 
		else if (Adr !== 96) begin
			$display("Simulation failed");
			$stop;
		end
	end
end

endmodule
