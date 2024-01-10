`timescale 1ns / 1ps

module mensajes(
    input clk,
    input reset,
    input locked,
    output reg [7:0] char,
    output pulso_tx
    );
 
reg [7:0] bienvenida [153:0];   //mensaje

reg flag_start;                 //flag para enviar el mensaje una unica vez al iniciar
reg [8:0] indice;               //indice para recorrer los 153 mensajes del array
reg [7:0] salida_aux;           //registro auxiliar para enviar datos por el transmisor
reg pulso_aux;                  //pulso para sacar cada dato
reg [3:0] i;                    //indice para copiar los 8 bits de cada caracter
reg [9:0] delay;                //registro para hacer delay entre caracteres enviados
reg bit_enviado;                //flag para enviar un caracter
    
always @(posedge clk) begin
    if (~locked || reset) begin
        indice <= 0;
        pulso_aux <= 0;
        flag_start <= 1;
        delay <= 0;
        bit_enviado <= 0;
        bienvenida[0] <= 8'h45; //E
        bienvenida[1] <= 8'h6C; //l
        bienvenida[2] <= 8'h20; //espacio
        bienvenida[3] <= 8'h4F; //O
        bienvenida[4] <= 8'h73; //s
        bienvenida[5] <= 8'h63; //c
        bienvenida[6] <= 8'h69; //i
        bienvenida[7] <= 8'h6C; //l
        bienvenida[8] <= 8'h6F; //o
        bienvenida[9] <= 8'h73; //s
        bienvenida[10] <= 8'h63; //c
        bienvenida[11] <= 8'h6F; //o
        bienvenida[12] <= 8'h70; //p
        bienvenida[13] <= 8'h69; //i
        bienvenida[14] <= 8'h61; //a
        bienvenida[15] <= 8'h73; //s
        bienvenida[16] <= 8'h6F; //o
        bienvenida[17] <= 8'h0A; //New Line
        bienvenida[18] <= 8'h0D; //CR
        bienvenida[19] <= 8'h43; //C
        bienvenida[20] <= 8'h6F; //o
        bienvenida[21] <= 8'h6E; //n
        bienvenida[22] <= 8'h74; //t
        bienvenida[23] <= 8'h72; //r
        bienvenida[24] <= 8'h6F; //o
        bienvenida[25] <= 8'h6C; //l
        bienvenida[26] <= 8'h65; //e
        bienvenida[27] <= 8'h73; //s
        bienvenida[28] <= 8'h3A; //:
        bienvenida[29] <= 8'h0A; //New Line
        bienvenida[30] <= 8'h0D; //CR
        bienvenida[31] <= 8'h57; //W
        bienvenida[32] <= 8'h3A; //:
        bienvenida[33] <= 8'h20; //espacio
        bienvenida[34] <= 8'h2B; //+
        bienvenida[35] <= 8'h20; //espacio
        bienvenida[36] <= 8'h61; //a
        bienvenida[37] <= 8'h6D; //m
        bienvenida[38] <= 8'h70; //p
        bienvenida[39] <= 8'h2E; //.
        bienvenida[40] <= 8'h0A; //New Line
        bienvenida[41] <= 8'h0D; //CR
        bienvenida[42] <= 8'h53; //S
        bienvenida[43] <= 8'h3A; //:
        bienvenida[44] <= 8'h20; //espacio
        bienvenida[45] <= 8'h2D; //-
        bienvenida[46] <= 8'h20; //espacio
        bienvenida[47] <= 8'h61; //a
        bienvenida[48] <= 8'h6D; //m
        bienvenida[49] <= 8'h70; //p
        bienvenida[50] <= 8'h2E; //.
        bienvenida[51] <= 8'h0A; //New Line
        bienvenida[52] <= 8'h0D; //CR
        bienvenida[53] <= 8'h44; //D
        bienvenida[54] <= 8'h3A; //:
        bienvenida[55] <= 8'h20; //espacio
        bienvenida[56] <= 8'h2B; //+
        bienvenida[57] <= 8'h20; //espacio
        bienvenida[58] <= 8'h65; //e
        bienvenida[59] <= 8'h73; //s
        bienvenida[60] <= 8'h63; //c
        bienvenida[61] <= 8'h2E; //.
        bienvenida[62] <= 8'h20; //espacio
        bienvenida[63] <= 8'h74; //t
        bienvenida[64] <= 8'h65; //e
        bienvenida[65] <= 8'h6D; //m
        bienvenida[66] <= 8'h70; //p
        bienvenida[67] <= 8'h2E; //.
        bienvenida[68] <= 8'h0A; //New Line
        bienvenida[69] <= 8'h0D; //CR
        bienvenida[70] <= 8'h41; //A
        bienvenida[71] <= 8'h3A; //:
        bienvenida[72] <= 8'h20; //espacio
        bienvenida[73] <= 8'h2D; //-
        bienvenida[74] <= 8'h20; //espacio
        bienvenida[75] <= 8'h65; //e
        bienvenida[76] <= 8'h73; //s
        bienvenida[77] <= 8'h63; //c
        bienvenida[78] <= 8'h2E; //.
        bienvenida[79] <= 8'h20; //espacio
        bienvenida[80] <= 8'h74; //t
        bienvenida[81] <= 8'h65; //e
        bienvenida[82] <= 8'h6D; //m
        bienvenida[83] <= 8'h70; //p
        bienvenida[84] <= 8'h2E; //.
        bienvenida[85] <= 8'h0A; //New Line
        bienvenida[86] <= 8'h0D; //CR
        bienvenida[87] <= 8'h43; //C
        bienvenida[88] <= 8'h3A; //:
        bienvenida[89] <= 8'h20; //espacio
        bienvenida[90] <= 8'h63; //c
        bienvenida[91] <= 8'h61; //a
        bienvenida[92] <= 8'h6D; //m
        bienvenida[93] <= 8'h62; //b
        bienvenida[94] <= 8'h69; //i
        bienvenida[95] <= 8'h61; //a
        bienvenida[96] <= 8'h72; //r
        bienvenida[97] <= 8'h20; //espacio
        bienvenida[98] <= 8'h63; //c
        bienvenida[99] <= 8'h61; //a
        bienvenida[100] <= 8'h6E; //n
        bienvenida[101] <= 8'h61; //a
        bienvenida[102] <= 8'h6C; //l
        bienvenida[103] <= 8'h0A; //New Line
        bienvenida[104] <= 8'h0D; //CR
        bienvenida[105] <= 8'h50; //P
        bienvenida[106] <= 8'h3A; //:
        bienvenida[107] <= 8'h20; //espacio
        bienvenida[108] <= 8'h70; //p
        bienvenida[109] <= 8'h61; //a
        bienvenida[110] <= 8'h75; //u
        bienvenida[111] <= 8'h73; //s
        bienvenida[112] <= 8'h61; //a
        bienvenida[113] <= 8'h20; //espacio
        bienvenida[114] <= 8'h0A; //New Line
        bienvenida[104] <= 8'h0D; //CR
        bienvenida[105] <= 8'h54; //T
        bienvenida[106] <= 8'h3A; //:
        bienvenida[107] <= 8'h20; //espacio
        bienvenida[108] <= 8'h2B; //+
        bienvenida[109] <= 8'h20; //espacio
        bienvenida[110] <= 8'h74; //t
        bienvenida[111] <= 8'h72; //r
        bienvenida[112] <= 8'h69; //i
        bienvenida[113] <= 8'h67; //g
        bienvenida[114] <= 8'h67; //g
        bienvenida[115] <= 8'h65; //e
        bienvenida[116] <= 8'h72; //r
        bienvenida[117] <= 8'h20; //espacio
        bienvenida[118] <= 8'h0A; //New Line
        bienvenida[119] <= 8'h0D; //CR
        bienvenida[120] <= 8'h47; //G
        bienvenida[121] <= 8'h3A; //:
        bienvenida[122] <= 8'h20; //espacio
        bienvenida[123] <= 8'h2D; //-
        bienvenida[124] <= 8'h20; //espacio
        bienvenida[125] <= 8'h74; //t
        bienvenida[126] <= 8'h72; //r
        bienvenida[127] <= 8'h69; //i
        bienvenida[128] <= 8'h67; //g
        bienvenida[129] <= 8'h67; //g
        bienvenida[130] <= 8'h65; //e
        bienvenida[131] <= 8'h72; //r
        bienvenida[132] <= 8'h20; //espacio
        bienvenida[133] <= 8'h0A; //New Line
        bienvenida[134] <= 8'h0D; //CR
        bienvenida[135] <= 8'h59; //Y
        bienvenida[136] <= 8'h3A; //:
        bienvenida[137] <= 8'h20; //espacio
        bienvenida[138] <= 8'h74; //t
        bienvenida[139] <= 8'h72; //r
        bienvenida[140] <= 8'h69; //i
        bienvenida[141] <= 8'h67; //g
        bienvenida[142] <= 8'h67; //g
        bienvenida[143] <= 8'h65; //e
        bienvenida[144] <= 8'h72; //r
        bienvenida[145] <= 8'h20; //espacio
        bienvenida[146] <= 8'h65; //e
        bienvenida[147] <= 8'h6E; //n
        bienvenida[148] <= 8'h2F; ///
        bienvenida[149] <= 8'h64; //d
        bienvenida[150] <= 8'h69; //i
        bienvenida[151] <= 8'h73; //s
        bienvenida[152] <= 8'h0A; //New Line
        bienvenida[153] <= 8'h0D; //CR    
    end
    else begin
        if (flag_start) begin
            delay <= delay + 1;
            if (indice < 154 && ~pulso_aux) begin
                bit_enviado <= 1;
                for (i = 0; i <= 7; i = i + 1)
                    char[i] <= bienvenida[indice][i];
                pulso_aux <= 1;
                bit_enviado <= 1;
            end
            pulso_aux <= (bit_enviado)? 0 : 1;
            if (delay == 1000) begin
                indice <= indice + 1;
                delay <= 0;
                bit_enviado <= 0;
            end
            if (indice == 153) begin
                flag_start <= 0;
                indice <= 0;
                pulso_aux <= 0;
            end
        end         
    end
end    

assign pulso_tx = pulso_aux;
    
endmodule
