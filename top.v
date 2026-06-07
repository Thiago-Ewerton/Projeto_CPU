// =============================================================================
// Top-Level — Wires Control Unit, RAM (dual read), MUX, and ALU together
// =============================================================================

module top (
    input             clk,
    input             reset,
    input      [2:0]  opcode,
    input      [3:0]  address_a,     // RAM read address for operand_a
    input      [3:0]  address_b,     // RAM read address for operand_b (Type A only)
    input      [3:0]  address_w,     // RAM write address
    input  signed [15:0] immediate,  // Immediate value (Type B only)
    output signed [15:0] result
);

    wire        ram_read;
    wire        ram_write;
    wire        addr_sel;

    wire signed [15:0] data_out_a;
    wire signed [15:0] data_out_b;
    wire signed [15:0] operand_a;
    wire signed [15:0] operand_b;

    control_unit CU (
        .opcode    (opcode),
        .ram_read  (ram_read),
        .ram_write (ram_write),
        .addr_sel  (addr_sel)
    );

    RAM MEM (
        .clk        (clk),
        .reset      (reset),
        .read       (ram_read),
        .write      (ram_write),
        .address_a  (address_a),
        .address_b  (address_b),
        .address_w  (address_w),
        .data_in    (result),
        .data_out_a (data_out_a),
        .data_out_b (data_out_b)
    );

    assign operand_a = data_out_a;

    mux_operand_b MUX (
        .ram_data  (data_out_b),
        .immediate (immediate),
        .addr_sel  (addr_sel),
        .operand_b (operand_b)
    );

    ULA ALU (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .opcode    (opcode),
        .result    (result)
    );

endmodule
