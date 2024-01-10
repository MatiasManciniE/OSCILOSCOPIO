`timescale 1ns / 1ps

module adaptador_tb();

reg clk_vga;
reg clk_adc;
reg reset;
reg locked;
reg wea;
wire [15:0] salida_mem_adc;
wire [11:0] dir_salida_mem_adc;
wire [9:0] dir_salida_9b;
wire [8:0] dato_salida_9b;
wire [9:0] ram_address_vga;
wire [8:0] mem_ram_vga;

blk_mem_adc16b ram_adc (
  .clka(clk_adc),    // input wire clka
  .wea(wea1),      // input wire [0 : 0] wea
  .addra(addra),  // input wire [11 : 0] direccion de entrada (ADC)
  .dina(dina),    // input wire [15 : 0] dato a escribir (ADC)
  .clkb(clk_adc),    // input wire clkb
  .addrb(dir_salida_mem_adc),  // input wire [11 : 0] direccion de salida
  .doutb(salida_mem_adc)  // output wire [15 : 0] dato de salida
);  

blk_mem_VGA ram_vga (
  .clka(clk_adc),    // input wire clock de escritura
  .wea(wea),      // input wire [0 : 0] wea
  .addra(dir_salida_9b),  // input wire [8 : 0] Direccion de entrada (Adaptador) 
  .dina(dato_salida_9b),    // input wire [8 : 0] Dato a escribir (Adaptador)
  .clkb(clk_vga),    // input wire clock de lectura (igual al VGA)
  .addrb(ram_address_vga),  // input wire [8 : 0] direccion a leer para el pixel de VGA
  .doutb(mem_ram_vga)  // output wire [8 : 0] dato a pintar en la pantalla
); 

adaptador adaptador(
    clk_adc,
    reset,
    locked,
    //amp,
    //tiempo,
    salida_mem_adc,      // input [15:0] Del ADC salen 16 bits de dato
    dir_salida_mem_adc,      // output [11:0] Direccion para leer de la memoria del ADC
    dato_salida_9b,     // output [8:0] A enviar a la ram del VGA
    dir_salida_9b       // output [8:0] Direccion del dato para escribir en la RAM de VGA
    );
    
vga vga_monitor (
        clk_vga,
        reset,
        locked,
        mem_ram_vga,        //[8:0]
        ram_address_vga,    //[9:0]
        hs,
        vs,
        r,
        g,
        b
    );

always #25 clk_vga = ~clk_vga;
always #19.2308 clk_adc = ~clk_adc;

initial begin
    clk_vga = 0;
    clk_adc = 0;
    reset = 1;
    locked = 0;
    wea = 1;
    #100
    reset = 0;
    locked = 1;
    #5000000
    $stop;
end

endmodule
