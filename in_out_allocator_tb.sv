import params_noc::*;
`timescale 1ns/1ps

module in_out_allocator_tb#(parameter vc_Num =4);

    logic clk, rst_n;                                               //clock, reset
    logic [in_Port_Cnt-1:0][vc_Num-1:0] request_in;                 //input port
    inout_Port [vc_Num-1:0] out_port_cmd [in_Port_Cnt-1:0];             //output port
    localparam [31:0] AGENTS_PTR_SIZE_IN = $clog2(vc_Num);          //vc pointer size
    localparam [31:0] AGENTS_PTR_SIZE_OUT = $clog2(in_Port_Cnt);    //input port pointer size
    logic [in_Port_Cnt-1:0][AGENTS_PTR_SIZE_IN-1:0] curr_highest_priority_vc, next_highest_priority_vc;   // current highest priority
    logic [in_Port_Cnt-1:0][AGENTS_PTR_SIZE_OUT-1:0] curr_highest_priority_ip, next_highest_priority_ip;  //next hightest priority
    logic [in_Port_Cnt-1:0][vc_Num-1:0] vc_grant_gen;         //vc grant 
    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] ip_grant_gen;    //ip grant
    logic [in_Port_Cnt-1:0][in_Port_Cnt-1:0] out_request_gen;  //output port grant
    logic [in_Port_Cnt-1:0][vc_Num-1:0] grant_o_gen;         //tb final grant output matrix 
    wire [in_Port_Cnt-1:0][vc_Num-1:0] grants;              //final grant output matrix
    inout_Port [in_Port_Cnt-1:0] ports = {LOCAL, NORTH, SOUTH, WEST, EAST};   //ports 

  //clock
  always #5 clk= ~clk;

  //module instantiation 
  in_out_allocator #(.vc_Num(vc_Num)) iobuff (.clk(clk), .rst_n(rst_n), .request_in(request_in), .inports_Out(out_port_cmd), .grant_o(grants));

initial
    begin
        dump_output();
        initialize();
        clear_reset();
        test();
        $display("[ALLOCATOR PASSED]");
        #5 $finish;
        
    end

    task dump_output();
        $dumpfile("out.vcd");
        $dumpvars(0, in_out_allocator_tb);
    endtask

    task initialize();
        clk <= 0;
        rst_n  = 0;
        for(int i=0; i < in_Port_Cnt; i++)
        begin
            curr_highest_priority_vc[i] = 1'b0;
            vc_grant_gen[i] = {vc_Num{1'b0}};
            curr_highest_priority_ip[i] = 1'b0;
        end
        ip_grant_gen = {in_Port_Cnt*in_Port_Cnt{1'b0}};
        out_request_gen = {in_Port_Cnt*in_Port_Cnt{1'b0}};
        grant_o_gen = {in_Port_Cnt*vc_Num{1'b0}};
    endtask

    task clear_reset();
        @(posedge clk);
            rst_n <= 1;
    endtask
    
    task test();
        repeat(10) @(posedge clk)
        begin
            for(int j=0; j < in_Port_Cnt; j = j + 1)
            begin
                request_in[j] = {vc_Num{$random}};
                gen_vc_grant(j);
            end
            for(int j=0; j < in_Port_Cnt; j = j + 1)
            begin 
                out_port_cmd[j] = {in_Port_Cnt{ports[$urandom_range(4,0)]}};
                gen_out_request();
            end
            for(int j=0; j < in_Port_Cnt; j = j + 1)
                gen_ip_grant(j); 
            gen_grant_o();
            check_matrices();
        end
        #5 $stop;
    endtask
    
    //round robin on vc's
    task gen_vc_grant(input int k);
        vc_grant_gen[k]  =  {vc_Num{1'b0}};
        next_highest_priority_vc[k] = curr_highest_priority_vc[k];
        for(int i = 0; i < vc_Num; i = i + 1)
        begin
            if(request_in[k][(curr_highest_priority_vc[k] + i) % vc_Num])
            begin
                vc_grant_gen[k][(curr_highest_priority_vc[k] + i) % vc_Num] = 1'b1; 
                next_highest_priority_vc[k] = (curr_highest_priority_vc[k] + i + 1) % vc_Num;
                break;
            end
        end
        curr_highest_priority_vc[k] = next_highest_priority_vc[k];            
    endtask
    
    //round robin on the input ports 
    task gen_ip_grant(input int k);
        ip_grant_gen[k]  =  {in_Port_Cnt{1'b0}};
        next_highest_priority_ip[k] = curr_highest_priority_ip[k];
        for(int i = 0; i < in_Port_Cnt; i = i + 1)
        begin
            if(out_request_gen[k][(curr_highest_priority_ip[k] + i) % in_Port_Cnt])
            begin
                ip_grant_gen[k][(curr_highest_priority_ip[k] + i) % in_Port_Cnt] = 1'b1;
                next_highest_priority_ip[k] = (curr_highest_priority_ip[k] + i + 1) % in_Port_Cnt;
                break;
            end
        end
        curr_highest_priority_ip[k] = next_highest_priority_ip[k];
    endtask

    //first stage outptut
    task gen_out_request();
        out_request_gen = {in_Port_Cnt*in_Port_Cnt{1'b0}};
        for(int i = 0; i < in_Port_Cnt; i = i + 1)
            begin
                for(int j = 0; j < vc_Num; j = j + 1)
                begin
                    if(vc_grant_gen[i][j])
                    begin
                        out_request_gen[out_port_cmd[i][j]][i] = 1'b1;
                        break;
                    end
                end
            end
    endtask

    //output final grant matrix
    task gen_grant_o();
        grant_o_gen= {in_Port_Cnt*vc_Num{1'b0}};
        for(int i = 0; i < in_Port_Cnt; i = i + 1)
        begin
            for(int j = 0; j < in_Port_Cnt; j = j + 1)
            begin
                for(int k = 0; k < vc_Num; k = k + 1)
                begin
                    if(ip_grant_gen[i][j] & vc_grant_gen[j][k])
                    begin
                        grant_o_gen[j][k] = 1'b1;
                        break;
                    end
                end
            end
        end
    endtask
    
    //Logic to check if the generated grant matrix is same as grant matrix calculated through the RTL
    task check_matrices();
        @(negedge clk)
        for(int g = 0; g < in_Port_Cnt; g = g + 1)
        begin
            for(int h = 0; h < vc_Num; h = h + 1)
            begin
            if(grants[g][h]!==grant_o_gen[g][h])
                begin
                    $display("[ARBITER FAILED] %d,%d  out: %d generated: %d", g, h, grants[g][h],grant_o_gen[g][h]);
                    #5 $stop;
                end
            else 
                begin
                    $display("[ARBITER PASSED] %d,%d  out: %d generated: %d", g, h, grants[g][h],grant_o_gen[g][h]);
                end
            end
        end
    endtask

endmodule

