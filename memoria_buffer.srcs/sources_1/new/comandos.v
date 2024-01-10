`timescale 1ns / 1ps

module comandos(
    input clk_64,
    input reset,
    input locked,
    input [7:0] dato_recibido,  //Dato que entro de la UART
    input pulso_rx,             //Pulso que indica que recibi algo
    output reg canal,
    output reg [2:0] voltdiv,
    output reg [2:0] tiempo,
    output reg pausa,
    output reg [2:0] tr_level,
    output reg tr_active
    );

always @(posedge clk_64) begin
    if (~locked || reset) begin
        canal <= 1;
        voltdiv <= 0;
        pausa <= 1;
        tiempo <= 7;
        tr_active <= 1;
        tr_level <= 2;
    end
    else begin
        if (pulso_rx) begin
            case (dato_recibido)    
                8'h43, 8'h63 : //C
                    canal <= ~canal;
                8'h77, 8'h57 : //W
                    voltdiv <= (voltdiv == 7)? 7 : voltdiv + 1;
                8'h53, 8'h73 : //S
                    voltdiv <= (voltdiv == 0)? 0 : voltdiv - 1;
                8'h41, 8'h61 : //A
                    tiempo <= (tiempo == 0)? 0 : tiempo - 1;
                8'h44, 8'h64 : //D
                    tiempo <= (tiempo == 7)? 7 : tiempo + 1;
                8'h50, 8'h70 : //P
                    pausa <= ~pausa;
                8'h54, 8'h74 : //T
                    tr_level <= (tr_level == 5)? 5 : tr_level + 1;
                8'h47, 8'h67 : //G
                    tr_level <= (tr_level == 0)? 0 : tr_level - 1;
                8'h59, 8'h79 : //Y
                    tr_active <= ~tr_active;                         
                default: begin end
            endcase    
        end
    end
end
                
endmodule      