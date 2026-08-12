`include "defines.sv"

class apb_transaction;
//inputs are declared as rand
rand bit transfer, write_read, PREADY, PSLVERR;
randc bit [`DATA_WIDTH-1:0] PRDATA,wdata_in;
randc bit [`ADDR_WIDTH-1:0]  addr_in;
randc bit [`PSTRB_WIDTH-1:0] strb_in;

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
transfer == 1;
}
constraint slave_representation{
pready_delay inside {[0:5]};
PSLVERR dist{0:=90,1:=10};
}
constraint read_write_strb{
//write_read dist{0:=50,1:=50};
if(!write_read)
wdata_in==0 && strb_in==0;
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

class write_only extends apb_transaction;

constraint b2b_write_c{
    transfer==1;
    write_read==1;
}

virtual function apb_transaction copy();
    write_only copy1;
    copy1=new();

    copy1.transfer=this.transfer;
    copy1.write_read=this.write_read;
    copy1.PREADY=this.PREADY;
    copy1.PSLVERR=this.PSLVERR;
    copy1.PRDATA=this.PRDATA;
    copy1.wdata_in=this.wdata_in;
    copy1.addr_in=this.addr_in;
    copy1.strb_in=this.strb_in;
    copy1.pready_delay=this.pready_delay;

    return copy1;
endfunction

endclass

class read_only extends apb_transaction;

constraint read_only_c {
    transfer   == 1;
    write_read == 0;
    strb_in    == 4'b0000;
}

virtual function apb_transaction copy();

    read_only copy1;
    copy1 = new();
    copy1.transfer     = this.transfer;
    copy1.write_read   = this.write_read;
    copy1.PREADY       = this.PREADY;
    copy1.PSLVERR      = this.PSLVERR;
    copy1.PRDATA       = this.PRDATA;
    copy1.wdata_in     = this.wdata_in;
    copy1.addr_in      = this.addr_in;
    copy1.strb_in      = this.strb_in;
    copy1.pready_delay = this.pready_delay;

    return copy1;

endfunction

endclass
