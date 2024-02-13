
//include "struct_param.sv";
import struct_param::*;

module struct_test #(parameter BUFFER_SIZE = 8);

 flit_Data_noVC new_Flit;
int op_Num;

initial begin 
  createflit();
  op_Num = 1;
end

  task createflit();
    new_Flit.flit_DataLabel                    <= HEAD;
    new_Flit.data.head_Data.x_Dest          <= {x_Des{op_Num}};
    new_Flit.data.head_Data.y_Dest          <= {y_Des{op_Num}};
    new_Flit.data.head_Data.head_Payload    <= {header_Payloadsize{op_Num}};
  endtask
 
endmodule