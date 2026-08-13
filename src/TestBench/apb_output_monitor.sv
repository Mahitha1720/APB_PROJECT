`include "defines.sv"
class apb_monitor_op;
apb_transaction mon_op_trans;

mailbox #(apb_transaction) mbx_oms;

virtual apb_interface.op_mon_mod mvif;


covergroup apb_state_cg @(mvif.op_mon_cb);

    cp_state : coverpoint {mvif.op_mon_cb.PSEL, mvif.op_mon_cb.PENABLE} {

        bins idle   = {2'b00};
        bins setup  = {2'b10};
        bins access = {2'b11};
        bins idle_setup =(2'b00 => 2'b10);
        bins setup_access =(2'b10 => 2'b11);
        bins access_idle =(2'b11 =>2'b00);
        bins complete_transfer =(2'b00 => 2'b10 => 2'b11 =>2'b00);
        bins access_setup = (2'b11 => 2'b10);
    }

endgroup
function new(mailbox #(apb_transaction) mbx_oms,
             virtual apb_interface.op_mon_mod mvif);
this.mbx_oms = mbx_oms;
this.mvif    = mvif;
apb_state_cg   = new();
endfunction

task start();
repeat(3) @(mvif.op_mon_cb);
$display("[%0t] OUTPUT MONITOR START", $time);

for(int i=0; i<`num_transaction; i++) begin
  do begin
    @(mvif.op_mon_cb) $display("%0t STATE=%b",$time,{mvif.op_mon_cb.PSEL,mvif.op_mon_cb.PENABLE});
  end while(!(mvif.op_mon_cb.PSEL && mvif.op_mon_cb.PENABLE && mvif.op_mon_cb.PREADY));

  mon_op_trans = new();
  mon_op_trans.PADDR  = mvif.op_mon_cb.PADDR;
  mon_op_trans.PSEL  = mvif.op_mon_cb.PSEL;
  mon_op_trans.PENABLE = mvif.op_mon_cb.PENABLE;
  mon_op_trans.PWRITE = mvif.op_mon_cb.PWRITE;
  mon_op_trans.PSTRB = mvif.op_mon_cb.PSTRB;
  mon_op_trans.PWDATA = mvif.op_mon_cb.PWDATA;

  @(mvif.op_mon_cb);
  mon_op_trans.transfer_done = mvif.op_mon_cb.transfer_done;
  mon_op_trans.error  = mvif.op_mon_cb.error;
  mon_op_trans.rdata_out = mvif.op_mon_cb.rdata_out;


  mbx_oms.put(mon_op_trans);


  $display("[%0t] MONITOR(OUTPUT) send data to scoreboard: PADDR=%h, PSEL=%b, PENABLE=%b, PWRITE=%b, PSTRB=%b, PWDATA=%h, rdata_out=%h, transfer_done=%b, error=%b",
    $time,
    mon_op_trans.PADDR,
    mon_op_trans.PSEL,
    mon_op_trans.PENABLE,
    mon_op_trans.PWRITE,
    mon_op_trans.PSTRB,
    mon_op_trans.PWDATA,
    mon_op_trans.rdata_out,
    mon_op_trans.transfer_done,
    mon_op_trans.error);

  do begin
    @(mvif.op_mon_cb);
  end while(mvif.op_mon_cb.PSEL || mvif.op_mon_cb.PENABLE);
end
endtask

endclass

