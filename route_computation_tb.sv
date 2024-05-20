`timescale 1ns / 1ps
//tb for route computation unit 
import params_noc::*;
module route_computation_tb#(

  parameter x_Current = 3,
  parameter y_Current = 3,
  parameter x_Des_Addr_Size=5,
  parameter y_Des_Addr_Size=5  );

  logic [x_Des_Addr_Size-1:0] x_Dest;
  logic [y_Des_Addr_Size-1:0] y_Dest;
  inout_Port portout;


route_Computation #(.x_Current(x_Current), .y_Current(y_Current), .x_Des_Addr_Size(x_Des_Addr_Size), .y_Des_Addr_Size(y_Des_Addr_Size)) rc_unit 
  (.x_Dest(x_Dest), .y_Dest(y_Dest), .port(portout));

initial begin 

  x_Dest <= 5;
  y_Dest <= 5;
  repeat(2)begin 
    $display("xDes and yDes values are %h, %h", x_Dest, y_Dest);
    increment(x_Dest, y_Dest);
  end 

  //$display("x_current, y_current, port are %x,%x,%x", x_Current, y_Current, portout);
  //x_Current = x_Current + 1;
  //y_Current = y_Current +1;
end

  function automatic increment(ref logic [x_Des_Addr_Size-1:0] x_Dest, ref logic [y_Des_Addr_Size-1:0] y_Dest);
  begin 
    $display("xDes and yDes inside the function values are %h, %h", x_Dest, y_Dest);
    if(x_Dest < x_Current)
      x_Dest =  x_Dest + 1;
    else if(x_Dest > x_Current)
      x_Dest =  x_Dest - 1;
  
    if(y_Dest < y_Current)
      y_Dest =  y_Dest + 1;
    else if(y_Dest > y_Current)
      y_Dest =  y_Dest - 1;
  
  end  
  endfunction

endmodule