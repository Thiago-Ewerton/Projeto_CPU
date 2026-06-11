// ============================================================================
// Módulo: memoria16_16
// Descrição: Banco de registradores/RAM contendo 16 posições de 16 bits cada.
//            Controlado por uma máquina de estados/comandos simples.
// ============================================================================

module memoria16_16 (
    input wire        clk,          // Clock do sistema
    input wire [1:0]  estado_modo,  // Seleciona o estado: 00=Read, 01=Write, 10=Clear
    input wire [3:0]  addr_rd1,     // Endereço de leitura do Registrador 1 (Src1)
    input wire [3:0]  addr_rd2,     // Endereço de leitura do Registrador 2 (Src2)
    input wire [3:0]  addr_wr,      // Endereço de escrita do Registrador (Destino)
    input wire [15:0] data_in,      // Dado de entrada a ser salvo (ULA ou Imediato)
    
    output reg [15:0] data_out1,    // Saída do dado do Registrador 1 para a ULA
    output reg [15:0] data_out2     // Saída do dado do Registrador 2 para a ULA
);

    // 1. Criação da matriz de memória
    reg [15:0] registradores [0:15];

    // 2. Definição dos Estados 
    localparam STATE_READ  = 2'b00;
    localparam STATE_WRITE = 2'b01;
    localparam STATE_CLEAR = 2'b10;

    // 3. Lógica Sequencial da Máquina de Estados da Memória
    always @(posedge clk) begin
        case (estado_modo)
            
            STATE_READ: begin
                
                // Busca os valores guardados nos endereços solicitados e joga nas saídas
                data_out1 <= registradores[addr_rd1];
                data_out2 <= registradores[addr_rd2];
            end

            STATE_WRITE: begin
                
                // Grava o valor de 'data_in' na posição indicada por 'addr_wr'
                registradores[addr_wr] <= data_in;
            end

            STATE_CLEAR: begin
                
                // Zera a memoria
                    registradores[0]  <= 16'h0000;
                    registradores[1]  <= 16'h0000;
                    registradores[2]  <= 16'h0000;
                    registradores[3]  <= 16'h0000;
                    registradores[4]  <= 16'h0000;
                    registradores[5]  <= 16'h0000;
                    registradores[6]  <= 16'h0000;
                    registradores[7]  <= 16'h0000;
                    registradores[8]  <= 16'h0000;
                    registradores[9]  <= 16'h0000;
                    registradores[10] <= 16'h0000;
                    registradores[11] <= 16'h0000;
                    registradores[12] <= 16'h0000;
                    registradores[13] <= 16'h0000;
                    registradores[14] <= 16'h0000;
                    registradores[15] <= 16'h0000;
            end

            default: begin
                // Estado Neutro: 
                data_out1 <= 16'h0000;
                data_out2 <= 16'h0000;
            end
            
        endcase
    end

endmodule
