module apb_top(
    input PCLK,
    input PRESETn,
    input transfer,
    input READ_WRITE,
    input [8:0] apb_write_paddr,
    input [7:0] apb_write_data,
    input [8:0] apb_read_paddr,

    output [7:0] apb_read_data_out,
    output PSLVERR,

    output [8:0] PADDR,
    output PSEL,
    output PENABLE,
    output PWRITE
);

wire [7:0] PWDATA;
wire [7:0] PRDATA;
wire PREADY;

wire PSEL1;
wire PSEL2;

wire [7:0] PRDATA1;
wire [7:0] PRDATA2;

wire PREADY1;
wire PREADY2;

wire PSLVERR1;
wire PSLVERR2;

apb_master master(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .transfer(transfer),
    .READ_WRITE(READ_WRITE),
    .apb_write_paddr(apb_write_paddr),
    .apb_write_data(apb_write_data),
    .apb_read_paddr(apb_read_paddr),
    .PRDATA(PRDATA),
    .PREADY(PREADY),

    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PWDATA(PWDATA),
    .apb_read_data_out(apb_read_data_out)
);

apb_mux mux(
    .PSEL(PSEL),
    .PADDR(PADDR),

    .PRDATA1(PRDATA1),
    .PRDATA2(PRDATA2),

    .PREADY1(PREADY1),
    .PREADY2(PREADY2),

    .PSLVERR1(PSLVERR1),
    .PSLVERR2(PSLVERR2),

    .PSEL1(PSEL1),
    .PSEL2(PSEL2),

    .PRDATA(PRDATA),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
);

apb_slave slave1(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL1),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),

    .PRDATA(PRDATA1),
    .PREADY(PREADY1),
    .PSLVERR(PSLVERR1)
);

apb_slave_wait slave2(
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL2),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR[7:0]),
    .PWDATA(PWDATA),

    .PRDATA(PRDATA2),
    .PREADY(PREADY2),
    .PSLVERR(PSLVERR2)
);

endmodule
