
package struct_param;


//X x Y mesh size
localparam mesh_Size_X = 6;
localparam mesh_Size_Y = 6;

//no of bits to assign to x and y coordinates of the destination to be stored in flit header 
localparam x_Des = $clog2(mesh_Size_X);
localparam y_Des = $clog2(mesh_Size_Y);

//payload size of the header
localparam header_Payloadsize = 16;

//flit_Data_Label to label which type of flit data is it 
typedef enum logic [1:0] {HEAD, BODY, TAIL, HEADTAIL} flit_Data_Label;

//packet size 
localparam flit_Size = x_Des + y_Des + header_Payloadsize;

//structure to store header data 
typedef struct packed
{
	logic [x_Des-1:0] x_Dest;
	logic [y_Des-1:0] y_Dest;
	logic [header_Payloadsize-1:0] head_Payload;
} packet_Header;

//structure to store either the header/body/tail/headtail depending upon the flit data label with no VC allocation 	
typedef struct packed 
{
	flit_Data_Label flit_DataLabel;
	//for union only one data type can be accessed at a time as the storage is allocated only for one data type
	union packed 
	{
		packet_Header head_Data;
		logic [flit_Size-1:0] flit;
	}data;
} flit_Data_noVC;

endpackage		