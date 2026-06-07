// =============================================================================
// RAM — 16 x 16-bit Synchronous Memory with Dual Read Ports
// =============================================================================
// Behavior:
//   - Reset (active-low, async) : clears all 16 positions to zero
//   - Write (sync, on posedge)  : stores data_in at address_w
//   - Read  (sync, on posedge)  : latches address_a and address_b
//   - Output                    : combinational read from both registered addresses
// =============================================================================

module RAM (
    input             clk,          // Clock
    input             reset,        // Asynchronous reset, active-low
    input             write,        // Write enable
    input             read,         // Read enable (latches both addresses)
    input      [3:0]  address_a,    // Read address for operand_a
    input      [3:0]  address_b,    // Read address for operand_b
    input      [3:0]  address_w,    // Write address
    input      [15:0] data_in,      // Data to write
    output     [15:0] data_out_a,   // Data output for operand_a
    output     [15:0] data_out_b    // Data output for operand_b
);

    integer i;
    reg [15:0] ram_block    [0:15]; // 16 words of 16 bits
    reg [3:0]  address_reg_a;       // Registered read address for operand_a
    reg [3:0]  address_reg_b;       // Registered read address for operand_b

    // -------------------------------------------------------------------------
    // Write port — synchronous write, asynchronous active-low reset
    // -------------------------------------------------------------------------
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            for (i = 0; i < 16; i = i + 1)
                ram_block[i] <= 16'd0;
            address_reg_a <= 4'd0;
            address_reg_b <= 4'd0;
        end
        else begin
            if (write)
                ram_block[address_w] <= data_in;

            if (read) begin
                address_reg_a <= address_a;
                address_reg_b <= address_b;
            end
        end
    end

    // -------------------------------------------------------------------------
    // Dual read ports — combinational, driven by registered addresses
    // -------------------------------------------------------------------------
    assign data_out_a = ram_block[address_reg_a];
    assign data_out_b = ram_block[address_reg_b];

endmodule
