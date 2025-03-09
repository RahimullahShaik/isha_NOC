import params_noc::*;
module in_out_allocator#(parameter vc_Num = 4)(

  input [in_Port_Cnt-1:0][vc_Num-1:0]request_in,         //input requests at each port
  input clk,
  input rst_n,
  input inout_Port [vc_Num-1:0] inports_Out[in_Port_Cnt-1:0],  //taking an unpacked array inorder to index into outrequest to provide it to the second stage 
  output logic [in_Port_Cnt-1:0][vc_Num-1:0]grant_o           //output grant at each port 
);

    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] out_request;       //input to the second stage 
    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] ip_grant;          //output of the second stage 
    logic [in_Port_Cnt-1:0][vc_Num-1:0] vc_grant;            //output of the first stage 

genvar i;
generate 
  //generate round robin arbitar at each input port, this is the first stage where we perform rr operation at each input port to select a VC which wins the arbitration 
	for(i=0; i<in_Port_Cnt; i++)
    begin
      round_robin_arb #(.num_Agents(vc_Num)) rrb (.request(request_in[i]), .grant(vc_grant[i]), .clk(clk), .rst_n(rst_n));
    end
endgenerate

genvar j;
generate
  //generate round robin arbitar at each output port, this is the second stage where we perform rr operation at each output to get the winner of which Input ports VC can
  //send the transaction to this output port 
	for(j=0; j<in_Port_Cnt; j++)
    begin 
      round_robin_arb #(.num_Agents(in_Port_Cnt)) rrb (.request(out_request[j]), .grant(ip_grant[j]), .clk(clk), .rst_n(rst_n));
    end 
endgenerate

always_comb 
begin
  out_request = 1'b0;
  grant_o = 1'b0;

  //We are computing an array out_request such that at each output port we get the respective input ports which have an active transaction in their VC's `
  for(int port =0; port<in_Port_Cnt; port++) begin 
    for(int vc = 0; vc <vc_Num; vc++) begin 
      if(vc_grant[port][vc] == 1)begin 
        out_request[inports_Out[port][vc]][port] = 1;
        break;
      end
    end
  end
  // At each output port, we iterate through all the input ports and for each input port we iterate through all the virtual channels and
  //whenever we have an active winning transaction in a virtual channel for a respective input port we set the bit to 1     
  for(int out_p=0; out_p <in_Port_Cnt; out_p++) begin
    for(int in_p=0; in_p<in_Port_Cnt; in_p++) begin
      for(int vc=0; vc<vc_Num; vc++) begin
        if(ip_grant[out_p][in_p] & vc_grant[in_p][vc])begin
          grant_o[in_p][vc] = 1'b1;
          break;
        end
      end
    end
  end
end 

endmodule
