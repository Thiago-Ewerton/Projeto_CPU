// =============================================================================
// MUX — Selects operand_b source for the ALU
// =============================================================================
// imm_sel = 0 : operand_b comes from RAM output
// imm_sel = 1 : operand_b comes from immediate value
// =============================================================================

module mux_operand_b (
    input  signed [15:0] ram_data,   // Data read from RAM
    input  signed [15:0] immediate,  // Immediate value from instruction
    input                imm_sel,    // Source select: 0 = RAM, 1 = Immediate
    output signed [15:0] operand_b   // Selected operand to ALU
);

    assign operand_b = imm_sel ? immediate : ram_data;

endmodule
