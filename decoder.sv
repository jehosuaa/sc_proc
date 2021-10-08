module decoder(input logic clk, reset,
	input logic [1:0] Op,
	input logic [5:0] Funct,
	input logic [3:0] Rd,
	output logic [1:0] FlagW,
	output logic PCS, NextPC, RegW, MemW,
	output logic IRWrite, AdrSrc,
	output logic [1:0] ResultSrc,
	output logic ALUSrcA,
	output logic [1:0] ALUSrcB, ImmSrc, RegSrc,
	output logic [2:0] ALUControl,
	output logic B);
	
logic [11:0] controls;
logic [3:0] Srcs;
logic Branch, ALUOp;

typedef enum logic [3:0] {S0,S1,S2,S3,S4,S5,S6,S7,S8,S9} State;

State currentState, nextState;


//Instr Decoder
always_comb
	begin
	
	casex(Op) 
		2'b01: begin 
			if (Funct[0]) begin 
			Srcs = 4'b0001;
			//B=Funct[2];
			end 
		else Srcs = 4'b1001;
		end
		
			
		2'b00: if (Funct[5]) Srcs = 4'bx000;
		else Srcs = 4'b0000;
		
		2'b10: Srcs = 4'bx110;
		
		default: Srcs = 4'bx;
	endcase
	end
	
assign {RegSrc, ImmSrc} = Srcs;

always_ff @(posedge reset, posedge clk) begin
	if (reset)
		currentState <= S0;
	else
		currentState <= nextState;
	end

// Main FSM
always_comb begin
	case(currentState)
	
	S0: begin	//fetch
		nextState <= S1;
	end
	
	S1: begin	//decode
		if (Op == 2'b00) begin
			if (Funct[5]) 	
				nextState <= S7;	//ExecuteL
			else 
				nextState <= S6;	//ExecuteR
			end
		else if (Op == 2'b01)
			nextState <= S2;	//MemAdr
		else if (Op == 2'b10)
			nextState <= S9;	//Branch
		else
			nextState <= S0;	//Reset
		end
	S2: begin	//MemAdr
		if (Funct[0])
			nextState <= S3;	//MemRead
		else
			nextState <= S5;	//MemWrite
		end
	S3: begin	//MemRead
		nextState <= S4;
	end
	S4: begin	//MemWB
		nextState <= S0;
	end
	S5: begin	//MemWrite
		nextState <= S0;
	end
	S6: begin	//ExecuteR
		nextState <= S8;
	end
	S7: begin	//ExecuteL
		nextState <= S8;
	end
	S8: begin	//ALUWB
		nextState <= S0;
	end
	S9: begin	//Branch
		nextState <= S0;
	end
	default: nextState <= S0;
	endcase
	end

always_comb begin
	B=0;
	casex(currentState)
		S0: begin
			controls = 12'b100010101100;
		end
		S1: begin
			controls = 12'b00000x101100;			
		end
		S2: begin
			controls = 12'b00000xxx0010;
		end
		S3: begin
			controls = 12'bx0000100xxxx;
		end
		S4: begin
			controls = 12'bx0010x01xxxx;
			B=Funct[2];
		end
		S5: begin
			controls = 12'bx0100100xxxx;
		end
		S6: begin
			controls = 12'bx0000xxx0001;
		end
		S7: begin
			controls = 12'bx0000xxx0011;
		end
		S8: begin
			if(Funct[4:1]!=4'b1010)controls = 12'bx0010x00xxxx;
			else controls = 12'bx0000x00xxxx;
		end
		S9: begin
			controls = 12'bx1000x100010;
		end
	endcase
end
	
assign {NextPC, Branch, MemW, RegW, IRWrite, AdrSrc, ResultSrc,

	ALUSrcA, ALUSrcB, ALUOp} = controls;
	
// ALU Decoder
always_comb
if (ALUOp) begin // which DP Instr?
	casex(Funct[4:1])
		4'b0100: ALUControl = 3'b000; // ADD
		4'b0010: ALUControl = 3'b001; // SUB
		4'b0000: ALUControl = 3'b010; // AND
		4'b1100: ALUControl = 3'b011; // ORR
		4'b0001: ALUControl = 3'b100; // xOR
		4'b1101: ALUControl = 3'b111; // MOV
		4'b1010: ALUControl = 3'b001; // CMP
		default: ALUControl = 3'bx; // unimplemented
	endcase
// update flags if S bit is set (C & V only for arith)
	FlagW[1] = Funct[0];
	FlagW[0] = Funct[0] &
	(ALUControl == 3'b000 | ALUControl == 3'b001);
end 
else begin
	ALUControl = 3'b000; // add for non-DP instructions
	FlagW = 2'b00; // don't update Flags
end

// PC Logic
assign PCS = ((Rd == 4'b1111) & RegW) | Branch;

endmodule
