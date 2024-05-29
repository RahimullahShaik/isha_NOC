`timescale 1ps / 1ps
//tb for route computation unit 
import params_noc::*;

module route_computation_tb();

  parameter x_Current = 3;
  parameter y_Current = 3;
  parameter x_Des_Addr_Size=5;
  parameter y_Des_Addr_Size=5;
  logic [x_Des_Addr_Size-1:0] x_Dest;
  logic [y_Des_Addr_Size-1:0] y_Dest;
  logic [x_Des_Addr_Size-1:0] x_off;
  logic [y_Des_Addr_Size-1:0] y_off;
  inout_Port portout;


route_Computation #(.x_Current(x_Current), .y_Current(y_Current), .x_Des_Addr_Size(x_Des_Addr_Size), .y_Des_Addr_Size(y_Des_Addr_Size)) rc_unit 
  (.x_Dest(x_Dest), .y_Dest(y_Dest), .port(portout));

initial begin 
  x_Dest = 0;
  y_Dest = 0;
  if(x_Dest > x_Current)
    x_off = x_Dest - x_Current;
  else 
    x_off = x_Current - x_Dest;

  if(y_Dest > y_Current)
    y_off = y_Dest - y_Current;
  else 
    y_off = y_Current - y_Dest;

  inc(x_off, y_off);
  #5 $stop;
end

task inc(input signed [x_Des_Addr_Size-1:0] x_off, input signed [y_Des_Addr_Size-1:0] y_off);begin
  $display("xDes and yDes values are %h, %h", x_Dest, y_Dest);
  $display("xoff and yoff values are %h, %h", x_off, y_off);
  repeat(x_off)begin
    #10
    if(check_dest())
    begin
      $display("rc unit failed incorrect x direction");
      return;
     end
     if(x_Dest < x_Current)
       x_Dest =  x_Dest + 1;
     else if(x_Dest > x_Current)
       x_Dest =  x_Dest - 1;
    end

  repeat(y_off)begin 
    #10
    if(check_dest())begin
      $display("rc unit failed incorrect y direction");
      return;
    end

    if(y_Dest < y_Current)
      y_Dest =  y_Dest + 1;
    else if(y_Dest > y_Current)
      y_Dest =  y_Dest - 1;
   end
  end  
endtask

function logic check_dest();
  if(x_Dest < x_Current & portout == WEST)
     check_dest = 0;
  else if(x_Dest > x_Current & portout == EAST)
     check_dest = 0;
  else if(x_Dest == x_Current & y_Dest < y_Current & portout == NORTH)
     check_dest = 0;
  else if(x_Dest == x_Current & y_Dest > y_Current & portout == SOUTH)
      check_dest = 0;
  else if(x_Dest == x_Current & y_Dest == y_Current & portout == LOCAL)
      check_dest = 0;
  else
       check_dest = 1;
  endfunction
endmodule