module cpu (
    input clk,
    input power,
    input enviar,

    input [2:0] opcode,
    input [3:0] reg_um,
    input [3:0] reg_dois,
    input [6:0] reg_tres_ou_imm,

    output [7:0] lcd_dados,
    output RS,
    output RW,
    output enable,
    output lcd_on,
    output lcd_blon
);

    // -------------------------------------------------------------------------
    // Debounced buttons
    // -------------------------------------------------------------------------
    wire power_clean;
    wire enviar_clean;

    debounce DB_POWER  (.clk(clk), .btn_raw(power),  .btn_clean(power_clean));
    debounce DB_ENVIAR (.clk(clk), .btn_raw(enviar), .btn_clean(enviar_clean));

    assign lcd_on   = 1'b1;
    assign lcd_blon = 1'b1;

    // -------------------------------------------------------------------------
    // Immediate decode — combinational
    // -------------------------------------------------------------------------
    wire is_immediate = (opcode == load  || opcode == addi ||
                         opcode == subi  || opcode == mul);

    wire signed [15:0] imd;
    assign imd = is_immediate
        ? (reg_tres_ou_imm[6]
            ? -{10'b0, reg_tres_ou_imm[5:0]}
            :  {10'b0, reg_tres_ou_imm[5:0]})
        : 16'sd0;

    wire [3:0] addr_rd2;
    assign addr_rd2 = is_immediate ? 4'b0000 : reg_tres_ou_imm[6:3];

    // -------------------------------------------------------------------------
    // Internal signals
    // -------------------------------------------------------------------------
    reg [3:0]        addr_rd1, addr_wr;
    reg signed [15:0] dado_para_memoria;
    reg [1:0]        estado_modo_mem;
    reg              lcd_start;
    wire             lcd_ocupado;

    wire signed [15:0] resultado_ula;
    reg  signed [15:0] ula_operando_b;
    wire [15:0]        data_out1_mem, data_out2_mem;

    // -------------------------------------------------------------------------
    // Opcodes
    // -------------------------------------------------------------------------
    parameter load    = 3'b000,
              add     = 3'b001,
              addi    = 3'b010,
              sub     = 3'b011,
              subi    = 3'b100,
              mul     = 3'b101,
              clear   = 3'b110,
              display = 3'b111;

    // -------------------------------------------------------------------------
    // FSM states
    // -------------------------------------------------------------------------
    parameter espera        = 3'd0,
              ler_ram       = 3'd1,
              acessar_ula   = 3'd2,
              escrever_ram  = 3'd3,
              atualizar_lcd = 3'd4;

    reg [2:0] estado = espera;

    // -------------------------------------------------------------------------
    // FSM
    // -------------------------------------------------------------------------
    always @(posedge clk) begin

        if (power_clean == 1'b0) begin
            estado          <= espera;
            estado_modo_mem <= 2'b10;
            lcd_start       <= 1'b0;
        end
        else begin
            case (estado)

                espera: begin
                    if (enviar_clean) begin
                        estado          <= ler_ram;
                        estado_modo_mem <= (opcode == clear) ? 2'b10 : 2'b00;
                    end
                end

                ler_ram: begin
                    addr_rd1        <= (opcode == display) ? reg_um : reg_dois;
                    estado_modo_mem <= 2'b00;
                    estado          <= acessar_ula;
                end

                acessar_ula: begin
                    ula_operando_b <= (opcode == addi || opcode == subi || opcode == mul)
                                      ? imd
                                      : data_out2_mem;
                    estado <= escrever_ram;
                end

                escrever_ram: begin
                    addr_wr <= reg_um;

                    case (opcode)
                        load    : dado_para_memoria <= imd;
                        add,
                        addi,
                        sub,
                        subi,
                        mul     : dado_para_memoria <= resultado_ula;
                        clear   : dado_para_memoria <= 16'sh0000;
                        display : dado_para_memoria <= data_out1_mem;
                        default : dado_para_memoria <= 16'sh0000;
                    endcase

                    estado_modo_mem <= (opcode == display) ? 2'b00 : 2'b01;
                    lcd_start       <= 1'b1;
                    estado          <= atualizar_lcd;
                end

                atualizar_lcd: begin
                    estado_modo_mem <= 2'b00;
                    lcd_start       <= 1'b0;  // Clear immediately on entry

                    if (lcd_start == 1'b0 && lcd_ocupado == 1'b0)
                        estado <= espera;
                end

                default: estado <= espera;

            endcase
        end
    end

    // -------------------------------------------------------------------------
    // Module instantiations
    // -------------------------------------------------------------------------
    memoria16_16 registrar (
        .clk         (clk),
        .estado_modo (estado_modo_mem),
        .addr_rd1    (addr_rd1),
        .addr_rd2    (addr_rd2),
        .addr_wr     (addr_wr),
        .data_in     (dado_para_memoria),
        .data_out1   (data_out1_mem),
        .data_out2   (data_out2_mem)
    );

    ULA operar (
        .operand_a (data_out1_mem),
        .operand_b (ula_operando_b),
        .opcode    (opcode),
        .result    (resultado_ula)
    );

    wire rst_lcd = ~power_clean;

    lcd_controller_top tela_placa (
        .clk      (clk),
        .rst      (rst_lcd),
        .start    (lcd_start),
        .opcode   (opcode),
        .addr_wr  (addr_wr),
        .dado_ula (dado_para_memoria),
        .ocupado  (lcd_ocupado),
        .lcd_data (lcd_dados),
        .lcd_rs   (RS),
        .lcd_rw   (RW),
        .lcd_e    (enable)
    );

endmodule
