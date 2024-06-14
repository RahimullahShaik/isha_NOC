module round_Robin_tb #(parameter Num_Agents = 4);
  logic clk;
  logic rst_n;
  logic [Num_Agents-1:0] requests;
  logic [Num_Agents-1:0] grants;

round_robin_arb #(.num_Agents(Num_Agents)) rra (.clk(clk), .rst_n(rst_n), .requests(request), .grants(grant));

always begin 
  #1 clk = ~clk;
end

initial begin 
  clk = 1'b0;
  rst_n = 1'b1;
end 


endmodule 