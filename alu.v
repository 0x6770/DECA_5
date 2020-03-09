module alu (instruction,
            rddata,
            rsdata,
            carrystatus,
            skipstatus,
            exec1,
            aluout,
            carryout,
            skipout,
            carryen,
            skipen,
            wenout);
    
    input [15:0] instruction; // from IR'
    input exec1;              // timing signal: when things happen
    input [15:0] rddata;      // Rd register data outputs
    input [15:0] rsdata;      // Rs register data outputs
    input carrystatus;        // the Q output from CARRY
    input skipstatus;         // the Q output from SKIP
    
    output [15:0] aluout; //  the ALU block output, written into Rd
    output carryout;      //  the CARRY out, D for CARRY flip flop
    output skipout;       //  the SKIP output, D for SKIP flip flop
    output carryen;       //  the enable signal for CARRY flip-flop
    output skipen;        //  the enable signal for SKIP flip-flop
    output wenout;        //  the enable for writing Rd in the register file
    
    // these wires are for convenience to make logic easier to see
    wire [2:0] opinstr   = instruction [6:4];	// OP field from IR'
    wire cwinstr         = instruction [7];	// 1 = > write CARRY: CW from IR'
    wire [3:0] condinstr = instruction [11:8];	// COND field from IR'
    wire [1:0] cininstr  = instruction [13:12];	// CIN field from IR'
    wire [1:0] code      = instruction [15:14];	// bits from IR': must be 11 for ARM instruction
    
    wire arm = &code;
    wire XSR = !opinstr[2] & opinstr[1] & opinstr[0];
    
    reg [16:0] alusum; //  the 17 bit sum, 1 extra bit so ALU carry out can be extracted
    wire cin;          //  The ALU carry input, determined from instruction as in ISA spec
    wire shiftin;      //  value shifted into bit 15 on XSR, determined as in ISA spec
    wire alucout;
    reg skipout;
//    wire skipout;
    
    assign alucout 	 = alusum [16];   //  carry bit from sum, or shift if OP = 011
    assign aluout 	 = alusum [15:0]; //  16 normal bits from sum
    
    assign wenout	 = exec1 & arm & !skipstatus;                        //  correct timing, to do: add enable condition
    assign carryen	 = exec1 & cwinstr & arm & !skipstatus;              //  correct timing, to do: add enable condition
    assign carryout	 = arm & (XSR ? rsdata[0] : alucout);  //  this is correct
                                                               //  note the special case of rsdata[0] when OP = 011
    assign cin	 = cininstr[1] ? (cininstr[0] ? rsdata[15] : carrystatus) : (cininstr[0] ? 1 : 0);   		     	//* DONE dummy, to do: replace with correct logic
    assign shiftin 	 = cin;     		// dummy, to do: replace with correct logic
    
//    assign skipout 	 = 0;     		// dummy, to do: replace with correct logic
    assign skipen 	 = exec1;  		// correct timing, to do: add enable condition
    
//    assign skipout = condinstr[3] ? condinstr[2] ? condinstr[1] ? condinstr[0] ? 0 
//    									       : 0 
//    								: condinstr[0] ? 0
//									       : 0 
//    						 : condinstr[1] ? condinstr[0] ? 0 
//    									       : 0 
//    								: condinstr[0] ? 0
//									       : 0 
//    				  : condinstr[2] ? condinstr[1] ? condinstr[0] ? 0 
//    									       : 0 
//    								: condinstr[0] ? 0
//									       : 0 
//    						 : condinstr[1] ? condinstr[0] ? alucout  & !skipstatus & arm
//    									       : !alucout & !skipstatus & arm
//    								: condinstr[0] ? 1        & !skipstatus & arm
//									       : 0        & !skipstatus & arm;
 

    always @(*) // do not change this line -it makes sure we have combinational logic
    begin
       case (condinstr)
            4'b0000 : skipout = 1'b0     & !skipstatus & arm;
            4'b0001 : skipout = 1'b1     & !skipstatus & arm;
            4'b0010 : skipout = !alucout & !skipstatus & arm;
            4'b0011 : skipout = alucout  & !skipstatus & arm;
            4'b0100 : skipout = !rsdata  & !skipstatus & arm;
            default : skipout = 1'b0     & !skipstatus;
    	endcase;
    end
    always @(*) // do not change this line -it makes sure we have combinational logic
    begin
        case (opinstr)
            // alusum is 17 bit so we must extend the two operands to 17 bits using 0
            // otherwise Verilog default extension will sign-extend these inputs
            // that create a subtle (not always obvious) error in carry out
            // note that ~ is bit inversion operator.
            3'b000 : alusum = {1'b0,rddata} + {1'b0,rsdata} + cin; // if OP = 000
            3'b001 : alusum = {1'b0,rddata} + {1'b0,~rsdata} + cin; // if OP = 001
            3'b010 : alusum = {1'b0,rsdata} + cin; // if OP = 010
            3'b011 : alusum = {rsdata[0], shiftin, rsdata[15:1]}; // if OP = 011
            // to do (optional): add additional instructions as cases here
            // available cases: 3'b100,3'b101,3'b110, 3'b111
            default : alusum = 0;// default output for unimplemented OP values, do not change
    	endcase;
    end

endmodule
