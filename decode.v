module decode(input FETCH,
              input EXEC1,
              input EXEC2,
              input EQ,
              input MI,
              input [15:0] IR,
              output EXTRA,
              output Wren,
              output MUX1,
              output MUX3,
              output PC_sload,
              output PC_cnt_en,
              output ACC_EN,
              output ACC_LOAD,
              output ACC_SHIFTIN,
              output ADDSUB,
              output MUX3_useAllBits,
	      output P
);
    // MU0 instruction  
    assign LDA = !IR[15] & !IR[14] & !IR[13] & !IR[12];
    assign STA = !IR[15] & !IR[14] & !IR[13] & IR[12];
    assign ADD = !IR[15] & !IR[14] & IR[13] & !IR[12];
    assign SUB = !IR[15] & !IR[14] & IR[13] & IR[12];
    assign JMP = !IR[15] & IR[14] & !IR[13] & !IR[12];
    assign JMI = !IR[15] & IR[14] & !IR[13] & IR[12];
    assign JEQ = !IR[15] & IR[14] & IR[13] & !IR[12];
    assign STP = !IR[15] & IR[14] & IR[13] & IR[12];
    assign LDI = IR[15] & !IR[14] & !IR[13] & !IR[12];
    assign LSR = IR[15] & !IR[14] & IR[13] & !IR[12];
    assign ASR = IR[15] & !IR[14] & IR[13] & IR[12];
   
    // whether is ARM instruction
    wire ARM = IR[15] & IR[14];
    // ARMish opcode    
    assign arm_ADD = ARM & !IR[6] & !IR[5] & !IR[4];
    assign arm_SUB = ARM & !IR[6] & !IR[5] & IR[4];
    assign arm_MOV = ARM & !IR[6] & IR[5] & !IR[4];
    assign arm_XSR = ARM & !IR[6] & IR[5] & IR[4];

    assign P 		   = LDA | LDI | ADD | SUB | LSR | ASR | JMP | JMI | JEQ;

    assign EXTRA           = LDA & EXEC1 | ADD & EXEC1 | SUB & EXEC1;
    assign Wren            = STA & EXEC1;
    assign MUX1            = LDA & EXEC1 | STA & EXEC1 | ADD & EXEC1 | SUB & EXEC1;
    assign MUX3            = LDA & EXEC2 | LDI & EXEC1;
    assign PC_sload        = JMP & EXEC1 | JMI & EXEC1 & MI | JEQ & EXEC1 & EQ;
    assign PC_cnt_en       = LDA & EXEC2 | STA & EXEC1 | ADD & EXEC2 | SUB & EXEC2 | JMI & EXEC1 & !MI | JEQ & EXEC1 & !EQ | LDI & EXEC1 | LSR & EXEC1 | ASR & EXEC1 | arm_ADD & EXEC1 | arm_SUB & EXEC1 | arm_MOV & EXEC1 | arm_XSR & EXEC1;
    assign ACC_EN          = LDA & EXEC2 | ADD & EXEC2 | SUB & EXEC2 | LDI & EXEC1 | LSR & EXEC1 | ASR & EXEC1;
    assign ACC_LOAD        = LDA & EXEC2 | ADD & EXEC2 | SUB & EXEC2 | LDI & EXEC1;
    assign ADDSUB          = ADD & EXEC2;
    // assign ACC_SHIFTIN     = LSR & EXEC1;
    assign ACC_SHIFTIN     = ASR & EXEC1 & MI;
    // assign ACC_SHIFTIN     = 0;
    assign MUX3_useAllBits = LDA & EXEC2 | LDA & EXEC2 | LSR & EXEC1 | ASR & EXEC1;
    
endmodule
