// =============================================================================
// Debounce — Filters mechanical button bounce
// =============================================================================
// Waits for the button to stay stable for STABLE_COUNT cycles before
// registering a clean press. At 50MHz, 20-bit counter ≈ 20ms debounce window.
// =============================================================================

module debounce #(
    parameter STABLE_COUNT = 20'd1_000_000  // 20ms at 50MHz — adjust to your clock
)(
    input  clk,
    input  reset,
    input  btn_raw,     // Raw button input from FPGA pin
    output btn_clean    // Debounced single-cycle pulse output
);

    reg [19:0] counter;
    reg        btn_stable;
    reg        btn_prev;

    // -------------------------------------------------------------------------
    // Hold counter — resets whenever button state changes
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            counter    <= 20'd0;
            btn_stable <= 1'b0;
            btn_prev   <= 1'b0;
        end
        else begin
            if (btn_raw != btn_stable) begin
                counter <= counter + 1;
                if (counter >= STABLE_COUNT) begin
                    btn_stable <= btn_raw;  // Accept new state after stable window
                    counter    <= 20'd0;
                end
            end
            else
                counter <= 20'd0;           // Reset counter if signal goes back

            btn_prev <= btn_stable;
        end
    end

    // -------------------------------------------------------------------------
    // Single-cycle pulse on rising edge of debounced signal
    // -------------------------------------------------------------------------
    assign btn_clean = btn_stable & ~btn_prev;

endmodule
