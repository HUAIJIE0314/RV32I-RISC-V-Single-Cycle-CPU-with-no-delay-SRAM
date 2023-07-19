module MUX_8_1 #(parameter WIDTH = 32)(
  in0_i,
  in1_i,
  in2_i,
  in3_i,
  in4_i,
  in5_i,
  in6_i,
  in7_i,
  sel_i,
  out_o
);
//---------------------------------------------------------------------
//        PORTS DECLARATION                             
//---------------------------------------------------------------------
input  logic [WIDTH-1:0] in0_i;
input  logic [WIDTH-1:0] in1_i;
input  logic [WIDTH-1:0] in2_i;
input  logic [WIDTH-1:0] in3_i;
input  logic [WIDTH-1:0] in4_i;
input  logic [WIDTH-1:0] in5_i;
input  logic [WIDTH-1:0] in6_i;
input  logic [WIDTH-1:0] in7_i;
input  logic [2:0]       sel_i;
output logic [WIDTH-1:0] out_o;
//---------------------------------------------------------------------
//        ALWAYS BLOCK                          
//---------------------------------------------------------------------
always_comb begin
  unique case(sel_i)
    3'd0:out_o = in0_i;
    3'd1:out_o = in1_i;
    3'd2:out_o = in2_i;
    3'd3:out_o = in3_i;
    3'd4:out_o = in4_i;
    3'd5:out_o = in5_i;
    3'd6:out_o = in6_i;
    3'd7:out_o = in7_i;
    default:out_o = in0_i;
  endcase
end

endmodule