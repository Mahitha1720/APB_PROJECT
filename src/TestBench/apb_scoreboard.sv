`include "defines.sv"

class apb_scoreboard;

apb_transaction ip_trans,op_trans;

mailbox #(apb_transaction) mbx_ims;
mailbox #(apb_transaction) mbx_oms;

int pass_count,fail_count;

logic [`DATA_WIDTH-1:0] expected_wdata;

function new(mailbox #(apb_transaction) mbx_ims,
             mailbox #(apb_transaction) mbx_oms);
this.mbx_ims=mbx_ims;
this.mbx_oms=mbx_oms;
pass_count=0;
fail_count=0;
endfunction

task start();
$display("[%0t] SCR Start",$time);
for(int i=0;i<`num_transaction;i++) begin
ip_trans=new();
op_trans=new();

mbx_ims.get(ip_trans);
mbx_oms.get(op_trans);

$display("[SCB] INPUT : transfer=%b write_read=%b addr=%h wdata=%h strb=%b PREADY=%b PSLVERR=%b PRDATA=%h",
ip_trans.transfer,
ip_trans.write_read,
ip_trans.addr_in,
ip_trans.wdata_in,
ip_trans.strb_in,
ip_trans.PREADY,
ip_trans.PSLVERR,
ip_trans.PRDATA);

$display("[SCB] OUTPUT: PSEL=%b PENABLE=%b PWRITE=%b PADDR=%h PWDATA=%h PSTRB=%b RDATA=%h transfer_done=%b error=%b",
op_trans.PSEL,
op_trans.PENABLE,
op_trans.PWRITE,
op_trans.PADDR,
op_trans.PWDATA,
op_trans.PSTRB,
op_trans.rdata_out,
op_trans.transfer_done,
op_trans.error);


check_pwrite();
check_paddr();
check_pwdata();
check_pstrb();
check_rdata();
check_error();
check_transfer_done();
check_psel();
end
report();
endtask

task check_pwrite();
if(ip_trans.write_read==op_trans.PWRITE) begin
$display("[SCB] PASS : PWRITE matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : PWRITE mismatch");
fail_count++;
end
endtask

task check_paddr();
if(op_trans.PADDR==ip_trans.addr_in) begin
$display("[SCB] PASS : PADDR matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : PADDR mismatch");
fail_count++;
end
endtask

task check_pwdata();
if(ip_trans.write_read) begin
if(op_trans.PWDATA==ip_trans.wdata_in) begin
$display("[SCB] PASS : PWDATA matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : PWDATA mismatch");
fail_count++;
end
end
else
$display("[SCB] SKIP : Read transaction");
endtask

task check_pstrb();
//expected_wdata='0;
if(ip_trans.write_read) begin
//for(int i=0;i<`PSTRB_WIDTH;i++) begin
//if(ip_trans.strb_in[i])
//expected_wdata[i*8+:8]=ip_trans.wdata_in[i*8+:8];
//end
if(op_trans.PSTRB==ip_trans.strb_in) begin
$display("[SCB] PASS : PSTRB matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : PSTRB mismatch");
fail_count++;
end
/*if(op_trans.PWDATA==expected_wdata) begin
$display("[SCB] PASS : Masked PWDATA matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : Masked PWDATA mismatch");
fail_count++;
end*/
end
else
$display("[SCB] SKIP : Read transaction");
endtask

task check_rdata();
if(!ip_trans.write_read) begin
if(op_trans.rdata_out==ip_trans.PRDATA) begin
$display("[SCB] PASS : Read Data matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : Read Data mismatch");
fail_count++;
end
end
else
$display("[SCB] SKIP : Write transaction");
endtask

task check_error();
if(ip_trans.PREADY) begin
if(op_trans.error==ip_trans.PSLVERR) begin
$display("[SCB] PASS : Error matched");
pass_count++;
end
else begin
$display("[SCB] FAIL : Error mismatch");
fail_count++;
end
end
else
$display("[SCB] SKIP : Waiting for PREADY");
endtask

task check_transfer_done();
if(ip_trans.PREADY) begin
if(op_trans.transfer_done) begin
$display("[SCB] PASS : transfer_done asserted");
pass_count++;
end
else begin
$display("[SCB] FAIL : transfer_done not asserted");
fail_count++;
end
end
else
$display("[SCB] SKIP : Waiting for PREADY");
endtask

task check_psel();
if(ip_trans.transfer) begin
if(op_trans.PSEL) begin
$display("[SCB] PASS : PSEL asserted");
pass_count++;
end
else begin
$display("[SCB] FAIL : PSEL not asserted");
fail_count++;
end
end
endtask

task report();
$display("\n========================================");
$display("[SCB] FINAL REPORT");
$display("========================================");
$display("[SCB] PASS COUNT : %0d",pass_count);
$display("[SCB] FAIL COUNT : %0d",fail_count);
if(fail_count==0)
$display("[SCB] ALL CHECKS PASSED");
else
$display("[SCB] SOME CHECKS FAILED");
$display("========================================\n");
endtask

endclass

