import params_noc::*;

//Status Buffer verilog code which tells us about the status of the current flit 
module status_Buffer #(parameter BUFFER_SIZE = 8)

(
  input clk,
  input rst_n,
  input read_i,
  input write_i,
  input buf_empty,
  input buf_full,
  input buf_On_Off,
  input flit_Data_noVC input_Data,
  output flit_Data_noVC output_Data,


);

typedef enum logic [1:0] { IDLE, VC, SWITCH } state;
state p_state, nxt_state;

always@(posedge clk, negedge rst_n) begin 
  if(!rst_n)begin
    p_state <= IDLE;
  else 
    p_state <= nxt_state;
end 
    

//Circular Buffer instantiation
circular_Buffer #(.BUFFER_SIZE(BUFFER_SIZE)) cirbuf (.clk(clk), .rst_n(rst_n), .input_Data(input_Data), .output_Data(output_Data), .read_i(read_i), .write_i(write_i),
  .buf_empty(buf_empty), .buf_full(buf_full), .buf_On_Off(buf_On_Off));

//FSM logic 
always@(*) begin 

case(state):

  default: begin 
    end 
  IDLE: begin 
    end 
  VC: begin 
    end 
  SWITCH: begin 
    end 

end

endmodule