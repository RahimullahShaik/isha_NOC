import params_noc::*;
module in_out_allocator#(parameter vc_Num = 4, port_Num = 5)(

  input logic [port_Num-1][vc_Num-1:0]request_in;
  input clk;
  input rst_n;
  input inout_Port [vc_Num-1:0] inports_Output[port_Num-1];
  output logic [port_Num-1][vc_Num-1:0]grant_o;
);

    logic [PORT_NUM-1:0][PORT_NUM-1:0] out_request;
    logic [PORT_NUM-1:0][PORT_NUM-1:0] ip_grant;
    logic [PORT_NUM-1:0][VC_NUM-1:0] vc_grant;

genvar i;
generate 
	for(i=0; i<port_Num; i++)
	begin
		round_robin_arb #parameter(.num_Agents(vc_Num)) rrb (.request(request_in[i]), .grant(grant_o[i]), .clk(clk), .rst_n(rst_n));
	end
endgenerate

genvar j;
generate
	for(j=0; j<port_Num; j++)
	begin 
		round_robin_arb #parameter(.num_Agents(vc_Num)) rrb (.request(out_request[i]), .grant(ip_grant[i]), .clk(clk), .rst_n(rst_n));
	end 
endgenerate
endmodule
