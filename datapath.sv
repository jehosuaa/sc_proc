module datapath(input logic clk, reset,
	output logic [31:0] Adr,
	output logic [31:0] WriteData,
	output logic [3:0] ALUFlags,
	input logic [31:0] ReadData,
	input logic  PCWrite,
	input logic AdrSrc,
	input logic IRWrite,
	input logic  [1:0] RegSrc,
	input logic RegWrite,
	input logic [1:0] ImmSrc,
	input logic ALUSrcA,
	input logic [1:0] ALUSrcB,
	input logic [2:0] ALUControl,
	input logic [1:0] ResultSrc,
	output logic [31:0] Instr,
	input logic B);

	
	
	
logic [31:0] PC,Data,A,ALUResult,ALUOut,RD1,RD2;
logic [3:0] RA1,RA2,R15=4'b1111;
logic [31:0] ExtImm,ExtImm2, SrcA, SrcB, Result,rixtm2,NewResult;
logic [7:0] muxout,segldrb;
logic [31:0] muxout2;
logic [1:0] ALUldrb;

// next adr logic
flopenr #(32) pcreg(clk, reset,PCWrite, NewResult, PC);
mux2 #(32) adrmux(PC, NewResult, AdrSrc, Adr);

//despues de memory

flopenr #(32) Instreg(clk, reset,IRWrite,ReadData,Instr);
flopr #(32) Datareg(clk, reset,ReadData,Data);

mux2 #(4) Ra1mux(Instr[19:16], R15, RegSrc[0], RA1);
mux2 #(4) Ra2mux(Instr[3:0],Instr[15:12], RegSrc[1], RA2);

extend ext(Instr[23:0], ImmSrc, ExtImm);

//register file

regfile rf(clk, RegWrite, RA1, RA2,
	Instr[15:12], NewResult, NewResult,
	RD1, RD2);

flopr #(32) Areg(clk, reset,RD1,A);
flopr #(32) WriteDatareg(clk, reset,RD2,WriteData);

mux2 #(32) SrcAmux(A,PC, ALUSrcA,SrcA);
mux_4 #(32) SrcBmux(WriteData,ExtImm,32'b0100,0,ALUSrcB,SrcB);

//Alu

alu alu(SrcA, SrcB, ALUControl, ALUResult, ALUFlags);

flopr #(32) Alureg(clk, reset,ALUResult,ALUOut);

flopr #(2) Aluoutregldrb(clk, reset,ALUOut[1:0],ALUldrb);

mux_4 #(32) resultmux(ALUOut,Data,ALUResult,0,ResultSrc,Result);

//ldrb
mux_4 #(8) ldrbmux(Result[7:0],Result[15:8],Result[23:16],Result[31:17],ALUldrb,segldrb);
extend2 ext2(segldrb,rixtm2);

//selec ldrb o ldr

mux2 #(32) newresultmux(Result,rixtm2, B,NewResult);



endmodule 