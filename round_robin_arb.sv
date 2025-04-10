
module round_robin_arb#(parameter num_Agents = 4)
(
  input [num_Agents-1:0]request,
  output logic [num_Agents-1:0]grant,
  input clk,
  input rst_n
);
  localparam[31:0] req_priority_size = $clog2(num_Agents);
  //grant_priority_size = $clog2(grant);
 
  logic [req_priority_size-1:0] current_Priority_Requestor;       //current highest priority given to a requestor
  logic [req_priority_size-1:0]next_current_Priority_Requestor;  //next highest priority given to a requestor 
  logic starvation;

  logic [num_Agents - 1 :0] Starv_count[num_Agents - 1 :0]; //4 bit starvation counter for each requestor 
  localparam starvation_Threshold = 1;
//reset priority on reset 
always@(posedge clk, negedge rst_n)begin 
  if(!rst_n)
    current_Priority_Requestor <= 0;
  else 
    current_Priority_Requestor <= next_current_Priority_Requestor;
end

//starvation logic 
always@(posedge clk, negedge rst_n) begin 
  for(int i=0; i<num_Agents; i++) begin 
    if(!rst_n) 
      Starv_count[i] <= 4'b0;
    else 
      if(request[i] & !grant[i]) begin 
        Starv_count[i] <= Starv_count[i] + 1;		//incrementing the counter when access is not granted 
      end
      else 
        Starv_count[i] <= 1'b0; //we need to reset the counter if access has been granted 
    end
end 
	
always@(posedge clk, negedge rst_n) begin 
  if(!rst_n) 
    starvation <= 1'b0;
  else 
    for(int i=0; i<num_Agents; i++) begin 
      if(Starv_count[i] > starvation_Threshold) begin 
        starvation <= 1'b1; 	//setting the starvation bit if starvation count is greater than the threshold for a requestor
      end
      else 
	starvation <= 1'b0;
    end
end
//Acess grant logic 
always_comb begin 
  grant = {num_Agents{1'b0}}; //resetting the requestor grant priority 
  next_current_Priority_Requestor = current_Priority_Requestor; //resetting next current priority
  for (int i=0; i<num_Agents; i++) begin
    if(request[(current_Priority_Requestor + i)%num_Agents]) begin 
      grant[(current_Priority_Requestor + i)%num_Agents] = 1'b1;
      next_current_Priority_Requestor = ((current_Priority_Requestor + i+ 1)%num_Agents);
      break; //grant only to the first priority requestor 
    end
  end 
end

endmodule