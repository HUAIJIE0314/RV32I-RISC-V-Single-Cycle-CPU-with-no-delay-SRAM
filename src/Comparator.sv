module Comparator(
  rs1_data_i,
  rs2_data_i,
  funct3_i,
  branch_flag_o
);

//---------------------------------------------------------------------
//        PORTS DECLARATION                             
//---------------------------------------------------------------------
input  logic [`DATA_WIDTH-1:0] rs1_data_i;
input  logic [`DATA_WIDTH-1:0] rs2_data_i;
input  logic [2:0]               funct3_i;
output logic                branch_flag_o;

//---------------------------------------------------------------------
//        LOGIC & VARIABLES DECLARATION                            
//---------------------------------------------------------------------
logic signed [`DATA_WIDTH-1:0] rs1_data_signed;
logic signed [`DATA_WIDTH-1:0] rs2_data_signed;
//---------------------------------------------------------------------
//        WIRE CONNECTION                             
//---------------------------------------------------------------------
assign rs1_data_signed = rs1_data_i;
assign rs2_data_signed = rs2_data_i;
//---------------------------------------------------------------------
//        ALWAYS BLOCK                             
//---------------------------------------------------------------------
always_comb begin
  unique case(funct3_i)
    3'd0:begin //BEQ
      branch_flag_o = rs1_data_i == rs2_data_i;
    end
    3'd1:begin //BNE
      branch_flag_o = rs1_data_i != rs2_data_i;
    end
    3'd4:begin //BLT
      branch_flag_o = rs1_data_signed < rs2_data_signed;
    end
    3'd5:begin //BGE
      branch_flag_o = rs1_data_signed >= rs2_data_signed;
    end
    3'd6:begin //BLTU
      branch_flag_o = rs1_data_i < rs2_data_i;
    end
    3'd7:begin //BGEU
      branch_flag_o = rs1_data_i >= rs2_data_i;
    end
    default:branch_flag_o = 1'b0;
  endcase
end


endmodule