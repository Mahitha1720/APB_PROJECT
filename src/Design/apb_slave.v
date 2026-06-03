module apb_slave(
    input PCLK,
    input PRESETn,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [7:0] PADDR,
    input [7:0] PWDATA,
    output reg [7:0] PRDATA,
    output PREADY,
    output reg PSLVERR
);

reg [7:0] ram [127:0];
integer i;

assign PREADY = PSEL && PENABLE;

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        for(i = 0; i < 128; i = i + 1) begin
            ram[i] <= 8'd0;
        end
        PSLVERR <= 1'b0;
    end
    else begin
        PSLVERR <= 1'b0;

        if(PSEL && PENABLE) begin
            if(PADDR <= 8'd127) begin
                if(PWRITE) begin
                    ram[PADDR] <= PWDATA;
                end
            end
            else begin
                PSLVERR <= 1'b1;
            end
        end
    end
end

always @(*) begin
    if(PSEL && PENABLE && !PWRITE && PADDR <= 8'd127) begin
        PRDATA = ram[PADDR];
    end
    else begin
        PRDATA = 8'd0;
    end
end

endmodule
