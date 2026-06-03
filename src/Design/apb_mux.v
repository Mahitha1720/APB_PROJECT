module apb_mux(
    input PSEL,
    input [8:0] PADDR,

    input [7:0] PRDATA1,
    input [7:0] PRDATA2,

    input PREADY1,
    input PREADY2,

    input PSLVERR1,
    input PSLVERR2,

    output reg PSEL1,
    output reg PSEL2,

    output reg [7:0] PRDATA,
    output reg PREADY,
    output reg PSLVERR
);

always @(*) begin
    PSEL1 = 1'b0;
    PSEL2 = 1'b0;
    PRDATA = 8'd0;
    PREADY = 1'b0;
    PSLVERR = 1'b0;

    if(PSEL) begin
        if(PADDR[8] == 1'b0) begin
            PSEL1 = 1'b1;
            PSEL2 = 1'b0;
            PRDATA = PRDATA1;
            PREADY = PREADY1;
            PSLVERR = PSLVERR1;
        end
        else begin
            PSEL1 = 1'b0;
            PSEL2 = 1'b1;
            PRDATA = PRDATA2;
            PREADY = PREADY2;
            PSLVERR = PSLVERR2;
        end
    end
end

endmodule
