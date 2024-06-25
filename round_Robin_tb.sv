`timescale 1ps/1ps
module round_Robin_tb #(parameter Num_Agents = 4);
  logic clk;
  logic rst_n;
  logic [Num_Agents-1:0] requests;
  logic [Num_Agents-1:0] grants;
  localparam [7:0] Priority_Size = $clog2(Num_Agents);
  logic [Priority_Size-1:0] current_Priority_Requestor;

round_robin_arb #(.num_Agents(Num_Agents)) rra (.clk(clk), .rst_n(rst_n), .request(requests), .grant(grants));

always begin 
  #1 clk = ~clk;
end

initial begin 
  clk = 1'b0;
  rst_n = 1'b0;
  //single requestor
  requests = 4'b0001;
  @(posedge clk);
  rst_n = 1'b1;
  @(posedge clk);
  requests = 4'b1000;
  @(posedge clk);
  requests = 4'b0010;
  @(posedge clk);

  //multiple requestors
  requests = 4'b 1101;
  @(posedge clk);
  requests = 4'b 1111;
  @(posedge clk);
  requests = 4'b 1010;
  @(posedge clk);
  requests = 4'b 1011;
  repeat(4)@(posedge clk);
  $stop();
end 


endmodule 