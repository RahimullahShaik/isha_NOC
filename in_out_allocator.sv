import params_noc::*;
module in_out_allocator#(parameter vc_Num = 4, port_Num = 5)(

  input logic [port_Num-1][vc_Num-1:0]request_in;         //input requests at each port
  input clk;
  input rst_n;
  input inout_Port [vc_Num-1:0] inports_Out[port_Num-1];  //taking an unpacked array inorder to index into outrequest to provide it to the second stage 
  output logic [port_Num-1][vc_Num-1:0]grant_o;           //output grant at each port 
);

    logic [PORT_NUM-1:0][PORT_NUM-1:0] out_request;       //input to the second stage 
    logic [PORT_NUM-1:0][PORT_NUM-1:0] ip_grant;          //output of the second stage 
    logic [PORT_NUM-1:0][VC_NUM-1:0] vc_grant;            //output of the first stage 

genvar i;
generate 
  //generate round robin arbitar at each input port, this is the first stage where we perform rr operation at each input port to select a VC which wins the arbitration 
	for(i=0; i<port_Num; i++)
	begin
		round_robin_arb #parameter(.num_Agents(vc_Num)) rrb (.request(request_in[i]), .grant(vc_grant[i]), .clk(clk), .rst_n(rst_n));
	end
endgenerate

genvar j;
generate
  //generate round robin arbitar at each output port, this is the second stage where we perform rr operation at each output to get the winner of which Input ports VC can
  //send the transaction to this output port 
	for(j=0; j<port_Num; j++)
	begin 
		round_robin_arb #parameter(.num_Agents(vc_Num)) rrb (.request(out_request[i]), .grant(ip_grant[i]), .clk(clk), .rst_n(rst_n));
	end 
endgenerate

always_comb begin : stages_block

out_request = 1'b0;
grant_o = 1'b0;

//We are computing an array out_request such that at each output port we get the respective input ports which have an active transaction in their VC's 
for(port =0; port<port_Num; port++) begin 
  for(vc = 0; vc <vc_Num; vc++) begin 
    if(vc_grant[port][vc] == 1)begin 
      out_request[inports_Out[port][vc]][port] == 1;
      break;
    end
  end
end
      
  
end

endmodule
