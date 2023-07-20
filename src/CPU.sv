`include "define.svh"
`include "Program_Counter.sv"
`include "Register_File.sv"
`include "MUX_2_1.sv"
`include "MUX_4_1.sv"
`include "Controller.sv"
`include "ALU_Controller.sv"
`include "ALU.sv"
`include "Imm_Gen.sv"
`include "CSR_Unit.sv"
`include "Comparator.sv"
`include "alignment_Correction.sv"
`include "LoadData_Mask.sv"

module CPU(
  clk,     
  rst,   
  IM_A,  
  IM_DO, 
  DM_OE, 
  DM_A,  
  DM_DO, 
  DM_WEB,
  DM_DI 
);
//---------------------------------------------------------------------
//        PORTS DECLARATION                             
//---------------------------------------------------------------------
input  logic                           clk;  
input  logic                           rst;
output logic [$clog2(`IM_DEPTH)-1:0]  IM_A;
input  logic [`DATA_WIDTH-1:0]       IM_DO;
output logic                         DM_OE;
output logic [$clog2(`DM_DEPTH)-1:0]  DM_A;
input  logic [`DATA_WIDTH-1:0]       DM_DO;
output logic [3:0]                  DM_WEB;
output logic [`DATA_WIDTH-1:0]       DM_DI;

//---------------------------------------------------------------------
//        LOGIC & VARIABLES DECLARATION                            
//---------------------------------------------------------------------
// << Program_Counter >>
logic        [`PC_WIDTH-1:0]    PC_Present;
logic        [`PC_WIDTH-1:0]       PC_next;

// << about instruction >>
logic        [`DATA_WIDTH-1:0] instruction;
logic        [6:0]                  funct7;
logic        [4:0]                rs2_addr;
logic        [4:0]                rs1_addr;
logic        [2:0]                  funct3;
logic        [4:0]                 rd_addr;
logic        [`OP_WIDTH-1:0]        opcode;

// << Controller >>
logic                             RegWrite;
logic                               rs2Sel;
logic        [1:0]                 rdPCSel;
logic        [3:0]                MemWrite;
logic        [1:0]                MemtoReg;
logic                              MemRead;
logic                               Branch;
logic                                  Jal;
logic                                 Jalr;
logic        [1:0]                   ALUop;

// << ALU & ALU Controller >>
logic        [`DATA_WIDTH-1:0]     ALUsrcA;
logic        [`DATA_WIDTH-1:0]     ALUsrcB;
logic        [`DATA_WIDTH-1:0]   ALUresult;
logic        [2:0]                 ALUctrl;
logic                              ALUSign;

// << CSR >>
logic        [`DATA_WIDTH-1:0]     CSR_OUT;

// << Register_File >>
logic        [`DATA_WIDTH-1:0]     rd_data;
logic        [`DATA_WIDTH-1:0]    rs1_data;
logic        [`DATA_WIDTH-1:0]    rs2_data;

// << Imm_Gen >>
logic        [`DATA_WIDTH-1:0]     imm_out;

// << for branch >>
logic        [`DATA_WIDTH-1:0]    PC_plus4;
logic        [`DATA_WIDTH-1:0]  PC_plusImm;
logic        [`DATA_WIDTH-1:0]  PC4orPCimm;
logic        [`DATA_WIDTH-1:0]  immPlusRs1;

// << Comparator >>
logic                          branch_flag;

// << rdPC target >>
logic        [`DATA_WIDTH-1:0]        rdPC;

// << LoadData_Mask >>
logic        [`DATA_WIDTH-1:0]    LoadData;

// << MUX selection >>
logic        [1:0]                  CSRSel;


//---------------------------------------------------------------------
//        WIRE CONNECTION                             
//---------------------------------------------------------------------
// << SRAM ports >>
assign DM_OE = MemRead;//1'b1;
assign IM_A  = PC_Present[15:2];

// << instruction >>
assign instruction = IM_DO;//IM data out
assign funct7      = instruction[`funct7_RANGE];
assign rs2_addr    = instruction[`rs2_RANGE   ];
assign rs1_addr    = instruction[`rs1_RANGE   ];
assign funct3      = instruction[`funct3_RANGE];
assign rd_addr     = instruction[`rd_RANGE    ];
assign opcode      = instruction[`OP_RANGE    ];

// << for MUX selection >>
assign CSRSel   = {instruction[21], instruction[27]};
assign LoadSel  = funct3;     // 2:LW, 0:LB, 1:LH, 4:LHU, 5:LBU

// << branch target >>
assign PC_plus4       = PC_Present + 4;//PC_Present
assign PC_plusImm     = PC_Present + imm_out;//PC_Present
assign immPlusRs1     = rs1_data   + imm_out;
//---------------------------------------------------------------------
//        MODULE INSTANTIATION                             
//---------------------------------------------------------------------

