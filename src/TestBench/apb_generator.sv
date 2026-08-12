class apb_generator;
apb_transaction apb_trans;
mailbox #(apb_transaction) mbx_gen;

function new(mailbox #(apb_transaction) mbx_gen);
this.mbx_gen= mbx_gen;
apb_trans=new();
endfunction

task start();

for(int i=0; i< `num_transactions; i++) begin
assert(apb_trans.randomize());
mbx_gen.put(apb_trans.copy());

$display("GENERATOR: transfer=%d, write_read=%d, addr_in=%d, wdata_in=%d, strb_in=%d, rdata_out=%d", apb_trans.transfer, apb_trans.write_read, apb_trans.addr_in, apb_trans.wdata_in, apb_trans.strb_in, apb_trans.rdata_out);

end
endtask
endclass
