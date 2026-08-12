`include "defines.sv"

interface apb_interface(input bit PRESETn,PCLK);
//dummy signal inputs
logic transfer,write_read;
logic [`ADDR_WIDTH-1:0]addr_in;
logic [`DATA_WIDTH-1:0]wdata_in;
logic [(`DATA_WIDTH/8)-1:0]strb_in;

//dummy signal output
logic [`DATA_WIDTH-1:0] rdata_out;
logic transfer_done,error;

//apb inputs
logic [`DATA_WIDTH-1:0]PRDATA;
logic PREADY,PSLVERR;

//apb outputs 
logic [`ADDR_WIDTH-1:0]PADDR;
logic PSEL, PENABLE, PWRITE;
logic[(`DATA_WIDTH/8)-1:0]PSTRB;
logic [`DATA_WIDTH-1:0]PWDATA;

clocking drv_cb@(posedge PCLK);
default input #0 output #0;
output transfer,write_read,addr_in,wdata_in,strb_in,PRDATA,PREADY,PSLVERR;
endclocking

clocking op_mon_cb@(posedge PCLK);
default input #1 output #0;
input PADDR,PSEL, PENABLE, PWRITE,PSTRB,PWDATA,rdata_out,transfer_done,error,PREADY;
endclocking

clocking ip_mon_cb@(posedge PCLK);
default input #0 output #0;
input transfer,write_read,addr_in,wdata_in,strb_in,PRDATA,PREADY,PSLVERR;
endclocking

modport drv_mod(input PRESETn,PCLK,clocking drv_cb);
modport ip_mon_mod(input PRESETn,PCLK,clocking ip_mon_cb);
modport op_mon_mod(input PRESETn,PCLK,clocking op_mon_cb);
endinterface
