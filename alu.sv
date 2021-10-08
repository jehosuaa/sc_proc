module alu(
	input logic [31:0] A,
	input logic [31:0] B,
	//input logic [1:0] ALUControl,
	input logic [2:0] ALUControl,
	output logic [31:0] ALUResult,
	output logic [3:0] ALUFlags);
	
	logic [31:0] NewB;
	logic cout;
	
	always_comb begin
	
	if(ALUControl[0]==1)
		NewB = ~B;
	else
		NewB = B;
	cout = 0;
	
	case(ALUControl)
		
			3'b000, 3'b001: begin		//suma (00) o resta(01)
				{cout, ALUResult} = {1'b0, A} + {1'b0, NewB} + ALUControl[0];
			end
			
			3'b010: //and
				ALUResult = A & B;
				
			3'b011: //or
				ALUResult = A|B; 
			3'b100: //xor
				ALUResult = A^B; 
			3'b111: //MOV
			ALUResult = B; 
			
				
			default:
				ALUResult = A;				
		endcase
			
	end 
					
	always_comb begin
	
		ALUFlags[3] = ALUResult[31];
		
		if (ALUResult == 0) ALUFlags[2] =1'b1;
		else ALUFlags[2] =1'b0;

		ALUFlags[1] = ~ALUControl[1] & cout;
		
		ALUFlags[0] = ( ~(ALUControl[0] ^ B[31] ^ A[31]) & (A[31] ^ ALUResult[31]) & ~(ALUControl[1]));		
			
	end
endmodule 
