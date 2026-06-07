// ---------------------------------------------------------------------------
// Módulo: lcd_controller_top (ADAPTADO COM 2 LINHAS E DECIMAL)
// ---------------------------------------------------------------------------
module lcd_controller_top (
    input  wire        clk,
    input  wire        rst,
    
    // Conexão com a CPU
    input  wire        start,     
    input  wire [2:0]  opcode,    // NOVO: Recebe a operação (3 bits)
    input  wire [3:0]  addr_wr,   // NOVO: Recebe o endereço do registrador
    input  wire [15:0] dado_ula,  
    output wire        ocupado,   

    // Saídas para o LCD físico da Placa
    output wire  [7:0] lcd_data,
    output wire        lcd_rs,
    output wire        lcd_rw,
    output wire        lcd_e
);

    // -----------------------------------------------------------------------
    // Instância do módulo de inicialização (MANTIDO DO ORIGINAL)
    // -----------------------------------------------------------------------
    wire [7:0] init_data;
    wire       init_rs;
    wire       init_rw;
    wire       init_e;
    wire       init_done;
    reg        start_init; 

    lcd_init_hd44780 lcd_init (
        .clk      (clk),
        .rst      (rst),
        .start    (start_init),
        .done     (init_done),
        .lcd_data (init_data),
        .lcd_rs   (init_rs),
        .lcd_rw   (init_rw),
        .lcd_e    (init_e)
    );

    wire controller_mode = init_done;
    assign lcd_data = (controller_mode == 0) ? init_data : wr_data;
    assign lcd_rs   = (controller_mode == 0) ? init_rs   : wr_rs;
    assign lcd_rw   = (controller_mode == 0) ? init_rw   : wr_rw;
    assign lcd_e    = (controller_mode == 0) ? init_e    : wr_e;

    // -----------------------------------------------------------------------
    // Formatação de Mensagem (Decimal, Opcode e 2 Linhas)
    // -----------------------------------------------------------------------
    // 33 comandos: 16 (Linha 1) + 1 (Comando pular linha) + 16 (Linha 2)
    localparam integer MSG_LEN = 33; 
    
    // Agora tem 9 bits: o bit [8] é o RS (0 para comando, 1 para texto) e [7:0] o texto
    reg [8:0] message [0:MSG_LEN-1]; 
    
    // Registradores para salvar os dados no momento do gatilho
    reg [15:0] latched_dado; 
    reg [2:0]  latched_opcode;
    reg [3:0]  latched_addr;

    // 1. Decodificador de Opcode para Texto
    reg [23:0] op_str;
    always @(*) begin
        case (latched_opcode)
            3'b000: op_str = "LOD";
            3'b001: op_str = "ADD";
            3'b010: op_str = "ADI";
            3'b011: op_str = "SUB";
            3'b100: op_str = "SBI";
            3'b101: op_str = "MUL";
            3'b110: op_str = "CLR";
            3'b111: op_str = "DIS";
            default: op_str = "UNK";
        endcase
    end

    // 2. Extrator de Sinal e Valor Absoluto para Decimal
    wire [15:0] abs_val = (latched_dado[15]) ? (~latched_dado + 16'd1) : latched_dado;
    wire [7:0] char_sign = (latched_dado[15]) ? 8'h2D : 8'h2B; // Hex 2D='-', 2B='+'

    // 3. Função para extrair os dígitos decimais
    function [7:0] get_digit;
        input [15:0] value;
        input [2:0] digit_idx;
        reg [15:0] temp;
        begin
            case (digit_idx)
                0: temp = (value % 10);
                1: temp = (value / 10) % 10;
                2: temp = (value / 100) % 10;
                3: temp = (value / 1000) % 10;
                default: temp = 0;
            endcase
            get_digit = temp[7:0] + 8'h30; // Soma com 0x30 para virar ASCII
        end
    endfunction

    // 4. Montagem do Quebra-cabeça na Tela
    integer i;
    always @(*) begin
        // Zera a tela inteira com "Espaços" por padrão (1'b1 = Texto, 8'h20 = Espaço)
        for (i = 0; i < MSG_LEN; i = i + 1) begin
            message[i] = {1'b1, 8'h20}; 
        end
        
        // --- LINHA 1: "ADD [0001]      " ---
        message[0] = {1'b1, op_str[23:16]}; // Letra 1 do Opcode
        message[1] = {1'b1, op_str[15:8]};  // Letra 2
        message[2] = {1'b1, op_str[7:0]};   // Letra 3
        
        message[4] = {1'b1, 8'h5B}; // Colchete '['
        message[5] = {1'b1, latched_addr[3] ? 8'h31 : 8'h30}; // Bits do endereço
        message[6] = {1'b1, latched_addr[2] ? 8'h31 : 8'h30};
        message[7] = {1'b1, latched_addr[1] ? 8'h31 : 8'h30};
        message[8] = {1'b1, latched_addr[0] ? 8'h31 : 8'h30};
        message[9] = {1'b1, 8'h5D}; // Colchete ']'

        // --- COMANDO DE PULAR LINHA (Índice 16) ---
        // 1'b0 indica para o display que não é texto, é um comando (0xC0 = Linha 2)
        message[16] = {1'b0, 8'hC0}; 

        // --- LINHA 2: Alinhado embaixo do [0000] ---
        // A Linha 2 começa no índice 17. Como o '[' está na posição 4, 
        // colocamos o sinal na posição 17 + 4 = 21.
        message[21] = {1'b1, char_sign};
        message[22] = {1'b1, get_digit(abs_val, 3)}; // Milhar
        message[23] = {1'b1, get_digit(abs_val, 2)}; // Centena
        message[24] = {1'b1, get_digit(abs_val, 1)}; // Dezena
        message[25] = {1'b1, get_digit(abs_val, 0)}; // Unidade
    end

    // -----------------------------------------------------------------------
    // Temporizações e Estados
    // -----------------------------------------------------------------------
    localparam [31:0] DELAY_WRITE = 32'd2000;  // ~40 us
    localparam [31:0] DELAY_PULSE = 32'd50;    // ~1 us

    localparam [2:0] S_WAIT_INIT = 3'd0, S_IDLE = 3'd1, S_PREPARE = 3'd2, S_PULSE_E = 3'd3, S_WAIT = 3'd4, S_DONE = 3'd5;
        
    reg [2:0]  state, next_state;
    reg [31:0] delay_cnt, next_delay_cnt;
    reg [5:0]  msg_index, next_msg_index; // Aumentado para 6 bits pois vai até 33

    assign ocupado = (start || state == S_WAIT_INIT || state == S_PREPARE || state == S_PULSE_E || state == S_WAIT);

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state        <= S_WAIT_INIT;
            delay_cnt    <= 32'd0;
            msg_index    <= 6'd0;
            latched_dado <= 16'd0;
            latched_opcode <= 3'd0;
            latched_addr   <= 4'd0;
        end else begin
            state        <= next_state;
            delay_cnt    <= next_delay_cnt;
            msg_index    <= next_msg_index;
            
            if (state == S_IDLE && start) begin
                latched_dado   <= dado_ula;
                latched_opcode <= opcode;
                latched_addr   <= addr_wr;
            end
        end
    end

    always @(*) begin
        next_state     = state;
        next_delay_cnt = delay_cnt;
        next_msg_index = msg_index;

        case (state)
            S_WAIT_INIT: if (init_done) begin next_state = S_IDLE; next_msg_index = 6'd0; end
            S_IDLE:      if (start) begin next_state = S_PREPARE; next_msg_index = 6'd0; end
            S_PREPARE:   begin next_state = S_PULSE_E; next_delay_cnt = DELAY_PULSE; end
            S_PULSE_E:   if (delay_cnt > 0) next_delay_cnt = delay_cnt - 1; else begin next_state = S_WAIT; next_delay_cnt = DELAY_WRITE; end
            S_WAIT:      if (delay_cnt > 0) next_delay_cnt = delay_cnt - 1; else if (msg_index == (MSG_LEN-1)) next_state = S_DONE; else begin next_msg_index = msg_index + 1; next_state = S_PREPARE; end
            S_DONE:      next_state = S_IDLE; 
            default:     begin next_state = S_WAIT_INIT; next_delay_cnt = 32'd0; next_msg_index = 6'd0; end
        endcase
    end

    // -----------------------------------------------------------------------
    // Sinais Físicos
    // -----------------------------------------------------------------------
    reg [7:0] wr_data; reg wr_rs; reg wr_rw; reg wr_e;

    always @(*) begin
        start_init = (state == S_WAIT_INIT) ? 1'b1 : 1'b0;
        wr_data = 8'h00; wr_rs = 1'b0; wr_rw = 1'b0; wr_e  = 1'b0;
        
        case (state)
            S_PREPARE: begin wr_data = message[msg_index][7:0]; wr_rs = message[msg_index][8]; wr_rw = 1'b0; wr_e = 1'b0; end
            S_PULSE_E: begin wr_data = message[msg_index][7:0]; wr_rs = message[msg_index][8]; wr_rw = 1'b0; wr_e = 1'b1; end
            S_WAIT:    begin wr_data = message[msg_index][7:0]; wr_rs = message[msg_index][8]; wr_rw = 1'b0; wr_e = 1'b0; end
            default:   begin wr_rs = 1'b0; wr_rw = 1'b0; wr_e = 1'b0; wr_data = 8'h00; end
        endcase
    end
endmodule