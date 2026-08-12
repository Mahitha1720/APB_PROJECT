`include "defines.sv"

class apb_output_monitor;

apb_transaction mon_op_trans;

// mailbox to scoreboard
mailbox #(apb_transaction) mbx_oms;

// virtual interface for driver data
virtual apb_interface.op_mon_mod mvif;

// count of real transfers seen
int count = 0;

// coverage group
//covergroup op_mon_cg;
//cp_psel:    coverpoint mon_op_trans.PSEL;
//cp_penable: coverpoint mon_op_trans.PENABLE;
//cp_pwrite:  coverpoint mon_op_trans.PWRITE;
//endgroup

covergroup outmon_cg;

PADDR: coverpoint apb_outmon_trans.PADDR{
  bins low  = {[0:10]};
  bins mid  = {[11:20]};
  bins high = {[21:31]};
}

PSEL: coverpoint apb_outmon_trans.PSEL{
  bins psel_bin = {0,1};
}

PENABLE: coverpoint apb_outmon_trans.PENABLE{
  bins penable_bin = {0,1};
}

PWRITE: coverpoint apb_outmon_trans.PWRITE{
  bins pwrite_bin = {0,1};
}

PWDATA: coverpoint apb_outmon_trans.PWDATA{
  bins low  = {[32'h0000_0000 : 32'h3FFF_FFFF]};
  bins mid  = {[32'h4000_0000 : 32'hBFFF_FFFF]};
  bins high = {[32'hC000_0000 : 32'hFFFF_FFFF]};
}

rdata_out: coverpoint apb_outmon_trans.rdata_out{
  bins low  = {[0:81]};
  bins mid  = {[82:163]};
  bins high = {[164:255]};
}

TRANSFER_DONE: coverpoint apb_outmon_trans.transfer_done{
  bins transfer_done_bins = {0,1};
}

error: coverpoint apb_outmon_trans.error{
  bins error_bins = {0,1};
}

FSM: coverpoint apb_outmon_trans.state{
  bins idle_to_setup    = (apb_transaction::IDLE   => apb_transaction::SETUP);
  bins setup_to_access  = (apb_transaction::SETUP  => apb_transaction::ACCESS);
  bins access_to_idle   = (apb_transaction::ACCESS => apb_transaction::IDLE);
  bins access_to_setup  = (apb_transaction::ACCESS => apb_transaction::SETUP);
  illegal_bins bad_jump = default sequence;
}

pwrite_pwdata: cross apb_outmon_trans.PWRITE, apb_outmon_trans.PWDATA;

pwrite_rdata_out: cross apb_outmon_trans.PWRITE, apb_outmon_trans.rdata_out;

transferdone_error: cross apb_outmon_trans.transfer_done, apb_outmon_trans.error;

psel_penable: cross apb_outmon_trans.PSEL, apb_outmon_trans.PENABLE;

paddr_pwrite: cross apb_outmon_trans.PADDR, apb_outmon_trans.PWRITE;

endgroup


function new(mailbox #(apb_transaction) mbx_oms,
             virtual apb_interface.op_mon_mod mvif);
this.mbx_oms = mbx_oms;
this.mvif    = mvif;
op_mon_cg    = new();
endfunction

task start();
repeat(3) @(mvif.op_mon_cb);   // align with driver/ip_mon startup delay
$display("[%0t] OUTPUT MONITOR START", $time);

while(count < `num_transaction) begin
/*  @(mvif.op_mon_cb);

  // only capture on the cycle a real APB transfer completes
  if(mvif.op_mon_cb.PSEL && mvif.op_mon_cb.PENABLE && mvif.op_mon_cb.PREADY) begin
//@(mvif.op_mon_cb);*/
 do begin
        @(mvif.op_mon_cb);
    end while(!(mvif.op_mon_cb.PSEL && mvif.op_mon_cb.PENABLE && mvif.op_mon_cb.PREADY));

    mon_op_trans = new();
    mon_op_trans.PADDR = mvif.op_mon_cb.PADDR;
    mon_op_trans.PSEL = mvif.op_mon_cb.PSEL;
    mon_op_trans.PENABLE= mvif.op_mon_cb.PENABLE;
    mon_op_trans.PWRITE = mvif.op_mon_cb.PWRITE;
    mon_op_trans.PSTRB= mvif.op_mon_cb.PSTRB;
    mon_op_trans.PWDATA= mvif.op_mon_cb.PWDATA;
    mon_op_trans.rdata_out= mvif.op_mon_cb.rdata_out;
@(mvif.op_mon_cb);
    mon_op_trans.transfer_done = mvif.op_mon_cb.transfer_done;
    mon_op_trans.error = mvif.op_mon_cb.error;

    count++;
    mbx_oms.put(mon_op_trans);
    op_mon_cg.sample();
/*do begin
    @(mvif.op_mon_cb);
end while(mvif.op_mon_cb.PSEL);*/
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

    $display("MONITOR output coverage %d", $time, op_mon_cg.get_coverage());
  end
//end
endtask

endclass
