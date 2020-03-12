# DECA_5

- [x] #### Task 1. If you have been working separately from your lab partner choose whichever Lab4 design works best and copy this for both of you. Follow the instructions in Figure 1 to create a new Lab5 project which is a copy of the lab4 work and add the register file and ALU block to the Lab5 project.

  1. In Quartus open your lab 4 project and archive it: *project* → *archive* will create a *.qar file from the entire project can be reconstructed.

     Generated QAR file from lab4 project. 

     <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8el71d4hj318y0u0nhg.jpg" style="zoom: 25%;" />

  2. Unarchive this file (separately if you want independent copies) to a new Lab5 quartus project in an empty directory. Download the provided block schematic register file and alu regfile.zip. Unzip this into 3 files: regfile.bdf, top.bdf, alu.v, and upload these using mobaXterm to the Lab5 project directory.

     Restored the lab4 project files in lab5 project directory and added files from `regfile`.  Also , initialised a git repo to preserve history of modification. 

     <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8emjvvyzj318y0u07jr.jpg" alt="Screenshot 2020-02-25 at 01.47.02" style="zoom:25%;" />

  3. In Lab5 *Project*→*add/remove files*→add remove files→*add all*. This will add top.bdf, regfile.bdf, alu.v to the project.

     Added all relevant files into project. 

     <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8erhho4oj30ic15sjt0.jpg" alt="image-20200225015153949" style="zoom:25%;" />

  4. Open the top.bdf schematic sheet.

     <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8espst9bj31e80u0gqu.jpg" alt="image-20200225015303819" style="zoom:25%;" />

  5. File*→*create*→*create symbol files for current file*

  6. Open the main MU0 schematic.

  7. Delete your existing LPM_SHIFTREG Acc block.

  8. Add the created symbol from top.bdf, found under *project* in the symbol tool, to your schematic, to the MU0 schematic. Call it (instance property) REGFILE.

  9. Connect R0din, R0q, R0wen to the corresponding busses and signal in your old design where Acc was connected, using connection by name as necessary to keep the schematic readable.

     <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8ew4ad6dj31e80u0wjw.jpg" alt="image-20200225015619760" style="zoom:25%;" />

- [x] #### Task 2. *Connect the inputs on the* *top* *block.* 

- Connect EXEC1

- Connect instr to IR’

  <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8ev3vckwj31e80u0tj6.jpg" alt="image-20200225015507794" style="zoom:25%;" />

- [x] #### Task 3. Implement a boolean expression in the Verilog ALU to control write enable of the new registers wenout when used by ARMish instructions. The registers are written in the EXEC1 cycle of every ARMish instruction - but must NOT be written during execution of normal MU0 instructions. Note that there is a separate enable r0wen that is used by the MU0 instructions to write to R0 (which takes the place of Acc).

  ```verilog
assign wenout = exec1 & (&code);
  // &code return 1 iff code[0] and code[1] are both equal to 1
  // wenout only return 1 when excutes ARMish code at EXEC1
  ```

  ![Rc7zEL](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/Rc7zEL.png)

- [x] #### Task 4. Use the data path test program from Lab 4 to check that your MU0 instructions still work with the register file taking the place of Acc.

  By comparing its IR/ACC/PC outputs with those from visual2deca, the CPU seems to be fine though a few problems were found. 

  1. Since I haven’t implement the LSR instruction yet, the ACC outputs did not halved.  
  
  <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8ez7efmjj31760u0x2w.jpg" alt="Screenshot 2020-02-25 at 01.59.08" style="zoom:33%;" />

- [x] #### Task 5. Note Figure *8* which is a quick reference allowing you to compose ARMish instructions in hex easily. Test your new ALU instructions, without Carry, using the text code provided.

  ```mif
  // mif content
  0 : 8123;
  1 : C028;
  2 : 8111;
  3 : C02C;
  4 : C00E;
  5 : 7000;
  ```

  

  ```verilog
  // whether is ARM instruction
  wire ARM = IR[15] & IR[14];
   // ARMish opcode
  assign arm_ADD = ARM & !IR[6] & !IR[5] & !IR[4];
  assign arm_SUB = ARM & !IR[6] & !IR[5] & IR[4];
  assign arm_MOV = ARM & !IR[6] & IR[5] & !IR[4];
  assign arm_XSR = ARM & !IR[6] & IR[5] & IR[4];
  
  // control for increment in PC value 
  assign PC_cnt_en = LDA & EXEC2 | STA & EXEC1 | ADD & EXEC2 | SUB & EXEC2 | JMI & EXEC1 & !MI | JEQ & EXEC1 & !EQ | LDI & EXEC1 | LSR & EXEC1 | ASR & EXEC1 | arm_ADD & EXEC1 | arm_SUB & EXEC1 | arm_MOV & EXEC1 | arm_XSR & EXEC1;
  ```

  ##### The new ARMish XSR instruction, when used with Rd = Rs = R0, can be used to replace MU0 LSR. Using Figure *7* *and* *9* determine the hex value of the ARMish instruction that will do this?

  According to the instruction: 

  > XSR shifts right (by 1), with bit 0 written into CARRY if S = 1, and cin shifted into bit 15. This combines ARM LSR, ASR, and RRX functionality.

  `LSR` inserts 0 to the `MSB`, so `cin` is 0. 

  ```mif
  1100 | 0000 | 0101 | 0000
  XSR R0,R0 => C030
  ```

  

