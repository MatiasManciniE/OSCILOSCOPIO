`timescale 1ns / 1ps

module Uart_tx(
    input clk_64,
    input locked,
    input reset,
    input [7:0] dato_i,     //Byte a transmitir 
    input start_i,          //Pulso para enviar el byte
    output dato_o);         //Trama codificada para enviar al transmisor de la UART

reg flag;           //Indica que recibi el bit de start
reg [4:0] k;        //contador interno para enviar datos     
reg bit_actual;     //bit que estoy enviando
reg flag_start;     //flag para evitar que se envien varios bit de start al comienzo
reg [6:0] contador; //contador para enviar un bit con una duracion de tiempo adecuada

always @(posedge clk_64) begin
    if (~locked || reset) begin
        flag <= 0;
        k <= 0;
        contador <= 0;
        flag_start <= 1;    //1 indica que necesito mandar el bit de Start
        bit_actual <= 1; 
    end  
    else begin
        if (start_i)  //Si recibi un pulso, empiezo a enviar
            flag <= 1;                 
        if (flag) begin
            contador <= contador+1;
            if (flag_start && contador < 63) 
                bit_actual <= 0;        //Bit de start
            if (flag_start && contador == 63) begin                     
                flag_start <= 0;
                contador <= 0;         //Recibi el bit de Start
            end    
            if (flag_start == 0) begin                
                if (contador < 63 && k < 11)    //Envio todos los demas datos
                    bit_actual <= dato_i[k];
                if (k < 11 && contador == 63) begin
                    k <= k + 1;
                    contador <= 0;
                end    
                if (k == 8 && contador < 63)    //Bit de paridad
                    bit_actual <= ^(dato_i);    //0 si es par, 1 si es impar
                if (k == 8 && contador == 63) begin        
                    k <= k + 1;
                    contador <= 0;       
                end
                if (k == 9 && contador < 63)   //Bit de Stop                     
                    //bit_actual = 1;
                    bit_actual <= 1;
                if (k == 9 && contador == 63) begin
                    bit_actual <= 1;                                                   
                    k <= 0;                    //Reiniciamos las variables para enviar otro dato
                    flag_start <= 1;
                    flag <= 0;
                end
            end     
        end                       
    end        
end    

assign dato_o = (flag == 1)? bit_actual : 1;    
         
endmodule
