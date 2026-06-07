// =============================================================================
// MUX — Selects operand_b source for the ALU
// =============================================================================
// addr_sel = 0 : both operands from RAM (address_a and address_b)
// addr_sel = 1 : operand_a from RAM (address_a), operand_b from immediate
// =============================================================================

module mux_operand_b (
    input  signed [15:0] ram_data,   // Data read from RAM port B
    input  signed [15:0] immediate,  // Immediate value from instruction
    input                addr_sel,   // 0 = RAM, 1 = Immediate
    output signed [15:0] operand_b   // Selected operand to ALU
);

    assign operand_b = addr_sel ? immediate : ram_data;

endmodule
