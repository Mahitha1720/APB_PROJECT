`include "defines.sv"
class apb_environment;
//declareing all the virtuall interface
virtual apb_interface drv_vif;
virtual apb_interface ip_mon_vif;
virtual apb_interface op_mon_vif;

//declaring all mailbox
mailbox #(apb_transaction)mbx_gd;
mailbox #(apb_transaction)mbx_ims;
mailbox #(apb_transaction)mbx_oms;

//environment component declared

apb_generator gen;
apb_driver drv;
apb_monitor_ip ip_mon;
apb_monitor_op op_mon;
apb_scoreboard scb;

function new(virtual apb_interface drv_vif,virtual apb_interface ip_mon_vif,
virtual apb_interface op_mon_vif);
this.drv_vif=drv_vif;
this.ip_mon_vif=ip_mon_vif;
this.op_mon_vif=op_mon_vif;
endfunction

task build();
mbx_gd=new();
mbx_ims=new();
mbx_oms=new();
gen=new(mbx_gd);
drv=new(mbx_gd,drv_vif);
ip_mon=new(mbx_ims,ip_mon_vif);
op_mon=new(mbx_oms,op_mon_vif);
scb=new(mbx_ims,mbx_oms);
endtask

task start();
fork
gen.start();
drv.start();
ip_mon.start();
op_mon.start();
scb.start();
join
endtask
endclass

