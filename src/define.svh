`ifndef define_sv
`define define_sv

//---------------------------------------------------------------------
//        Bit Width             
//---------------------------------------------------------------------
`define DATA_WIDTH    32
`define REG_DEPTH     32
`define PC_WIDTH      32
`define DM_DEPTH      16384
`define IM_DEPTH      16384
`define CSR_WIDTH     64
//---------------------------------------------------------------------
//        Instruction             
//---------------------------------------------------------------------
`define funct7_RANGE 31:25
`define rs2_RANGE    24:20
`define rs1_RANGE    19:15
`define funct3_RANGE 14:12
`define rd_RANGE     11:7
`define OP_RANGE	   6:2
`define OP_WIDTH	   5

// << opcode >>
// << R-type >>
`define RTYPE 5'b01100 // 11
// << I-type >>
`define ITYPE 5'b00100 // 11
`define JALR  5'b11001 // 11
`define LOAD  5'b00000 // 11
// << S-type >>
`define STYPE	5'b01000 // 11
// << B-type >>
`define BTYPE	5'b11000 // 11
// << U-type >>
`define AUIPC 5'b00101 // 11
`define LUI   5'b01101 // 11
// << J-type >> // JAL
`define JTYPE 5'b11011 // 11
// << CSR >>
`define CSR   5'b11100 // 11

//---------------------------------------------------------------------
//        ALU Operations             
//---------------------------------------------------------------------
`define ADD       3'd0 // rd = rs1 + rs2
`define SUB       3'd1 // rd = rs1 - rs2
`define SLL       3'd2 // rd = rs1s << rs2[4:0]
`define SLT_SLTU  3'd3 // rd = (rs1s < rs2s)? 1:0 / rd = (rs1u < rs2u)? 1:0
`define XOR       3'd4 // rd = rs1 ^ rs2
`define SRL_SRA   3'd5 // rd = rs1u >> rs2[4:0] / rd = rs1s >> rs2[4:0]
`define OR        3'd6 // rd = rs1 | rs2
`define AND       3'd7 // rd = rs1 & rs2



`endif
