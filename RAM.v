// =============================================================================
// RAM — 16 x 16-bit Synchronous Memory with Asynchronous Active-Low Reset
// =============================================================================
// Behavior:
//   - Reset (active-low, async) : clears all 16 positions to zero
//   - Write (sync, on posedge)  : stores data_in at address
//   - Read  (sync, on posedge)  : latches address into address_reg
//   - Output                    : combinational read from address_reg
// =============================================================================

module RAM (
    input             clk,        // Clock
    input             reset,      // Asynchronous reset, active-low
    input             write,      // Write enable
    input             read,       // Read enable (latches address)
    input      [3:0]  address,    // 4-bit address (16 positions)
    input      [15:0] data_in,    // Data to write
    output     [15:0] data_out    // Data read output
);

    integer i;
    reg [15:0] ram_block  [0:15]; // 16 words of 16 bits
    reg [3:0]  address_reg;       // Registered read address

    // -------------------------------------------------------------------------
    // Write port — synchronous write, asynchronous active-low reset
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 16; i = i + 1)
                ram_block[i] <= 16'd0;
            address_reg <= 4'd0;
        end
        else begin
            if (write)
                ram_block[address] <= data_in;

            if (read)
                address_reg <= address;
        end
    end

    // -------------------------------------------------------------------------
    // Read port — combinational, driven by registered address
    // -------------------------------------------------------------------------
    assign data_out = ram_block[address_reg];

endmodule
