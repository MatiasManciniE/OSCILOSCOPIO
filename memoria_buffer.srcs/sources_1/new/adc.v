`timescale 1ns / 1ps

module adc(
    input clk,
    input reset,
    input locked,
    input vauxp6,            // input wire vauxp6
    input vauxn6,            // input wire vauxn6
    input vauxp14,          // input wire vauxp14
    input vauxn14,          //input wire vauxn14
    input canal_selector,
    input [2:0] tr_level,
    input tr_active,
    output reg [15:0] dato_canal_1,
    output reg [11:0] address
    );

reg [6:0] canal;            //canal utilizado en el adc (direccion)
wire ready;                 //dato_ready del adc
reg [15:0] dato_adc;        //dato a procesar, que varia dependiendo del canal seleccionado
reg [15:0] val_anterior;    //valor anterior para comparar en el trigger
reg flag_enable;    //flag para utilizar dentro del trigger
reg flag_start;     //flag para ejecutar el caso del primer valor una unica vez
reg [15:0] val_tr;  //valor del trigger

reg den;    //den dentro del adc (al enviarle un pulso se habilita la proxima conversion)
reg [2:0] estado_actual;    //estado dentro de la maquina de estados
reg [15:0] dato_1;          //dato salida del canal 6
reg [15:0] dato_2;          //dato salida del canal 14
wire [15:0] dout;           //salida del adc

wire eoc;   //pulso que indica que se termino una conversion de los dos canales (de canal 6 y de 14)

always @(posedge clk) begin
    if (reset | ~locked) begin
        canal <= 0;
        address <= 0;
        flag_enable <= 1;
        flag_start <= 1;
        val_tr <= 32768;
        estado_actual <= 0;
    end
    else begin
        case (tr_level)
            0: val_tr <= 75;         // Trigger (casi) sobre 0V
            1: val_tr <= 16384;     //  1/4 de grilla
            2: val_tr <= 32768;     //  2/4 de grilla
            3: val_tr <= 49152;     //  3/4 de grilla
            4: val_tr <= 65460;     // Triger (casi) sobre 1V
        endcase

        case(estado_actual)
            //0 : Estado de reposo
      		0: begin
                   den <= 1'b0;
                   //En reposo no pasamos direcciones
                   canal <= 6'h00;
       		       if(eoc)
        	           estado_actual <= 1;
       		       else
        	           estado_actual <= 0;
                   end
      		//1 : Copiado de la direccion del canal 6   
     	    1: begin
       		       canal <= 8'h16;
       		       estado_actual <= 2;
      	     end
      	    //2 : Lectura del dato 1
            2: begin
                den <= 1;
                estado_actual <= 3;
            end
            //3 : Espera del primer dato_ready
            3: begin
                den <= 0;
                //Si no tengo dato ready, espero hasta tenerlo
                if (ready) begin
                    estado_actual <= 4;
                    dato_1 <= dout;
                end    
                else
                    estado_actual <= 3;
            end
            //4 : Copiado de la direccion del canal 14
            4: begin
                canal <= 8'h1e;
                estado_actual <= 5;
            end
            //5 : Lectura del dato 2
            5: begin
                den <= 1'b1;
                estado_actual <= 6;
            end
            //6 : Esperando el segundo dato_ready
            6: begin
                den <= 1'b0;
                if (ready) begin
                    estado_actual <= 0;
                    dato_2 <= dout;
                end    
                else
                    estado_actual <= 6;
            end
        endcase
        
        dato_adc <= (canal_selector)? dato_1 : dato_2;        
        if (tr_active) begin
            if (flag_start) begin            
                val_anterior <= dato_adc;
                flag_start <= 0;
            end else begin    
                if (val_anterior < val_tr && dato_adc >= val_tr)
                    flag_enable <= 0;
                if (flag_enable == 0) begin    
                    address <= (address == 4000)? 0 : address + 1;
                    dato_canal_1 <= dato_adc;
                    flag_enable <= (address == 4000)? 1 : 0;
                end
                val_anterior <= dato_adc;
            end
        end else begin
            dato_canal_1 <= dato_adc;
            address <= (address == 4000)? 0 : address + 1;
        end                
    end   
end

assign tr_enable = (~flag_enable)? 1 : 0;   

adc_vauxp6_14 adc_canal_6_14 (
  .di_in(0),              // input wire [15 : 0] di_in
  .daddr_in(canal),        // input wire [6 : 0] daddr_in
  .den_in(den),            // input wire den_in
  .dwe_in(0),            // input wire dwe_in
  .drdy_out(ready),        // output wire drdy_out
  .do_out(dout),            // output wire [15 : 0] do_out
  .dclk_in(clk),          // input wire dclk_in
  .reset_in(reset || ~locked),        // input wire reset_in
  .vp_in(0),              // input wire vp_in
  .vn_in(0),              // input wire vn_in
  .vauxp6(vauxp6),            // input wire vauxp6
  .vauxn6(vauxn6),            // input wire vauxn6
  .vauxp14(vauxp14),          // input wire vauxp14
  .vauxn14(vauxn14),          // input wire vauxn14
  .channel_out(),  // output wire [4 : 0] channel_out
  .eoc_out(eoc),          // output wire eoc_out
  .alarm_out(),      // output wire alarm_out
  .eos_out(),          // output wire eos_out
  .busy_out()        // output wire busy_out
);

endmodule
