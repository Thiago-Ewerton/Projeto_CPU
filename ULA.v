// =============================================================================
// Arithmetic Logic Unit (ALU) — 16-bit Signed
// =============================================================================
// Opcodes:
//   000  LOAD    — Pass immediate value to output
//   001  ADD     — Register + Register
//   010  ADDI    — Register + Immediate
//   011  SUB     — Register - Register
//   100  SUBI    — Register - Immediate
//   101  MUL     — Register × Immediate
//   110  CLEAR   — Zero output (memory control handled externally)
//   111  DISPLAY — Pass register value to display output
// =============================================================================

module ULA (
    input  signed [15:0] operand_a,  // Source register 1 (Src1)
    input  signed [15:0] operand_b,  // Source register 2 or immediate value
    input         [2:0]  opcode,     // 3-bit instruction opcode
    output reg signed [15:0] result  // 16-bit operation result
);

    // Opcode parameters for readability and maintainability
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
        case (opcode)
            OP_LOAD    : result = operand_b;              // Load immediate
            OP_ADD     : result = operand_a + operand_b;  // Reg + Reg
            OP_ADDI    : result = operand_a + operand_b;  // Reg + Immediate
            OP_SUB     : result = operand_a - operand_b;  // Reg - Reg
            OP_SUBI    : result = operand_a - operand_b;  // Reg - Immediate
            OP_MUL     : result = operand_a * operand_b;  // Reg × Immediate
            OP_CLEAR   : result = 16'd0;                  // Zero output
            OP_DISPLAY : result = operand_a;              // Pass to display
            default    : result = 16'd0;                  // Latch prevention
        endcase
    end

endmodule