// =============================================================================
// Top-Level — Wires Control Unit, RAM, MUX, and ALU together
// =============================================================================
// Data flow:
//   opcode → control_unit → (ram_read, ram_write, imm_sel)
//   address + ram_read/write → RAM ↔ data_out/data_in
//   (ram_data | immediate) → mux_operand_b → operand_b
//   (operand_a, operand_b, opcode) → ULA → result
//   result → RAM.data_in (writeback for CLEAR and future store ops)
// =============================================================================

module top (
    input             clk,         // System clock
    input             reset,       // Async active-low reset
    input      [2:0]  opcode,      // Instruction opcode
    input      [3:0]  address,     // RAM address
    input  signed [15:0] operand_a,  // Source register 1 (accumulator / Src1)
    input  signed [15:0] immediate,  // Immediate value from instruction
    output signed [15:0] result      // ALU result (also to display / writeback)
);

    // -------------------------------------------------------------------------
    // Internal wires
    // -------------------------------------------------------------------------
    wire        ram_read;       // Control → RAM + address_reg latch
    wire        ram_write;      // Control → RAM write enable
    wire        imm_sel;        // Control → MUX select

    wire signed [15:0] ram_data_out;  // RAM  → MUX
    wire signed [15:0] operand_b;     // MUX  → ALU

    // -------------------------------------------------------------------------
    // Control Unit
    // -------------------------------------------------------------------------
    control_unit CU (
        .opcode    (opcode),
        .ram_read  (ram_read),
        .ram_write (ram_write),
        .imm_sel   (imm_sel)
    );

    // -------------------------------------------------------------------------
    // RAM
    // data_in is driven by ALU result for writeback (e.g. CLEAR writes 0)
    // -------------------------------------------------------------------------
    RAM MEM (
        .clk      (clk),
        .reset    (reset),
        .read     (ram_read),
        .write    (ram_write),
        .address  (address),
        .data_in  (result),
        .data_out (ram_data_out)
    );

    // -------------------------------------------------------------------------
    // MUX — selects operand_b source
    // -------------------------------------------------------------------------
    mux_operand_b MUX (
        .ram_data  (ram_data_out),
        .immediate (immediate),
        .imm_sel   (imm_sel),
        .operand_b (operand_b)
    );

    // -------------------------------------------------------------------------
    // ALU
    // -------------------------------------------------------------------------
    ULA ALU (
        .operand_a (operand_a),
        .operand_b (operand_b),
        .opcode    (opcode),
        .result    (result)
    );

endmodule
