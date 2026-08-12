`include "defines.sv"

class apb_transaction;
//inputs are declared as rand
rand bit transfer, write_read, PREADY, PSLVERR;
rand bit [`DATA_WIDTH-1:0] PRDATA,wdata_in;
rand bit [`ADDR_WIDTH-1:0]  addr_in;
rand bit [`PSTRB_WIDTH-1:0] strb_in;

//pready delay
rand bit[3:0] pready_delay;

//output as non-rand
bit [`DATA_WIDTH-1:0] rdata_out;
bit transfer_done,error;
bit [`ADDR_WIDTH-1:0]PADDR;
bit PSEL, PENABLE, PWRITE;
bit[(`DATA_WIDTH/8)-1:0]PSTRB;
bit [`DATA_WIDTH-1:0]PWDATA;

//constraint to start the transfer
constraint tran_distribution{
transfer dist {1:=80,0:=20};
}
constraint slave_representation{
pready_delay inside {[0:5]};
PSLVERR dist{0:=90,1:=10};
}
constraint read_write_strb{
//write_read dist{0:=50,1:=50};
if(!write_read)
wdata_in==0;
strb_in==0;
}

virtual function apb_transaction copy();
copy=new();
copy.transfer=this.transfer;
copy.write_read=this.write_read;
copy.PREADY=this.PREADY;
copy.PSLVERR=this.PSLVERR;
copy.PRDATA=this.PRDATA;
copy.wdata_in=this.wdata_in;
copy.addr_in=this.addr_in;
copy.strb_in=this.strb_in;
return copy;
endfunction
endclass
