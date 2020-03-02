# DECA_5

- [x] ##### Task 1. If you have been working separately from your lab partner choose whichever Lab4 design works best and copy this for both of you. Follow the instructions in Figure 1 to create a new Lab5 project which is a copy of the lab4 work and add the register file and ALU block to the Lab5 project.

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

- [x] ##### Task 2. *Connect the inputs on the* *top* *block.* 

- Connect EXEC1

- Connect instr to IR’

  <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8ev3vckwj31e80u0tj6.jpg" alt="image-20200225015507794" style="zoom:25%;" />

- [x] ##### Task 3. Implement a boolean expression in the Verilog ALU to control write enable of the new registers wenout when used by ARMish instructions. The registers are written in the EXEC1 cycle of every ARMish instruction - but must NOT be written during execution of normal MU0 instructions. Note that there is a separate enable r0wen that is used by the MU0 instructions to write to R0 (which takes the place of Acc).

  ```verilog
assign wenout = exec1 & (&code);
  // &code return 1 iff code[0] and code[1] are both equal to 1
  // wenout only return 1 when excutes ARMish code at EXEC1
  ```

  ![Rc7zEL](https://cdn.jsdelivr.net/gh/Ouikujie/image@master/Mac/Rc7zEL.png)

- [x] ##### Task 4. Use the data path test program from Lab 4 to check that your MU0 instructions still work with the register file taking the place of Acc.

  By comparing its IR/ACC/PC outputs with those from visual2deca, the CPU seems to be fine though a few problems were found. 

  1. Since I haven’t implement the LSR instruction yet, the ACC outputs did not halved.  
  
  <img src="https://tva1.sinaimg.cn/large/0082zybpgy1gc8ez7efmjj31760u0x2w.jpg" alt="Screenshot 2020-02-25 at 01.59.08" style="zoom:33%;" />

- [ ] ##### Task 5. *Note Figure* *8* which is a quick reference allowing you to compose ARMish instructions in hex easily. Test your new ALU instructions, without Carry, using the text code provided.

  

- [ ] ##### Task 6. Implement a boolean expression in the Verilog ALU to control write enable of the new registers wenout when used by ARMish instructions. The registers are written in the EXEC1 cycle of every ARMish instruction.