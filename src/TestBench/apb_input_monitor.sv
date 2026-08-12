`include "defines.sv"
class apb_monitor_ip;
apb_transaction mon_ip_trans;

mailbox #(apb_transaction) mbx_ims;

virtual apb_interface.ip_mon_mod mvif;

covergroup ip_mon_cg;
  cp_transfer:   coverpoint mon_ip_trans.transfer{ 
    bins transfer_bin[] = {0,1}; 
  }
  cp_write_read: coverpoint mon_ip_trans.write_read { 
    bins write_bin = {1}; 
    bins read_bin = {0}; }
  cp_addr_in:    coverpoint mon_ip_trans.addr_in { 
    bins addr_bin[3] = {[0:(2**`ADDR_WIDTH)-1]}; }
  cp_wdata: coverpoint mon_ip_trans.wdata_in { bins wdata_bin[2] = {[0:(2**`DATA_WIDTH)-1]}; }
  cp_strb_in: coverpoint mon_ip_trans.strb_in { bins strb_bin[4] = {[0:15]}; }
  cp_pready: coverpoint mon_ip_trans.PREADY {bins pready_bin[] = {0,1}; }
  cp_pslverr: coverpoint mon_ip_trans.PSLVERR { bins pslverr_bin[] = {0,1}; }
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

  do begin
    @(mvif.ip_mon_cb);
  end while(mvif.ip_mon_cb.transfer !== 1'b1);

  mon_ip_trans=new();
  mon_ip_trans.transfer   = mvif.ip_mon_cb.transfer;
  mon_ip_trans.write_read = mvif.ip_mon_cb.write_read;
  mon_ip_trans.addr_in    = mvif.ip_mon_cb.addr_in;
  mon_ip_trans.wdata_in   = mvif.ip_mon_cb.wdata_in;
  mon_ip_trans.strb_in    = mvif.ip_mon_cb.strb_in;

  do begin
    @(mvif.ip_mon_cb);
  end while(mvif.ip_mon_cb.PREADY !== 1'b1);

  mon_ip_trans.PRDATA  = mvif.ip_mon_cb.PRDATA;
  mon_ip_trans.PREADY  = mvif.ip_mon_cb.PREADY;
  mon_ip_trans.PSLVERR = mvif.ip_mon_cb.PSLVERR;

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
  $display("[IP MON] Coverage = %0.2f%%",ip_mon_cg.get_coverage());

  do begin
    @(mvif.ip_mon_cb);
  end while(mvif.ip_mon_cb.transfer === 1'b1);

end
endtask
endclass
