`include "apb_master.sv"
`include "apb_interface.sv"
`include "defines.sv"
module apb_top;
import apb_package::*;

//clk and reset
logic PCLK;
logic PRESETn;

//INTERFACE 
apb_interface inf(PRESETn,PCLK);

// INSTANTIATE DUV
apb_master #(
    .ADDR_WIDTH(`ADDR_WIDTH),
    .DATA_WIDTH(`DATA_WIDTH)
) DUT (
    .PCLK          (inf.PCLK),
    .PRESETn       (inf.PRESETn),
    .PADDR         (inf.PADDR),
    .PSEL          (inf.PSEL),
    .PENABLE       (inf.PENABLE),
    .PWRITE        (inf.PWRITE),
    .PWDATA        (inf.PWDATA),
    .PSTRB         (inf.PSTRB),
    .PRDATA        (inf.PRDATA),
    .PREADY        (inf.PREADY),
    .PSLVERR       (inf.PSLVERR),
    .transfer      (inf.transfer),
    .write_read    (inf.write_read),
    .addr_in       (inf.addr_in),
    .wdata_in      (inf.wdata_in),
    .strb_in       (inf.strb_in),
    .rdata_out     (inf.rdata_out),
    .transfer_done (inf.transfer_done),
    .error         (inf.error)
);

//clk toggleing
initial begin
PCLK=0;
forever #10 PCLK=~PCLK;
end

initial begin
PRESETn=0;
repeat(3) @(posedge PCLK);
PRESETn=1;
end
//always @(inf.PREADY )
//    $display("[%0t] TOP : inf.PREADY=%b", $time, inf.PREADY);
//instrantiation of test
//apb_test test;

regression_test tb_reg;

//calling each test
initial
begin
tb_reg=new(inf.drv_mod,inf.ip_mon_mod,inf.op_mon_mod);
tb_reg.start();
$finish;
end
endmodule
