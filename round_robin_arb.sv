
module round_robin_arb#(parameter num_Agents = 4);

  input logic [num_Agents - 1:0]request;
  input logic [num_Agents - 1:0]grant;
  input clk;
  input rst_n;
  req_priority_size = $clog2(request);
  //grant_priority_size = $clog2(grant);

  wire [req_priority_size -1 :0] current_Priority_Requestor;       //current highest priority given to a requestor
  wire [req_priority_size - 1 :0]next_current_Priority_Requestor;  //next highest priority given to a requestor 

//reset priority on reset 
always@(posedge clk, negedge rst_n)begin 
  if(!rst_n)
    current_Priority_Requestor <= 0;
  else 
    current_Priority_Requestor <= next_current_Priority_Requestor;
end

//Acess grant logic 
always@(*)begin 
  for (i=0; i<num_Agents; i++)begin
    if(req[(current_Priority_Requestor + i)%4) begin 
      grant[(current_Priority_Requestor + i)%4)] = 1;
      next_current_Priority_Requestor = current_Priority_Requestor + 1;
    end
  end 

endmodule