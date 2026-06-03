module apb_master(
    input PCLK,
    input PRESETn,
    input transfer,
    input READ_WRITE,
    input [8:0] apb_write_paddr,
    input [7:0] apb_write_data,
    input [8:0] apb_read_paddr,
    input [7:0] PRDATA,
    input PREADY,

    output reg PSEL,
    output reg PENABLE,
    output reg PWRITE,
    output reg [8:0] PADDR,
    output reg [7:0] PWDATA,
    output reg [7:0] apb_read_data_out
);

parameter IDLE   = 2'b00;
parameter SETUP  = 2'b01;
parameter ACCESS = 2'b10;

reg [1:0] state, next_state;

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn)
        state <= IDLE;
    else
        state <= next_state;
end

always @(*) begin
    case(state)
        IDLE: begin
            if(transfer)
                next_state = SETUP;
            else
                next_state = IDLE;
        end

        SETUP: begin
            next_state = ACCESS;
        end

        ACCESS: begin
            if(PREADY) begin
                if(transfer)
                    next_state = SETUP;
                else
                    next_state = IDLE;
            end
            else begin
                next_state = ACCESS;
            end
        end

        default: begin
            next_state = IDLE;
        end
    endcase
end

always @(posedge PCLK or negedge PRESETn) begin
    if(!PRESETn) begin
        PSEL <= 1'b0;
        PENABLE <= 1'b0;
        PWRITE <= 1'b0;
        PADDR <= 9'd0;
        PWDATA <= 8'd0;
    end
    else begin
        case(next_state)
            IDLE: begin
                PSEL <= 1'b0;
                PENABLE <= 1'b0;
            end

            SETUP: begin
                PSEL <= 1'b1;
                PENABLE <= 1'b0;
                PWRITE <= READ_WRITE;

                if(READ_WRITE) begin
                    PADDR <= apb_write_paddr;
                    PWDATA <= apb_write_data;
                end
                else begin
                    PADDR <= apb_read_paddr;
                end
            end

            ACCESS: begin
                PSEL <= 1'b1;
                PENABLE <= 1'b1;
            end

            default: begin
                PSEL <= 1'b0;
                PENABLE <= 1'b0;
            end
        endcase
    end
end

always @(*) begin
    if(state == ACCESS && PREADY && !PWRITE)
        apb_read_data_out = PRDATA;
    else
        apb_read_data_out = 8'd0;
end

endmodule