- [x] #### Task 6.Implement in the Verilog ALU the boolean expressions required to write CARRY as specified by the *S* bit in Figure 7. The necessary signals are:

  - [x] **cin**. The carry in to the ALU adder from **CIN** field.
  
    ```verilog
    assign cin = cininstr[1] ? (cininstr[0] ? rsdata[15] : carryout) : (cininstr[0] ? 1 : 0);
    ```
  
  - [x] **carryen**. Controls writing **CARRY**, derived from **S**, the ARMish opcode bits, and timing info from **EXEC1**.
  
    ```verilog
    assign carryen = exec1 & alucout & cwinstr & (&code);
    // alucout = alusum[16] => carry out from adder
    // exec1 => timing
    // cwinstr => S whether write CARRY
    // code => ARMish Opcode (&code) both bits are high
    ```
  
  - [x] **shiftin**. This determines the MSB of the result in the special case of **XSR**, as in Figure 7. Note that **shiftin** is just **cin** for the specified instructions.
  
    ```verilog
    assign shiftin = cin;
    ```
  
  - [x] **carryout**. To make **CARRY** work properly in right shifts (**XSR**) carryout must equal **rsdata[0]** in **XSR** and ALU cout otherwise. You may wish to use Verilog conditional operator to simplify this: condition ? thenpart : elsepart.
  
    ```verilog
    wire XSR = !opinstr[2] & opinstr[1] & opinstr[0];
    assign carryout	 = XSR ? rsdata[0] : alucout; 
    // if OP=011, then rsdata[0], else alucout
    ```
  
    ###### Test CARRY
    
    ```mif
    0 : 8123;
    1 : C028;
    2 : 8111;
    3 : C02C;
    4 : C00E;
    // testing by adding 0xFFFF and 0x0001
    5 : 0100;	// load 0xFFFF into R0
    6 : C028;	// R2 = R0
    7 : 8001; // load 0x0001 into R0
    8 : C024; // R1 = R0
    9 : C082;	// ADDS R0 := R0 + R2
    a : 7000;
    100 : FFFF;
    ```
    
    ###### Test result
    
    The value of `R0` changed to `0x0000`  and the output of `carryff` changed to `1` at the end, so the result is correct.
    
    <img src="https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/QJ6i7J.png" style="zoom:25%;" />
    
    <img src='https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/87BI4V.png' alt='87BI4V' style="zoom:25%;"/>
    
  - [ ] Which of these four signals are don’t care for MU0 instructions, and outside EXEC1, and which must have defined values at all times?
  
    Only **carryen** needs correct timing. 
  
    
  
    
  
  ![WUxZGR](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/WUxZGR.png)





- [x] #### **Task 7.** Test your ARMish instructions, with **CARRY**, as in lecture 11. Check that you can use the new instructions as suggested in TBL Class 6.
  - [x] ##### Testing ARMish (1) – Data IN/OUT

  ```assembly
  // simple ADD tests
  LDI 0x111						// R0 := 0x111 
  ARM ADD R0 R0				// R0 := R0 + R0 (equiv: Acc := Acc + Acc)
  LDI 0x123						// R0 := 0x123
  ARM MOV R1 R0				// R1 := R0
  LDI 0x234						// R0	:= 0x123
  ARM ADD R1 R0				// R1 := 0x357 (R1 := R1 + R0)
  ARM XSR R2 R1				// R2 := 0x1AB (R2 := R1 LSR 1)
  
  
  LDA 0x100 					// load full 16 bit constant (0xFE22) into R0 
  ARM CMSB XSR R0 R0 	// R0 := 0xFF11 (R0 := R0 ASR 1)
  ARM XSR R0 R0 			// R0 := 0x7F88 (R0 := R0 LSR 1)
  ARM CMSB XSR R0 R0 	// R0 := 0x3FC4 (R0 := R0 ASR 1)
  ORG 0x100
  DCW 0xFE22 					// Constant data loaded by LDA
  ```

  ```assembly
  // mif content
  0 : 8111;
  1 : C000;
  2 : 8123;
  3 : C024;
  4 : 8234;
  5 : C004;
  6 : C039;
  7 : 0100;
  8 : F030;
  9 : C030;
  a : F030;
  b : 7000;
  
  100 : FE22;
  ```

  ###### Test result

  The result is as expected. 

  <img src='https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/AL6qcy.png' alt='AL6qcy' style="zoom:25%;" />

  <img src='https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/InDRq1.png' alt='InDRq1' style="zoom:25%;" />



