module alu ( instruction, rddata, rsdata, carrystatus, skipstatus, exec1,
    aluout, carryout, skipout, carryen, skipen, wenout) ;
             
input [15:0] instruction; // from IR'
input exec1;          // timing signal: when things happen
input [15:0] rddata;  // Rd register data outputs
input [15:0] rsdata;  // Rs register data outputs
input carrystatus;    // the Q output from CARRY
input skipstatus;     // the Q output from SKIP

output [15:0] aluout;	// the ALU block output, written into Rd
output carryout;	// the CARRY out, D for CARRY flip flop
output skipout;        	// the SKIP output, D for SKIP flip flop
output carryen;        	// the enable signal for CARRY flip-flop
output skipen;         	// the enable signal for SKIP flip-flop
output wenout;         	// the enable for writing Rd in the register file

// these wires are for convenience to make logic easier to see
wire [2:0] opinstr 	= instruction [6:4];	// OP field from IR'
wire cwinstr 		= instruction [7];	// 1 => write CARRY: CW from IR'
wire [3:0] condinstr 	= instruction [11:8];	// COND field from IR'
wire [1:0] cininstr 	= instruction [13:12];	// CIN field from IR'
wire [1:0] code 	= instruction [15:14];	// bits from IR': must be 11 for ARM instruction

reg [16:0] alusum; 			// the 17 bit sum, 1 extra bit so ALU carry out can be extracted
wire cin; 				// The ALU carry input, determined from instruction as in ISA spec
wire shiftin; 				// value shifted into bit 15 on XSR, determined as in ISA spec

assign alucout 	= alusum [16]; 		// carry bit from sum, or shift if OP = 011
assign aluout 	= alusum [15:0]; 	// 16 normal bits from sum

assign wenout	= exec1 & (&code);	// correct timing, to do: add enable condition
assign carryen	= exec1 & alucout;	// correct timing, to do: add enable condition
assign carryout	= alucout;		// this is correct
                           		// note the special case of rsdata[0] when OP=011
assign cin	= 0;   		     	// dummy, to do: replace with correct logic
assign shiftin 	= 0;     		// dummy, to do: replace with correct logic

assign skipout 	= 0;     		// dummy, to do: replace with correct logic
assign skipen 	= exec1;  		// correct timing, to do: add enable condition

always @(*) // do not change this line - it makes sure we have combinational logic
  begin
    case (opinstr)
      3'b000  : alusum = rddata + rsdata + cin;			// if OP = 000
      3'b001  : alusum = rddata + ~rsdata + cin;		// if OP = 001
      3'b010  : alusum = rsdata + cin;				// if OP = 010
      3'b011  : alusum = {rsdata[0], shiftin, rsdata[15:1]};	// if OP = 011
      // to do (optional): add additional instructions as cases here
      // available cases: 3'b100,3'b101,3'b110, 3'b111
      default : alusum = 0;// default output for unimplemented OP values, do not change
    endcase;
  end

endmodule
