module CRS_Unit(
  clk_i,
  rst_i,
  CSRSel_i,
  CSR_OUT_o
);

//---------------------------------------------------------------------
//        PORTS DECLARATION                             
//---------------------------------------------------------------------
input  logic                       clk_i;
input  logic                       rst_i;
input  logic [1:0]              CSRSel_i;
output logic [`DATA_WIDTH-1:0] CSR_OUT_o;
//---------------------------------------------------------------------
//        LOGIC & VARIABLES DECLARATION                            
//---------------------------------------------------------------------
logic [`CSR_WIDTH-1:0]    cycle;
logic [`CSR_WIDTH-1:0]  instret;
//---------------------------------------------------------------------
//        ALWAYS BLOCK                             
//---------------------------------------------------------------------
// << cycle >>
always_ff@(posedge clk_i or posedge rst_i)begin
  if(rst_i)cycle <= {`CSR_WIDTH{1'b0}};
  else begin
    cycle <= cycle + {{`CSR_WIDTH{1'b0}}, 1'b1};
  end
end

// << instret >>
always_ff@(posedge clk_i or posedge rst_i)begin
  if(rst_i)instret <= {`CSR_WIDTH{1'b0}};
  else begin
    instret <= instret + {{`CSR_WIDTH{1'b0}}, 1'b1};
  end
end

always_comb begin
  unique case(CSRSel_i)
    2'd0:CSR_OUT_o = cycle[31:0];
    2'd1:CSR_OUT_o = cycle[63:32];
    2'd2:CSR_OUT_o = instret[31:0];
    2'd3:CSR_OUT_o = instret[63:32];
    default:CSR_OUT_o = {`DATA_WIDTH{1'b0}};
  endcase
end

endmodule