- [x] #### Task 8. Implement in the ALU logic as detailed in Figure *8* *that writes* *SKIP* to 1 when the next instruction must be skipped, as specified by the *COND* field. *SKIP* should be written only during *EXEC1*, and if *SKIP* is 1 (for an instruction being skipped), it should always be written 0 regardless of *COND.*

  ```verilog
  case (condinstr)
    4'b0000 : skipout = 1'b0     & !skipstatus & arm;
    4'b0001 : skipout = 1'b1     & !skipstatus & arm;
    4'b0010 : skipout = !alucout & !skipstatus & arm;
    4'b0011 : skipout = alucout  & !skipstatus & arm;
    default : skipout = 1'b0     & !skipstatus;
  endcase;
  ```

- [x] #### Task 9. Add logic (a few AND gates) to ensure that when SKIP is high nothing happens:

  - [x] wen and r0wen are 0

    ```verilog
    assign wenout = exec1 & arm & !skipstatus;
    ```

  - [x] PC sload is 0

    ```verilog
    assign PC_sload = JMP & EXEC1 & !skipstatus | JMI & EXEC1 & MI & !skipstatus | JEQ & EXEC1 & EQ & !skipstatus;
    ```

  - [x] RAM wren is 0

    ```verilog
    assign Wren = STA & EXEC1 & !skipstatus;
    ```

  - [x] CARRY cannot change its value.

    ```verilog
    assign carryen = exec1 & cwinstr & arm & !skipstatus;
    ```

- [x] #### Task 10. For instructions with h2 = 0 *SKIP* will always be 0 and have no effect. Using such instructions, and a test program which implements *R0:R1 := R0:R1 + R2:R3* as suggested in the TBL classes to test your new instructions with *CARRY*, *CIN* functionality!

  - [x] ##### Testing ARMish (2) CARRY in ADD/SUB

    ![8ls5Fs](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/8ls5Fs.png)

    The values stored in `r0` and `r2` are changed to `0xFFFF` and changed back to `0x0000` as expected. 
    
    ```verilog
    3'b001 : alusum = {1'b0,rddata} + {1'b0,~rsdata} + cin; // if OP = 001 subtraction
    ```
    
    ```assembly
      // R2:R0 := R2:R0 - R3:R1 - 1
      ARM C0 S SUB R0 R1
      ARM CC SUB R2 R3
      // R2:R0 := R2:R0 + R3:R1 + 1 ARM C1 S ADD R0 R1
      ARM CC ADD R2 R3
    ```
    
    ```assembly
      0 : C091;
      1 : E01B;
      2 : D081;
      3 : E008;
      4 : 7000;
    ```
    
    ![kHS9oj](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/kHS9oj.png)

- [x] #### **Task 11.** Optional. Work out instructions (perhaps based on TBL Class questions) to test *COND* *and* *SKIP*.

  ```verilog
  case (condinstr)
    // self added COND
  	4'b0100 : skipout = !rsdata & !skipstatus & arm; // skip if Rs = 0
  endcase;
  ```

  ```assembly
  LDA 0x101 		# R0 = mem[0x101] (0x1234)
  MOV NV R1 R0	# R1 = R0, skip next instruction
  LDA	0xCCC			# R1 = mem[0xCCC] (would be skipped)
  LDA 0x100			# R0 = mem[0x100] (0x5000)
  
  # <<< start
  ADD C0 AL S R1 R1
  ADD CC CC S R1 R1 # skip if Rs = 0
  JMP 4 # Jump to the start of the loop
  # end >>>
  
  SUB C0 AL	S C0 C1		# C0 := C0 - C1
  SUB CC CC S C2 C3		# C2 := C2 - C3 skip if Cout = 1
  LDI	0x999						# C0 = 0x999
  
  STP
  ```
  
  ```assembly
  0 : 0101;
  1 : C124;
  2 : 0ccc;
  3 : 0100;
  4 : C085;
  5 : E480;
  6 : 4004;
7 : C091;
  8 : D31B;
9 : 8999;
  a : 7000;
  100 : 1234;
  101 : 5000;
  ccc : dddd;
  ```
  
  ![image-20200312010751761](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/image-20200312010751761.png)
  
  ![image-20200312010827798](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/image-20200312010827798.png)
  
  ![image-20200312011604233](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/image-20200312011604233.png)

