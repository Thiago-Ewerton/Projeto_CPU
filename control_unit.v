// =============================================================
// Control Unit — Decodes opcode and drives all control signals
// =============================================================
module control_unit (
    input      [2:0] opcode,    // Instruction opcode
    output reg       ram_read,  // Enable RAM read
    output reg       ram_write, // Enable RAM write
    output reg       imm_sel    // 0 = operand_b from RAM, 1 = from immediate
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
        imm_sel   = 1'b0;

        case (opcode)
            OP_LOAD    : imm_sel   = 1'b1;  // operand_b = immediate
            OP_ADD     : ram_read  = 1'b1;  // operand_b = RAM
            OP_ADDI    : imm_sel   = 1'b1;  // operand_b = immediate
            OP_SUB     : ram_read  = 1'b1;  // operand_b = RAM
            OP_SUBI    : imm_sel   = 1'b1;  // operand_b = immediate
            OP_MUL     : imm_sel   = 1'b1;  // operand_b = immediate
            OP_CLEAR   : ram_write = 1'b1;  // writes zero via ALU result
            OP_DISPLAY : ram_read  = 1'b1;  // reads value to display
            default    : ;                  // all signals stay 0
        endcase
    end

endmodule
