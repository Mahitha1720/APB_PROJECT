`include "defines.sv"

class apb_test;
//declareing all the virtuall interface
virtual apb_interface drv_vif;
virtual apb_interface ip_mon_vif;
virtual apb_interface op_mon_vif;

apb_environment env;

function new(virtual apb_interface drv_vif,virtual apb_interface ip_mon_vif,
virtual apb_interface op_mon_vif);
this.drv_vif=drv_vif;
this.ip_mon_vif=ip_mon_vif;
this.op_mon_vif=op_mon_vif;
endfunction

task start();
env=new(drv_vif,ip_mon_vif,op_mon_vif);
env.build();
env.start();
endtask
endclass
