//verilog code for route computational unit which gives us the route that is the direction of the next hop for the flit 
import params_noc::*;
module route_Computation #(
	parameter x_Current,
	parameter y_Current,
	parameter x_Des_Addr_Size,
	parameter y_Des_Addr_Size)

( input logic [x_Des_Addr_Size-1:0] x_Des,
  input logic [y_Des_Addr_Size-1:0] y_Des,
  output inout_Port port );

  wire [x_Des_Addr_Size-1:0]x_Offset;
  wire [y_Des_Addr_Size-1:0]y_Offset;

  assign x_Offset =  x_Des - x_Current;
  assign y_Offset =  y_Des - y_Current;

always_comb begin 

  //unique if is used as it gives out error if there are multiple matches 
  //the following logic tells us the direction of the next hop
  unique if(x_Offset < 0)
    port = WEST;
  else if(x_Offset > 0)
    port = EAST;
  else if(x_Offset ==0 & y_Offset <0)
    port = NORTH;
  else if(x_Offset ==0 & y_Offset >0)
    port = SOUTH;
  else 
    port = LOCAL;
    
end 

endmodule 
