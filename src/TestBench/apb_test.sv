`include "defines.sv"

class apb_test;

virtual apb_interface drv_vif;
virtual apb_interface ip_mon_vif;
virtual apb_interface op_mon_vif;

apb_environment env;

function new(
    virtual apb_interface drv_vif,
    virtual apb_interface ip_mon_vif,
    virtual apb_interface op_mon_vif
);
    this.drv_vif    = drv_vif;
    this.ip_mon_vif = ip_mon_vif;
    this.op_mon_vif = op_mon_vif;
endfunction

task start();
    env = new(drv_vif, ip_mon_vif, op_mon_vif);
    env.build();
    env.start();
endtask

endclass


class regression_test extends apb_test;

apb_transaction trans;
write_only      trans_write;
read_only       trans_read;

function new(
    virtual apb_interface drv_vif,
    virtual apb_interface ip_mon_vif,
    virtual apb_interface op_mon_vif
);
    super.new(drv_vif, ip_mon_vif, op_mon_vif);
endfunction

task start();

    // Random Test
    $display("\n==============================");
    $display(" RANDOM TEST");
    $display("==============================");

    env = new(drv_vif, ip_mon_vif, op_mon_vif);
    env.build();

    trans = new();
    env.gen.blueprint = trans;
    env.start();


    $display("\n==============================");
    $display(" WRITE ONLY TEST");
    $display("==============================");

    trans_write = new();
    env.gen.blueprint = trans_write;
    env.start();

    $display("\n==============================");
    $display(" READ ONLY TEST");
    $display("==============================");

    trans_read = new();
    env.gen.blueprint = trans_read;
    env.start();

endtask

endclass