// << Program_Counter >>
Program_Counter PC(
  .clk_i       (clk       ),
  .rst_i       (rst       ),
  .PC_Present_i(PC_next   ),
  .PC_next_o   (PC_Present)
);

// << Register_File >>
Register_File RF(
  .clk_i     (clk     ),
  .rst_i     (rst     ),
  .rs1_addr_i(rs1_addr),
  .rs2_addr_i(rs2_addr),
  .rd_addr_i (rd_addr ),
  .rd_data_i (rd_data ),
  .RegWrite_i(RegWrite),
  .rs1_data_o(rs1_data),
  .rs2_data_o(rs2_data)
);

// << Imm_Gen >>
Imm_Gen Imm_Gen(
  .instr_i  (instruction),
  .imm_out_o(imm_out    )
);

// << ALU_Controller >>
ALU_Controller ALU_Controller(
  .funct7_6_i(funct7[5]),
  .funct3_i  (funct3   ),
  .ALUop_i   (ALUop    ),
  .ALUctrl_o (ALUctrl  ),
  .sign_o    (ALUSign  )
);

// << ALU >>
assign ALUsrcA = rs1_data;
ALU ALU(
  .srcA_i     (ALUsrcA  ),
  .srcB_i     (ALUsrcB  ),
  .ALUctrl_i  (ALUctrl  ),
  .sign_i     (ALUSign  ),
  .ALUresult_o(ALUresult)
);

// << ALUsrcB selection >>
MUX_2_1 #(.WIDTH(32)) MUX_2_1_ALUsrcB (
  .in0_i(rs2_data),
  .in1_i(imm_out ),
  .sel_i(rs2Sel  ),
  .out_o(ALUsrcB )
);

// << Comparator >>
Comparator Comparator(
  .rs1_data_i   (rs1_data   ),
  .rs2_data_i   (rs2_data   ),
  .funct3_i     (funct3     ),
  .branch_flag_o(branch_flag)
);

// << Controller >>
Controller controller(
  .opcode_i  (opcode  ),
  .funct3_i  (funct3  ),
  .RegWrite_o(RegWrite),
  .rs2Sel_o  (rs2Sel  ),
  .rdPCSel_o (rdPCSel ),
  .MemWrite_o(MemWrite),
  .MemtoReg_o(MemtoReg),
  .MemRead_o (MemRead ),
  .Branch_o  (Branch  ),
  .Jal_o     (Jal     ),
  .Jalr_o    (Jalr    ),
  .ALUop_o   (ALUop   )
);

// << CRS_Unit >>
CRS_Unit CRS_Unit(
  .clk_i    (clk    ),
  .rst_i    (rst    ),
  .CSRSel_i (CSRSel ),
  .CSR_OUT_o(CSR_OUT)
);

// << rdPCSel >>
MUX_4_1 #(.WIDTH(32)) MUX_4_1_rdPCSel (
  .in0_i(PC_plus4  ),
  .in1_i(PC_plusImm),//PC_Present_dly_dly + imm_out_dly
  .in2_i(imm_out   ),
  .in3_i(32'd0     ),
  .sel_i(rdPCSel   ),
  .out_o(rdPC      )
);

// << Memory to Register >>
MUX_4_1 #(.WIDTH(32)) MUX_4_1_MemtoReg (
  .in0_i(ALUresult),
  .in1_i(rdPC     ),
  .in2_i(LoadData ),
  .in3_i(CSR_OUT  ),
  .sel_i(MemtoReg ),
  .out_o(rd_data  )
);

LoadData_Mask LoadData_Mask(
  .LoadData_i(DM_DO   ),
  .funct3_i  (funct3  ),
  .LoadData_o(LoadData)
);

// << PC Branch >>
MUX_2_1 #(.WIDTH(32)) MUX_2_1_PC4orPCimm (
  .in0_i(PC_plus4  ),
  .in1_i(PC_plusImm),
  .sel_i((Branch&branch_flag)|Jal),
  .out_o(PC4orPCimm)
);

MUX_2_1 #(.WIDTH(32)) MUX_2_1_PC_next (
  .in0_i(PC4orPCimm),
  .in1_i(immPlusRs1),
  .sel_i(Jalr      ),
  .out_o(PC_next   )
);

// << alignment_Correction >>

assign DM_A = ALUresult[15:2];

alignment_Correction alignment_Correction(
  .DM_A_2b_i(ALUresult[1:0]),
  .DM_WEB_i (MemWrite      ),
  .DM_DI_i  (rs2_data      ),            
  .DM_WEB_o (DM_WEB        ),
  .DM_DI_o  (DM_DI         )
);


endmodule

