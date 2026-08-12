`include "defines.sv"

// APB INPUT MONITOR
class apb_input_monitor;

apb_transaction mon_ip_trans;

// mailbox to scoreboard
mailbox #(apb_transaction) mbx_ims;

// virtual interface
virtual apb_interface.ip_mon_mod mvif;

// coverage
//covergroup ip_mon_cg;
//cp_transfer:coverpoint mon_ip_trans.transfer;
//cp_rw:coverpoint mon_ip_trans.write_read;
//endgroup

covergroup inmon_cg;

PRESETN: coverpoint vif.PRESETn{
bins presetn_bin= {0,1};
}

TRANSFER: coverpoint apb_inmon_trans.transfer{
bins transfer_bin= {0,1};
}

WRITE_READ: coverpoint apb_inmon_trans.write_read{
bins write_read_bi= {0,1};
}

WDATA: coverpoint apb_inmon_trans.wdata_in{
bins low={[0:81]};
bins mid={[82:163]};
bins high={[164:255]};
}

STRBIN: coverpoint apb_inmon_trans.strb_in{}

transfer_write_read: cross apb_inmon_trans.transfer, apb_inmon_trans.write_read;

presetn_transfer: cross vif.PRESETn, apb_inmon_trans.transfer;

write_read_wdatain: cross apb_inmon_trans.write_read, apb_inmon_trans.wdata_in;

write_read_strb: cross apb_inmon_trans.write_read, apb_inmon_trans.strb_in;

endgroup


function new(mailbox #(apb_transaction) mbx_ims,
             virtual apb_interface.ip_mon_mod mvif);
this.mbx_ims=mbx_ims;
this.mvif=mvif;
ip_mon_cg=new();
endfunction

task start();

repeat(3) @(mvif.ip_mon_cb);

$display("[%0t] INPUT MONITOR START",$time);

for(int i=0;i<`num_transaction;i++) begin

//@(mvif.ip_mon_cb);

/*Detect start of transaction
if(mvif.ip_mon_cb.transfer)begin 

Wait until slave is ready
while(!mvif.ip_mon_cb.PREADY)begin
$display("wait for PREADY");
@(mvif.ip_mon_cb);
end
*/
do begin
@(mvif.ip_mon_cb);
end while(mvif.ip_mon_cb.transfer!==1'b1);
//@(mvif_ip_mon_cb);
mon_ip_trans=new();

mon_ip_trans.transfer=mvif.ip_mon_cb.transfer;
mon_ip_trans.write_read=mvif.ip_mon_cb.write_read;
mon_ip_trans.addr_in=mvif.ip_mon_cb.addr_in;
mon_ip_trans.wdata_in=mvif.ip_mon_cb.wdata_in;
mon_ip_trans.strb_in=mvif.ip_mon_cb.strb_in;

do begin
@(mvif.ip_mon_cb);
end while(mvif.ip_mon_cb.PREADY!==1'b1);

mon_ip_trans.PRDATA=mvif.ip_mon_cb.PRDATA;
mon_ip_trans.PREADY=mvif.ip_mon_cb.PREADY;
mon_ip_trans.PSLVERR=mvif.ip_mon_cb.PSLVERR;

mbx_ims.put(mon_ip_trans);

ip_mon_cg.sample();

$display("[IP MON] transfer=%0b write=%0b addr=%h wdata=%h strb=%b PREADY=%0b PSLVERR=%0b PRDATA=%h",
mon_ip_trans.transfer,
mon_ip_trans.write_read,
mon_ip_trans.addr_in,
mon_ip_trans.wdata_in,
mon_ip_trans.strb_in,
mon_ip_trans.PREADY,
mon_ip_trans.PSLVERR,
mon_ip_trans.PRDATA);

do begin
    @(mvif.ip_mon_cb);
end while(!mvif.ip_mon_cb.transfer);

$display("[IP MON] Coverage = %0.2f%%",ip_mon_cg.get_coverage());

end

endtask

endclass
