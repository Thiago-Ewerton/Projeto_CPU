module cpu (
	
	 // Entradas Físicas (Placa)
    input clk,
    input power,        // Botão Ligar/Desligar
    input enviar,       // Botão Enviar

    // Switches divididos para facilitar a codificação (Baseado nas imagens do PDF)
    input [2:0] opcode,           // 3 bits para a operação
    input [3:0] reg_um,           // 4 bits (Geralmente o Destino)
    input [3:0] reg_dois,         // 4 bits (Geralmente a Fonte 1)
    input [6:0] reg_tres_ou_imm,  // 7 bits (Pode ser o Reg 3 [3:0] ou o Sinal + Imediato [6:0])

    // Saídas Físicas (Para controlar o LCD da Placa)
    output [7:0] lcd_dados,
    output RS,
    output RW,
    output enable,

    // Comunicação com a Memória (memory.v)
    output [3:0] endereco_memoria, // Exatamente os 4 bits que você mencionou (acessa os 16 locais)
    output [15:0] dado_para_memoria, // Os 16 bits do valor a ser guardado no local
    output mem_write_enable,      // 1 bit para dizer à memória se é operação de Escrita (1) ou Leitura (0)
    input [15:0] dado_da_memoria, // 16 bits do valor devolvido pela memória após uma leitura

    // Comunicação com a ULA (module_alu.v)
    output [15:0] ula_operando_1, // 16 bits enviados para o primeiro operando da conta
    output [15:0] ula_operando_2, // 16 bits enviados para o segundo operando da conta
    output [2:0] ula_seletor,     // O próprio opcode repassado para a ULA saber qual conta fazer
    input  [15:0] ula_resultado    // 16 bits com o resultado da conta feita pela ULA
	 
	 );
	
	reg sinal;
	reg [5:0] imd;
	reg [3:0] acessar_endereco;
	
	parameter  load    = 3'b000,
				add     = 3'b001,
				addi    = 3'b010,
				sub     = 3'b011,
				subi    = 3'b100,
				mul     = 3'b101,
				clear   = 3'b110,
				display = 3'b111;
	
	always @ (negedge clk, negedge enviar) begin
		case (opcode)
			   load:  begin
					sinal = reg_tres_ou_imm[6];
					imd 	= reg_tres_ou_imm[5:0];
				end
				
				add: acessar_endereco = reg_tres_ou_imm[6:3];
				
				addi: begin
					sinal = reg_tres_ou_imm[6];
					imd 	= reg_tres_ou_imm[5:0];
				end
				
				sub: acessar_endereco = reg_tres_ou_imm[6:3];
				
				subi:  begin
					sinal = reg_tres_ou_imm[6];
					imd 	= reg_tres_ou_imm[5:0];
				end
				
				mul:  begin
					sinal = reg_tres_ou_imm[6];
					imd 	= reg_tres_ou_imm[5:0];
				end
				
				clear:;
				display:;
		endcase
	end

endmodule