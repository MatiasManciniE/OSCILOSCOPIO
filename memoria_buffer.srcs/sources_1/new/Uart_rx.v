`timescale 1ns / 1ps

module Uart_rx(
    input  rxd_i,   //Trama recibida por la UART
    input  reset, 
    input  locked,  //sale de mi PLL
    input  clk_64,  //salida de mi PLL, mi clock principal
    output [7:0] datos_recibido_o,  //Dato procesado en 8 bits
    output pulso            //Pulso habilitador para usar en otros modulos
    );

reg [8:0] datos_recibido_aux;   //Registro para procesar la trama dentro del always
integer contador;               //32 bits
reg flag_1;                     //Indica que se recibio el bit de Start
reg flag_2;                     //Indica que la paridad es correcta
reg flag_3;                     //Indica que se recibio el bit de Stop
reg [4:0] k;                    //Cantidad de elementos que guardo en mi vector (8 datos + bit de paridad)
reg trama_ok;                   //Flag para prender LEDs y reiniciar registros
reg pulso_salida;               //Registro para sacar un pulso al final

integer sub_cont;               //Subcontador para verificar que la primera mitad 
                                //del bit de Start esta compuesto por todos ceros y no
                                //es ruido  

always @(posedge clk_64) begin
    if (reset || ~locked) begin
        flag_1 <=0; //Flag que se activa con el bit Start
        flag_2 <=0; //Flag que se activa con el bit paridad
        flag_3 <=0; //Flag que se activa con el bit Stop
        k<=9;       //Inicializo en 9 porque empiezo restando 1, de esa manera tengo 8 subindices para los vectores 
        contador<=0;
        datos_recibido_aux<=0;
        trama_ok <= 0;
        sub_cont <= 0;   
        pulso_salida <=0;
    end else begin      
        if (flag_1 == 0 && ~rxd_i) begin
            contador <= contador + 1; //inicializo contador
            if (~rxd_i && contador<33)
                sub_cont <= sub_cont + 1;
            if (contador==32 && sub_cont==32) //Cuando se llega a 32 y sigue estando el bit de start, levanto una flag
            begin
                flag_1 <= 1; 
                contador <= 0;
                sub_cont <= 0;
                datos_recibido_aux <= 0;  //Reinicio el valor del registro auxiliar para recibir una trama
                trama_ok <= 0; //Reinicio el registro que indica que ya tengo el dato recibido listo
            end
            if (contador==32 && sub_cont!=31) begin //Encontre ruido, ACA VA UN ELSE DEL 1er IF!!
                contador <= 0;
                sub_cont <= 0;
            end        
        end 
        if (flag_1)
        begin
            contador <= contador + 1;         //inicializo contador
            if (contador==64 && k>0 && k<=9) //Voy llenando el vector con los datos
            begin
                datos_recibido_aux[k-1]<=rxd_i;
                k<=k-1;
                contador <=0;
            end
            if (k==0)
            begin
                if(~^datos_recibido_aux) begin //Se corrobora el bit de paridad
                    flag_2<=1;
                end//agregar un else para reset    
            end
            if (contador==64 && rxd_i && flag_2) begin //Se corrobora el bit de stop 
                flag_3<=1;
                contador <= 0;
            end       
            if (flag_3) begin            
                trama_ok <= 1; //Aviso que la trama recibida es correcta
                pulso_salida <= 1;        
            end                    
            if (trama_ok == 1) begin
                flag_1 <= 0;
                flag_2 <= 0;
                flag_3 <= 0;    //Reiniciamos todo para recibir otra trama nueva
                k <= 9;
                contador <= 0;
                pulso_salida <= 0;
            end                
        end
    end    
end         

//Los guardo espejados porque recibi el LSB primero y el MSB al ultimo
//El bit de paridad ya no me interesa, asique no lo guardo  
assign datos_recibido_o[0] = (trama_ok)? datos_recibido_aux[8] : 0;
assign datos_recibido_o[1] = (trama_ok)? datos_recibido_aux[7] : 0;
assign datos_recibido_o[2] = (trama_ok)? datos_recibido_aux[6] : 0;
assign datos_recibido_o[3] = (trama_ok)? datos_recibido_aux[5] : 0;
assign datos_recibido_o[4] = (trama_ok)? datos_recibido_aux[4] : 0;
assign datos_recibido_o[5] = (trama_ok)? datos_recibido_aux[3] : 0;
assign datos_recibido_o[6] = (trama_ok)? datos_recibido_aux[2] : 0;
assign datos_recibido_o[7] = (trama_ok)? datos_recibido_aux[1] : 0;  //Guardo todos menos el bit menos significativo para obviar pariedad

assign pulso = pulso_salida; 

endmodule
