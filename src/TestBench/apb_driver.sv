`include "defines.sv"
class apb_driver;
apb_transaction drv_trans;

mailbox #(apb_transaction)mbx_gd;
virtual apb_interface.drv_mod vif;

function new(mailbox#(apb_transaction)mbx_gd,virtual apb_interface.drv_mod vif);
this.mbx_gd=mbx_gd;
this.vif=vif;
//object for coverage
endfunction

task start();
repeat(3) @(vif.drv_cb);
for(int i=0;i<`num_transaction;i++)
begin
drv_trans=new();
mbx_gd.get(drv_trans);

if(vif.PRESETn==0)begin
repeat(1)@(vif.drv_cb)

vif.drv_cb.transfer<=0;
vif.drv_cb.write_read<=0;
vif.drv_cb.addr_in <=0;
vif.drv_cb.wdata_in <=0;
vif.drv_cb.strb_in <=0;
vif.drv_cb.PRDATA <=0;
vif.drv_cb.PREADY <=0;
vif.drv_cb.PSLVERR <=0;
end

else

repeat(1)@(vif.drv_cb)
begin

$display("[%0t] DRIVER transfer=1", $time);
vif.drv_cb.transfer<=drv_trans.transfer;
vif.drv_cb.write_read<=drv_trans.write_read;
vif.drv_cb.addr_in <=drv_trans.addr_in;
vif.drv_cb.wdata_in <=drv_trans.wdata_in;
vif.drv_cb.strb_in <=drv_trans.strb_in;

//slave inputs 
vif.drv_cb.PRDATA <=0;
vif.drv_cb.PREADY <=0;
vif.drv_cb.PSLVERR <=0;

//set no transfer
@(vif.drv_cb);
vif.drv_cb.transfer<=0;
//wait in access
repeat(drv_trans.pready_delay)begin
@(vif.drv_cb);
vif.drv_cb.PREADY <=0;
vif.drv_cb.PSLVERR <=0;
end

//pready signal
@(vif.drv_cb);
vif.drv_cb.PRDATA <=drv_trans.PRDATA;
vif.drv_cb.PREADY <= 1;
vif.drv_cb.PSLVERR <=drv_trans.PSLVERR;

//$display("[%0t] DRIVER: Assigned PREADY=1", $time);
repeat(2)@(vif.drv_cb);
@(vif.drv_cb);
//$display("[%0t] Interface PREADY=%0b", $time, vif.drv_cb.PREADY);
vif.drv_cb.PREADY <= 0;
vif.drv_cb.PSLVERR <= 0;

@(vif.drv_cb);
vif.drv_cb.transfer <= 0;

//$display("[%0t] DRIVER END transfer=%b", $time, vif.drv_cb.transfer);
$display("DRIVER driving data: transfer=%b, write_read=%b, PREADY=%b,PSLVERR=%b,PRDATA=%h,wdata_in=%h,addr_in=%h,strb_in=%b",drv_trans.transfer,drv_trans.write_read,drv_trans.PREADY,drv_trans.PSLVERR,drv_trans.PRDATA,drv_trans.wdata_in,drv_trans.addr_in,drv_trans.strb_in);
end
end
endtask
endclass

