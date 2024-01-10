`timescale 1ns / 1ps

module adaptador(
    input clk,
    input reset,
    input locked,
    //input tiempo,
    input [15:0] dato_entrada,  //Del ADC 1 salen 16 bits, solo me interesan los 12 MSB
    input [2:0] voltdiv,
    input [2:0] tiempo, 
    output [11:0] dir_entrada,
    output reg [8:0] dato_salida,
    output [9:0] dir_salida
    );
 
reg [11:0] cont;
reg [15:0] dato_aux_16;
reg [9:0] cont_salida;
reg [15:0] dato_anterior;

reg [2:0] t_ant; 

always @(posedge clk) begin
    if (reset || ~locked) begin
        dato_aux_16 <= 0;
        cont <= 0;
        cont_salida <= 0;
        dato_salida <= 0;
        dato_anterior <= 0;       
    end
    else begin
        cont_salida <= (cont_salida != 799)? cont_salida + 1 : 0;
        //Se escoge con cual de los dos canales nos quedamos en pantalla:
        dato_aux_16 <= dato_entrada;     
        case (voltdiv)
            7: dato_salida <= dato_aux_16[15:14];   //12.8  
            6: dato_salida <= dato_aux_16[15:13];   //6.4
            5: dato_salida <= dato_aux_16[15:12];   //3.2
            4: dato_salida <= dato_aux_16[15:11];   //1.6
            3: dato_salida <= dato_aux_16[15:10];   //0.8
            2: dato_salida <= dato_aux_16[15:9];    //0.4
            1: dato_salida <= dato_aux_16[15:8];    //0.2
            0: dato_salida <= dato_aux_16[15:7];    //0.1
            default: begin end
        endcase
        if (tiempo != t_ant)
            cont <= 0;
        case (tiempo)
            7: cont <= (cont < 3995)? cont + 5 : 0;
            6: cont <= (cont < 3990)? cont + 10 : 0;
            5: cont <= (cont < 3980)? cont + 20 : 0;  
            4: cont <= (cont < 3975)? cont + 25 : 0;   
            3: cont <= (cont < 3960)? cont + 40 : 0;   
            2: cont <= (cont < 3950)? cont + 50 : 0;   
            1: cont <= (cont < 3920)? cont + 80 : 0;    
            0: cont <= (cont < 3900)? cont + 100 : 0;    
            default: begin end
        endcase
        dato_anterior <= dato_aux_16;
        t_ant <= tiempo;    
    end    
end
    
assign dir_entrada = cont;  
assign dir_salida = cont_salida;
    
endmodule

