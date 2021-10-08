module arm(
	input logic clk, reset,
	output logic MemWrite,
	output logic [31:0] Adr, WriteData,
	input logic [31:0] ReadData);

logic [31:0] Instr;	
logic [3:0] ALUFlags;
logic  PCWrite, RegWrite, IRWrite;
logic AdrSrc, ALUSrcA,B;
logic [1:0] RegSrc, ALUSrcB, ImmSrc,  ResultSrc;
logic [2:0] ALUControl;

controller c(clk, reset, Instr[31:12], ALUFlags,
 RegSrc, RegWrite, ImmSrc, ALUSrcA, 
	ALUSrcB, ResultSrc, ALUControl, 
	IRWrite, MemWrite, AdrSrc, PCWrite,B);
	
datapath dp(clk, reset, Adr, WriteData,ALUFlags, ReadData,PCWrite,AdrSrc,IRWrite,
RegSrc,RegWrite,ImmSrc, ALUSrcA, ALUSrcB,ALUControl,ResultSrc, Instr,B);
	
	
	
endmodule