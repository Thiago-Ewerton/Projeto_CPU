<<<<<<< HEAD
module cpu (
    // Entradas Físicas (Placa)
    input clk,
    input power,        // Botão Ligar/Desligar
    input enviar,       // Botão Enviar

    // Switches
    input [2:0] opcode,           // 3 bits para a operação
    input [3:0] reg_um,           // 4 bits (Geralmente o Destino)
    input [3:0] reg_dois,         // 4 bits (Geralmente a Fonte 1)
    input [6:0] reg_tres_ou_imm,  // 7 bits (Pode ser o Reg 3 [3:0] ou o Sinal + Imediato [6:0])

    // Saídas Físicas (Para controlar o LCD da Placa)
    output [7:0] lcd_dados,
    output RS,
    output RW,
    output enable,
	 output lcd_on,      
    output lcd_blon     
);
    
    reg signed [15:0] imd;
    
    // Sinais de controle internos para ligar na RAM e ULA
    reg [3:0] addr_rd1, addr_rd2, addr_wr;
    reg signed [15:0] dado_para_memoria;
    reg [1:0] estado_modo_mem;
	 reg lcd_start;
    wire lcd_ocupado;
    
    wire signed [15:0] resultado_ula;
    reg signed [15:0] ula_operando_b;
    
    wire [15:0] data_out1_mem, data_out2_mem;
	 assign lcd_on = 1'b1;    // Display sempre energizado
    assign lcd_blon = 1'b1;  // Luz sempre acesa

    // Parâmetros dos Opcodes (Instruções)
    parameter load    = 3'b000,
              add     = 3'b001,
              addi    = 3'b010,
              sub     = 3'b011,
              subi    = 3'b100,
              mul     = 3'b101,
              clear   = 3'b110,
              display = 3'b111;
                    
    // Parâmetros dos Estados da FSM
    parameter espera        = 3'd0,
              ler_ram       = 3'd1,
              acessar_ula   = 3'd2,
              escrever_ram  = 3'd3,
              atualizar_lcd = 3'd4;
                    
    reg [2:0] estado = espera;
    
    reg enviar_anterior;
    wire enviar_solto = (enviar_anterior == 1'b0 && enviar == 1'b1);
    
 
    always @ (*) begin
        if (opcode == load || opcode == addi || opcode == subi || opcode == mul) begin
        // Tradução de Sinal-Magnitude para Complemento de Dois (16 bits)
        if (reg_tres_ou_imm[6] == 1'b1) begin
            imd = -{10'b0, reg_tres_ou_imm[5:0]}; // Sinal negativo
        end else begin
            imd = {10'b0, reg_tres_ou_imm[5:0]};  // Sinal positivo
        end
			  addr_rd2 = 4'b0000;
		 end else begin
			  imd = 16'sd0;
			  addr_rd2 = reg_tres_ou_imm[6:3];
		 end
    end
    
    always @ (posedge clk) begin
        enviar_anterior <= enviar; 
        
        if (power == 1'b0) begin
            estado <= espera;
            estado_modo_mem <= 2'b10;
        end 
        else begin
            case(estado) 
                espera: begin
                    if(enviar_solto) begin
                        
                        estado <= ler_ram;
                        if(opcode == clear)
                            estado_modo_mem <= 2'b10; 
                    end
                    else begin
                        estado <= espera;
                    end
                end
                
                ler_ram: begin
                    
						  if(opcode == display)
								addr_rd1 <= reg_um;
						  else
								addr_rd1 <= reg_dois;
                    estado_modo_mem <= 2'b00;       
                    estado <= acessar_ula;
                end
                
                acessar_ula: begin
                    if (opcode == addi || opcode == subi || opcode == mul)
                        ula_operando_b <= imd; 
                    else
                        ula_operando_b <= data_out2_mem;
                    
                    estado <= escrever_ram;
                end
                
                escrever_ram: begin
                    addr_wr <= reg_um;
                    if(opcode == load)
                        dado_para_memoria <= imd; 
                    
                    if(opcode == add || opcode == addi || opcode == sub || opcode == subi || opcode == mul)
                        dado_para_memoria <= resultado_ula;
							
							if(opcode == clear)
								dado_para_memoria <= 16'sh0000;
                        
                    if(opcode == display)
                        dado_para_memoria <= data_out1_mem;
                        
                    if(opcode == display)
                        estado_modo_mem <= 2'b00;
                    else
                        estado_modo_mem <= 2'b01;
								
						  lcd_start <= 1'b1;
                    estado <= atualizar_lcd;  
                end
                
                atualizar_lcd: begin
                  estado_modo_mem <= 2'b00; 
                
                    if (lcd_ocupado == 1'b1) begin
                        lcd_start <= 1'b0;
                    end
						  
                    if (lcd_start == 1'b0 && lcd_ocupado == 1'b0) begin
                        estado <= espera;
                    end
                end
                
                default: estado <= espera;
            endcase
        end
    end
    
    
    memoria16_16 registrar (
        .clk(clk),
        .estado_modo(estado_modo_mem),
        .addr_rd1(addr_rd1),
        .addr_rd2(addr_rd2),
        .addr_wr(addr_wr),
        .data_in(dado_para_memoria),   
        .data_out1(data_out1_mem),
        .data_out2(data_out2_mem)
    );

    ULA operar (
        .operand_a(data_out1_mem),  
        .operand_b(ula_operando_b),  
        .opcode(opcode),             
        .result(resultado_ula)         
    );
	 
	 wire rst_lcd = ~power; 

    lcd_controller_top tela_placa (
        .clk(clk),
        .rst(rst_lcd),
        .start(lcd_start),             
        .opcode(opcode),               
        .addr_wr(addr_wr),            
        .dado_ula(dado_para_memoria),      
        .ocupado(lcd_ocupado),         
        
        .lcd_data(lcd_dados),          
        .lcd_rs(RS),                   
        .lcd_rw(RW),                   
        .lcd_e(enable)                 
    );
=======
module cpu (
    // Entradas Físicas (Placa)
    input clk,
    input power,        // Botão Ligar/Desligar
    input enviar,       // Botão Enviar

    // Switches
    input [2:0] opcode,           // 3 bits para a operação
    input [3:0] reg_um,           // 4 bits (Geralmente o Destino)
    input [3:0] reg_dois,         // 4 bits (Geralmente a Fonte 1)
    input [6:0] reg_tres_ou_imm,  // 7 bits (Pode ser o Reg 3 [3:0] ou o Sinal + Imediato [6:0])

    // Saídas Físicas (Para controlar o LCD da Placa)
    output [7:0] lcd_dados,
    output RS,
    output RW,
    output enable,
	 output lcd_on,      
    output lcd_blon     
);
    
    reg signed [6:0] imd;
    
    // Sinais de controle internos para ligar na RAM e ULA
    reg [3:0] addr_rd1, addr_rd2, addr_wr;
    reg [15:0] dado_para_memoria;
    reg [1:0] estado_modo_mem;
	 reg lcd_start;
    wire lcd_ocupado;
    
    wire signed [15:0] resultado_ula;
    reg signed [15:0] ula_operando_b;
    
    wire [15:0] data_out1_mem, data_out2_mem;
	 assign lcd_on = 1'b1;    // Display sempre energizado
    assign lcd_blon = 1'b1;  // Luz sempre acesa

    // Parâmetros dos Opcodes (Instruções)
    parameter load    = 3'b000,
              add     = 3'b001,
              addi    = 3'b010,
              sub     = 3'b011,
              subi    = 3'b100,
              mul     = 3'b101,
              clear   = 3'b110,
              display = 3'b111;
                    
    // Parâmetros dos Estados da FSM
    parameter espera        = 3'd0,
              ler_ram       = 3'd1,
              acessar_ula   = 3'd2,
              escrever_ram  = 3'd3,
              atualizar_lcd = 3'd4;
                    
    reg [2:0] estado = espera;
    
    reg enviar_anterior;
    wire enviar_solto = (enviar_anterior == 1'b0 && enviar == 1'b1);
    
 
    always @ (*) begin
        if (opcode == load || opcode == addi || opcode == subi || opcode == mul) begin
            imd = reg_tres_ou_imm[6:0];
            addr_rd2 = 4'b0000;
        end else begin
            imd = 7'b0000000;
            addr_rd2 = reg_tres_ou_imm[3:0];
        end 
    end
    
    always @ (posedge clk) begin
        enviar_anterior <= enviar; 
        
        if (power == 1'b0) begin
            estado <= espera;
            estado_modo_mem <= 2'b10;
        end 
        else begin
            case(estado) 
                espera: begin
                    if(enviar_solto) begin
                        
                        estado <= ler_ram;
                        if(opcode == clear)
                            estado_modo_mem <= 2'b10; 
                    end
                    else begin
                        estado <= espera;
                    end
                end
                
                ler_ram: begin
                    addr_rd1 <= reg_dois;  
                    estado_modo_mem <= 2'b00;       
                    estado <= acessar_ula;
                end
                
                acessar_ula: begin
                    if (opcode == addi || opcode == subi || opcode == mul)
                        ula_operando_b <= {{9{imd[6]}}, imd}; 
                    else
                        ula_operando_b <= data_out2_mem;
                    
                    estado <= escrever_ram;
                end
                
                escrever_ram: begin
                    addr_wr <= reg_um;
                    if(opcode == load)
                        dado_para_memoria <= {{9{imd[6]}}, imd}; 
                    
                    if(opcode == add || opcode == addi || opcode == sub || opcode == subi || opcode == mul)
                        dado_para_memoria <= resultado_ula; 
                        
                    estado_modo_mem <= 2'b01;
						  lcd_start <= 1'b1;
                    estado <= atualizar_lcd;  
                end
                
                atualizar_lcd: begin
                   estado_modo_mem <= 2'b00; 
                    lcd_start <= 1'b0;
                    if (lcd_ocupado == 1'b0) begin
                        estado <= espera;
                    end
                end
                
                default: estado <= espera;
            endcase
        end
    end
    
    
    memoria16_16 registrar (
        .clk(clk),
        .estado_modo(estado_modo_mem),
        .addr_rd1(addr_rd1),
        .addr_rd2(addr_rd2),
        .addr_wr(addr_wr),
        .data_in(dado_para_memoria),   
        .data_out1(data_out1_mem),
        .data_out2(data_out2_mem)
    );

    ULA operar (
        .operand_a(data_out1_mem),  
        .operand_b(ula_operando_b),  
        .opcode(opcode),             
        .result(resultado_ula)         
    );
	 
	 wire rst_lcd = ~power; 

    lcd_controller_top tela_placa (
        .clk(clk),
        .rst(rst_lcd),
        .start(lcd_start),             
        .opcode(opcode),               
        .addr_wr(addr_wr),            
        .dado_ula(resultado_ula),      
        .ocupado(lcd_ocupado),         
        
        .lcd_data(lcd_dados),          
        .lcd_rs(RS),                   
        .lcd_rw(RW),                   
        .lcd_e(enable)                 
    );
>>>>>>> 3edc9c0636a6aec0612b93f8ff7bca3d9b756cff
endmodule