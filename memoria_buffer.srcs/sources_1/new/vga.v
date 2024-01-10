`timescale 1ns / 1ps

module vga (
        input clk,
        input reset,
        input locked,
        input [8:0] mem_ram,    //dato leido de la memoria a pintar dentro de la pantalla
        input canal_selector,   
        input [2:0] tr_level,   //entrada para ajustar el trigger (visualmente) en la pantalla
        input tr_active,        //entrada para mostrar o no el trigger en pantalla
        output [9:0] address_ram,   //direccion a leer en memoria para luego pintar en pantalla
        output hs,              //horizontal sync
        output vs,              //vertical sync
        output [3:0] r,         
        output [3:0] g,
        output [3:0] b
    );


//800x600 60hz

///////////////////////////////////////////////
//////////////  Parametros  ///////////////////
///////////////////////////////////////////////

//TOTAL_H
//Cantidad total de pulsos de clock en horizontal
//ACTIVE + FP + BP + PW
//  800  + 40 + 88 + 128 
localparam TOTAL_H = 1056;

//TOTAL_V
//Cantidad total de pulsos de clock en vertical
//ACTIVE + FP + BP + PW
//  600  + 1  + 23 +  4 
localparam TOTAL_V = 628;

//ACTIVE_H
localparam ACTIVE_H = 800;

//ACTIVE_V
localparam ACTIVE_V = 600;

//H_PULSO
//A partir de donde debo enviar el pulso horizontal en bajo
//ACTIVE + FP + BP
//  800  + 40 + 88
localparam H_PULSO = 928;

//V_PULSO
//A partir de donde debo enviar el pulso vertical en bajo
//ACTIVE + FP + BP
//  600  + 1  + 23 
localparam V_PULSO = 624;

//Contadores 
reg [10:0] h_cont;
reg [9:0] v_cont;

//Indicadores dentro de la region activa
reg [9:0] h_active;
reg [9:0] v_active;
 
//Indica si estoy dentro de la parte ACTIVE (Para poder colorear la pantalla) 
reg in_active;

//Auxiliares para ir cambiando colores dentro del always
reg [3:0] r_a;
reg [3:0] g_a;
reg [3:0] b_a;

//Valor del pixel anterior para utilizar en la interpolacion
reg [9:0] val_anterior;

//Registro auxiliar para copiar datos de memoria en always
reg [10:0] aux_mem_ram;
 
//Contadores para ir colocando los colores en la pantalla
//Una vez terminada la cuenta horizontal, empiezo con la cuenta vertical
always @(posedge clk) begin
    if (reset || ~locked) begin
        h_cont <= 0;
        v_cont <= 0;
        h_active <= 0;
    end else begin
        if (h_cont < TOTAL_H - 1)begin 
            h_cont <= h_cont + 1;
            h_active <= ( h_cont>= 88 &&  h_cont< 888)? h_active + 1 : 0;
            end
        else begin
            h_cont <= 0;
            if (v_cont < TOTAL_V - 1) begin
                v_cont <= v_cont + 1;
                v_active <= ( v_cont>= 24 &&  v_cont< 624)? v_active + 1 : 0;
            end else
                v_cont <= 0;
        end  
    end
end

assign vs = (v_cont < V_PULSO)? 1 : 0;
assign hs = (h_cont < H_PULSO)? 1 : 0;

//Centrar la imagen (Sumas los BP):
//BPh = 88
//BPv = 23

/*
<----BP----><------------------ACTIVE---------------------><----FP---->
                                                                       <----PW---->

https://web.mit.edu/6.111/www/s2004/NEWKIT/vga.shtml                                                                    
*/

//Definimos la parte activa para pintar la pantalla
always @(posedge clk) begin
    if (reset || ~locked) begin
        in_active <= 0;
    end else begin
        if ((h_cont < ACTIVE_H + 88) && (v_cont < ACTIVE_V + 23) &&
            (h_cont >= 88) && (v_cont >= 23))
            in_active <= 1;
        else 
            in_active <= 0;
    end
end

always @(posedge clk) begin
    if (reset || ~locked) begin
        r_a <= 0;
        g_a <= 0;
        b_a <= 0;
        val_anterior <= mem_ram;
    end else begin
        if (in_active) begin
        //Segun el orden de los Case, primero se pinta horizontal y despues se pinta encima el vertical
        //Pintar el fondo fuera de la grilla vertical
            if (v_cont >= 67 && v_cont <= 580) begin
                case (h_cont)
                    //Grilla vertical
                    168,248,328,408,488,568,648,728,808: begin   //Cada 80 pixeles, una linea de la grilla
                            r_a <= 4'hF;                         //Sumar 88 para centrarla en la pantalla
                            g_a <= 4'hF;
                            b_a <= 4'hF;               
                        end
                        //Pinta el fondo gris
                        default : begin
                            r_a <= 4'h9;
                            g_a <= 4'h9;
                            b_a <= 4'h9;
                        end
                endcase
            end
            else begin      //Margenes fuera de la grilla vertical
                r_a <= 4'h9;
                g_a <= 4'h9;
                b_a <= 4'h9;                
            end    
            case (v_cont)                      
                //Grilla Horizontal
                //Centrada en 300, 256 pixeles hacia arriba y hacia abajo
                //Los 88 pixeles sobrantes (44 arriba y abajo) son para escribir informacion en pantalla
                //Sumar 23 del BP
                67,118,169,220,271,323,374,425,476,528,580: begin                
                    r_a <= 4'hF;
                    g_a <= 4'hF;
                    b_a <= 4'hF;
                end              
                //No hacer nada si no cae en el case, porque si no re-pintamos y borramos lo anterior 
                default : begin end
            endcase
            
            //Trigger Level
            if (tr_active) begin
                case (tr_level)
                    //0 + 44 para ingresar dentro de la grilla
                    4:  if (v_active == 44 || v_active == 45) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end
                    //128 + 44 para ingresar dentro de la grilla
                    3:  if (v_active == 172 || v_active == 173) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end
                    //256 + 44 para ingresar dentro de la grilla
                    2:  if (v_active == 300 || v_active == 301) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end
                    //384 + 44 para ingresar dentro de la grilla
                    1:  if (v_active == 428 || v_active == 429) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end
                    //512 + 44 para ingresar dentro de la grilla
                    0:  if (v_active == 556 || v_active == 557) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end    
                    default : begin end
                endcase    
            end
                       
            //Indicador de canal dentro de la pantalla
            if (canal_selector) begin
            //Canal 1
            //Lineas Horizontales
                if (v_active == 11 && h_active >= 80 && h_active < 92) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                if (v_active == 11 && h_active >= 113 && h_active < 119) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                if (v_active == 33 && h_active >= 80 && h_active < 92) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                if (v_active == 33 && h_active >= 113 && h_active < 125) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                if (v_active == 22 && h_active >= 97 && h_active < 109) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
            //Lineas Verticales    
                if (v_active >= 11 && v_active <= 33 && h_active == 80) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end 
                if (v_active >= 11 && v_active <= 33 && h_active == 97) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                if (v_active >= 11 && v_active <= 33 && h_active == 108) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end  
                if (v_active >= 11 && v_active <= 33 && h_active == 118) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end       
            end
            else begin
            //Canal 2
            //Lineas Horizontales
                if (v_active == 11 && h_active >= 480 && h_active < 492) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active == 11 && h_active >= 513 && h_active < 525) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active == 33 && h_active >= 480 && h_active < 492) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active == 33 && h_active >= 513 && h_active < 525) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active == 22 && h_active >= 497 && h_active < 509) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active == 22 && h_active >= 513 && h_active < 525) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
            //Lineas Verticales    
                if (v_active >= 11 && v_active <= 33 && h_active == 480) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end 
                if (v_active >= 11 && v_active <= 33 && h_active == 497) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
                if (v_active >= 11 && v_active <= 33 && h_active == 508) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end  
                if (v_active >= 11 && v_active <= 22 && h_active == 524) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end 
                if (v_active >= 22 && v_active <= 33 && h_active == 513) begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end       
            end
                                           
            
/////////////////////////////////////////////////////////////////////////////////
///////////////////     Graficar resultados desde la memoria    /////////////////
/////////////////////////////////////////////////////////////////////////////////
           
            //Restamos a 512 para que el cero quede en la parte de abajo de la grilla y no arriba
            //Sumamos 68 para que grafique dentro de la grilla y no en los margenes que estan por fuera
            //Al restar a 512, no es necesario sumar una cantidad extra a los valores, ya que se acomodan solos
            aux_mem_ram <= (512 - mem_ram) + 68;
            if (h_active == 0 && v_cont == aux_mem_ram) begin 
                if (canal_selector) begin
                    r_a <= 4'h0;
                    g_a <= 4'h0;
                    b_a <= 4'hF;
                end
                else begin
                    r_a <= 4'hF;
                    g_a <= 4'h0;
                    b_a <= 4'h0;
                end
            end
            //Casos distintos al primer valor        
            else begin    
                if (aux_mem_ram < val_anterior) begin
                    if ((v_cont >= aux_mem_ram) && (v_cont < val_anterior)) begin
                        if (canal_selector) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'hF;
                        end
                        else begin
                            r_a <= 4'hF;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end    
                    end
                end
                else if (aux_mem_ram >= val_anterior) begin
                    if ((v_cont >= val_anterior) && (v_cont <= aux_mem_ram)) begin
                        if (canal_selector) begin
                            r_a <= 4'h0;
                            g_a <= 4'h0;
                            b_a <= 4'hF;
                        end
                        else begin
                            r_a <= 4'hF;
                            g_a <= 4'h0;
                            b_a <= 4'h0;
                        end  
                    end
                end
            end    
        //actualizo el valor anterior para el proximo pixel        
        val_anterior <= aux_mem_ram;
        end  //(end if(in_active))                   
        //Si no estamos dentro de la parte ACTIVE, no enviar colores   
        else begin   
            r_a <= 4'h0;
            g_a <= 4'h0;
            b_a <= 4'h0;
        end    
    end     //end if(reset || ~locked) 
end    

assign address_ram = h_active;

assign r = r_a;
assign g = g_a;
assign b = b_a;
        
endmodule