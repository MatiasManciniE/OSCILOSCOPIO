`timescale 1ns / 1ps

module memoria_toplevel(
    input clk_in1,
    input reset,
    output hs,
    output vs,
    input rxd_i,
    input vauxp6,            // input wire vauxp6
    input vauxn6,            // input wire vauxn6
    input vauxp14,          // input wire vauxp14
    input vauxn14,          // input wire vauxn14
    output [3:0] r,
    output [3:0] g,
    output [3:0] b,
    output txd_o  
    );

clk_sys_vga clk_100_40
   (
    // Clock out ports
    .clk_100(clk_100),     // output clk_100
    .clk_vga(clk_vga),     // output clk_vga
    // Status and control signals
    .reset(reset), // input reset
    .locked0(locked0),       // output locked0
   // Clock in ports
    .clk_in1(clk_in1)      // input clk_in1
);
    
clk_wiz_1 clock_adc_uart
   (
    // Clock out ports
    .clk_uart(clk_uart),     // output clk_uart
    .clk_adc(clk_adc),     // output clk_adc
    // Status and control signals
    .reset(reset), // input reset
    .locked(locked2),       // output locked
   // Clock in ports
    .clk_in1(clk_100)      // input clk_in1
);    

wire locked;     
assign locked = (locked0 & locked2);    

//La direccion para leer se puede compartir, es el mismo contador
//Dentro de adaptador se escoge con cual de los ADC se trabaja

//////////////////////////////////////////////////
/////////////////       ADC         //////////////
//////////////////////////////////////////////////

wire [11:0] dir_salida_mem_adc;

wire [15:0] salida_mem_adc;

wire [11:0] address_adc;
wire [15:0] dato_canal_1;

wire [2:0] tr_level;

adc adc_convertidor(
    clk_adc,
    reset,
    locked,
    vauxp6,            // input wire vauxp6
    vauxn6,            // input wire vauxn6
    vauxp14,          // input wire vauxp14
    vauxn14,
    canal_selector,
    tr_level,
    tr_active,  
    dato_canal_1,       //output [15:0] dato a escribir en memoria
    address_adc
    );
    
blk_mem_adc16b ram_adc (
  .clka(clk_adc),    // input wire clka
  .wea(pausa),      // input wire [0 : 0] wea
  .addra(address_adc),  // input wire [11 : 0] direccion de entrada (ADC)
  .dina(dato_canal_1),    // input wire [15 : 0] dato a escribir (ADC)
  .clkb(clk_adc),    // input wire clkb
  .enb(wea),            //input enb
  .addrb(dir_salida_mem_adc),  // input wire [11 : 0] direccion de salida
  .doutb(salida_mem_adc)  // output wire [15 : 0] dato de salida
);

//////////////////////////////////////////////////
/////////////////       VGA         //////////////
//////////////////////////////////////////////////

wire [2:0] voltdiv;
wire [2:0] tiempo;

wire [8:0] dato_salida_a_vga;
wire [9:0] dir_salida_a_vga;

wire [9:0] ram_address_vga;
wire [8:0] mem_ram_vga;

blk_mem_VGA ram_vga (
  .clka(clk_adc),    // input wire clka
  .wea(wea),      // input wire [0 : 0] wea
  .addra(dir_salida_a_vga),  // input wire [9 : 0] direccion para escribir desde adaptador
  .dina(dato_salida_a_vga),    // input wire [8 : 0] dato a escribir desde adaptado
  .clkb(clk_vga),    // input wire clkb
  .addrb(ram_address_vga),  // input wire [9 : 0] direccion para leer desde VGA
  .doutb(mem_ram_vga)  // output wire [8 : 0] dato para enviar a VGA
);

vga vga_monitor (
        clk_vga,
        reset,
        locked,
        mem_ram_vga,        //[8:0]
        canal_selector,
        tr_level,
        tr_active,
        ram_address_vga,    //[9:0]
        hs,
        vs,
        r,
        g,
        b
    );

assign wea = 1;

//////////////////////////////////////////////////////
/////////////////       UART        //////////////////
//////////////////////////////////////////////////////


uart modulo_uart (
        clk_uart,           //7.38 MHz
        locked,
        reset,
        rxd_i,              //input entrada del receptor uart
        txd_o,              //output salida del receptor uart
        canal_selector,     //output
        voltdiv,            //output [2:0] valor de la escala de volt/div
        tiempo,             //output [2:0] valor de la escala de temporal
        pausa,              //output
        tr_level,           //output [2:0] valor del trigger
        tr_active           //output trigger enable
        );   

////////////////////////////////////////////////////////
//////////         ADAPTADOR DE SENAL       ////////////
////////////////////////////////////////////////////////

adaptador adaptador(
    clk_adc,
    reset,
    locked,
    salida_mem_adc,      // [15:0] input dato que ingresa de la memoria del ADC
    voltdiv,                //input [2:0]
    tiempo,                 //input [2:0]
    dir_salida_mem_adc,      // [11:0] output Direccion para leer de la memoria del ADC
    dato_salida_a_vga,     // [8:0] output A enviar a la ram del VGA
    dir_salida_a_vga       // [9:0] output Direccion del dato para escribir en la RAM de VGA (0-800)
    );
    
endmodule

