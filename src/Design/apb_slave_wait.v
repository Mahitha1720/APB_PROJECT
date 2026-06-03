module apb_slave_wait(
    input PCLK,
    input PRESETn,
    input PSEL,
    input PENABLE,
    input PWRITE,
    input [7:0] PADDR,
    input [7:0] PWDATA,
    output reg [7:0] PRDATA,
    output reg PREADY,
    output reg PSLVERR
);

reg [7:0] ram [127:0];
integer i;
reg [2:0] wait_count;

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        for(i = 0; i < 128; i = i + 1)
            ram[i] <= 8'd0;

        PREADY <= 1'b0;
        PSLVERR <= 1'b0;
        wait_count <= 3'd0;
    end
    else begin
        PREADY <= 1'b0;
        PSLVERR <= 1'b0;

        if(PSEL && PENABLE) begin
            if(wait_count < 3'd2) begin
                wait_count <= wait_count + 1'b1;
            end
            else begin
                wait_count <= 3'd0;
                PREADY <= 1'b1;

                if(PADDR <= 8'd127) begin
                    if(PWRITE)
                        ram[PADDR] <= PWDATA;
                end
                else begin
                    PSLVERR <= 1'b1;
                end
            end
        end
        else begin
            wait_count <= 3'd0;
        end
    end
end

always @(*) begin
    if(PSEL && PENABLE && !PWRITE && PADDR <= 8'd127)
        PRDATA = ram[PADDR];
    else
        PRDATA = 8'd0;
end

endmodule
