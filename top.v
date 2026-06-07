// =============================================================================
// Top-Level — Wires Control Unit, RAM (dual read), MUX, and ALU together
// =============================================================================
// Data flow:
//   opcode → control_unit → (ram_read, ram_write, imm_sel)
//   address_a + address_b → RAM → data_out_a (operand_a), data_out_b → MUX
//   (ram_data | immediate) → mux_operand_b → operand_b
//   (operand_a, operand_b, opcode) → ULA → result
//   result → RAM.data_in (writeback for CLEAR and future store ops)
// =============================================================================

module top (
    input             clk,           // System clock
    input             reset,         // Async active-low reset
    input      [2:0]  opcode,        // Instruction opcode
    input      [3:0]  address_a,     // RAM read address for operand_a
    input      [3:0]  address_b,     // RAM read address for operand_b
    input      [3:0]  address_w,     // RAM write address
    input  signed [15:0] immediate,  // Immediate value from instruction
    output signed [15:0] result      // ALU result (display / writeback)
);

    // -------------------------------------------------------------------------
    // Internal wires
    // -------------------------------------------------------------------------
    wire        ram_read;             // Control → RAM read enable
    wire        ram_write;            // Control → RAM write enable
    wire        imm_sel;              // Control → MUX select

    wire signed [15:0] data_out_a;   // RAM port A → operand_a
    wire signed [15:0] data_out_b;   // RAM port B → MUX
    wire signed [15:0] operand_a;    // MUX/RAM → ALU src1
    wire signed [15:0] operand_b;    // MUX     → ALU src2

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
    // RAM — dual read ports, single write port
    // data_in driven by ALU result for writeback (CLEAR writes 0)
    // -------------------------------------------------------------------------
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

    // -------------------------------------------------------------------------
    // operand_a — always comes directly from RAM port A
    // -------------------------------------------------------------------------
    assign operand_a = data_out_a;

    // -------------------------------------------------------------------------
    // MUX — selects operand_b: RAM port B or immediate
    // -------------------------------------------------------------------------
    mux_operand_b MUX (
        .ram_data  (data_out_b),
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
