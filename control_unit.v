// =============================================================================
// Control Unit — Decodes 3-bit opcode into datapath control signals
// =============================================================================
// Operation types:
//   Type A (addr_sel = 0) : operand_a = RAM[address_a], operand_b = RAM[address_b]
//   Type B (addr_sel = 1) : operand_a = RAM[address_a], operand_b = immediate
// =============================================================================

module control_unit (
    input      [2:0] opcode,      // 3-bit instruction opcode
    output reg       ram_read,    // RAM read enable
    output reg       ram_write,   // RAM write enable
    output reg       addr_sel     // 0 = both from RAM, 1 = operand_b from immediate
);

    localparam [2:0]
        OP_LOAD    = 3'b000,
        OP_ADD     = 3'b001,
        OP_ADDI    = 3'b010,
        OP_SUB     = 3'b011,
        OP_SUBI    = 3'b100,
        OP_MUL     = 3'b101,
        OP_CLEAR   = 3'b110,
        OP_DISPLAY = 3'b111;

    always @(*) begin
        // Safe defaults
        ram_read  = 1'b0;
        ram_write = 1'b0;
        addr_sel  = 1'b0;

        case (opcode)
            // Type A — both operands from RAM
            OP_LOAD    : ram_read  = 1'b1;
            OP_ADD     : ram_read  = 1'b1;
            OP_SUB     : ram_read  = 1'b1;
            OP_DISPLAY : ram_read  = 1'b1;

            // Type B — operand_a from RAM, operand_b from immediate
            OP_ADDI    : begin ram_read = 1'b1; addr_sel = 1'b1; end
            OP_SUBI    : begin ram_read = 1'b1; addr_sel = 1'b1; end
            OP_MUL     : begin ram_read = 1'b1; addr_sel = 1'b1; end

            // Special — write zero back to RAM
            OP_CLEAR   : ram_write = 1'b1;

            default    : ;
        endcase
    end

endmodule
