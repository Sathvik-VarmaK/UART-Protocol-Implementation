module uart_rx(
    input               clk,
    input               rst_n,
    input               rx_tick,
    input               uart_rx_in,
    output reg [7:0]    rx_data_out,
    output reg          rx_data_valid
    );
    
    localparam IDLE      = 2'b00;
    localparam RX_START  = 2'b01;
    localparam RX_DATA   = 2'b10;
    localparam RX_STOP   = 2'b11;

    reg [1:0] state = IDLE;
    reg [3:0] sample_count = 0;
    reg [2:0] bit_count = 0;
    reg [7:0] rx_shift_reg = 8'b0;
    reg       rx_in_sync = 1'b1;

    always @(posedge clk) rx_in_sync <= uart_rx_in;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            rx_data_valid <= 1'b0;
            sample_count <= 0;
            bit_count <= 0;
        end
        else begin
            rx_data_valid <= 1'b0;
            case(state)
                IDLE: begin
                    if (!rx_in_sync) begin
                        sample_count <= 0;
                        state <= RX_START;
                    end
                end
                RX_START: begin
                    if (rx_tick) begin
                        sample_count <= sample_count + 1;
                        if (sample_count == 7 && !rx_in_sync) begin
                           state <= RX_DATA;
                        end else if (sample_count == 7 && rx_in_sync) begin
                           state <= IDLE;
                        end
                    end
                end
                RX_DATA: begin
                    if (rx_tick) begin
                        sample_count <= sample_count + 1;
                        if (sample_count == 15) begin
                            rx_shift_reg <= {rx_in_sync, rx_shift_reg[7:1]};
                            if (bit_count < 7) begin
                                bit_count <= bit_count + 1;
                            end else begin
                                state <= RX_STOP;
                            end
                        end
                    end
                end
                RX_STOP: begin
                    if (rx_tick) begin
                        sample_count <= sample_count + 1;
                        if (sample_count == 15) begin
                            rx_data_out <= rx_shift_reg;
                            rx_data_valid <= 1'b1;
                            bit_count <= 0;
                            state <= IDLE;
                        end
                    end
                end
            endcase
        end
    end
endmodule
