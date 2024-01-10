Este trabajo consiste en el diseño e implementación de un osciloscopio en una placa FPGA modelo Basys 3. Esta placa fue elegida particularmente ya que cuenta con salida VGA para poder mostrar las señales en tiempo a través de un monitor. La implementación del proyecto fue subdividida en 7 módulos. Además se incluyen los resultados obtenidos, evaluaciones y posibles mejoras del dispositivo. Cabe aclarar que uno de los módulos existentes contiene todos los demás módulos en su interior (Top Level).


Las características que debían cumplir eran las siguientes
● 2 Canales analógicos
● 8 Escalas temporales
● 8 valores de ganancia
● Trigger en cruce por cero
● Pausa
● Configuración por UART

El proyecto a implementar se dividio en los siguientes módulos, donde se describen las conexiones y el propósito de cada uno de estos módulos:
Partiendo de un clock del sistema establecido en 100 MHz, se utilizó dentro del proyecto una IP (Intellectual Property) provista por Vivado llamada “Clocking Wizard”, la cual permitía crear clocks secundarios a partir de un clock principal. Dicho módulo consta de dos entradas: un reset el cual reinicia el sistema, el cual para nuestro caso funcionó a partir de un botón dentro de la FPGA, y además un clock de entrada a partir del cual se crearán los clocks secundarios, para el cual se utilizó el clock del sistema antes mencionado. Como salida, el módulo nos provee la cantidad de clocks necesarios y además se nos provee de una salida extra llamada “locked”,la cual posee un valor en alto cuando el PLL dentro de la FPGA encargado de ajustar la frecuencia de los clocks secundarios logró ajustar el clock a la frecuencia deseada, caso contrario permanece en bajo hasta realizar dicho ajuste.
Para el proyecto implementado, fueron necesarios 4 clocks:
El primero llamado “clk_adc” el cual funciona a una frecuencia de 104 MHz. Este valor fue escogido debido a que el ADC dentro de la FPGA necesita ser múltiplo de 26 MHz para poder obtener un muestreo una tasa de 1 MSPS por segundo. Además la máquina de estado implementada y explicada más adelante para leer datos del ADC dentro de la FPGA debía ser al menos 4 veces más rápido que la frecuencia de muestreo para su correcto funcionamiento, debido al diseño escogido
El segundo clock “clk_vga” es utilizado dentro del módulo VGA. Este es de una frecuencia de 40MHz, valor el cual se escogió para mostrar por pantalla una resolución de 800x600 píxeles con una tasa de refresco de 60HZ.
Por último, el clock que permite el funcionamiento de la UART, también conocido como “clk_uart”. El mismo es de 7.3728 MHz. 
Cabe destacar que el cuarto clock “clk_100” fue creado debido a que se usaron dos IPs distintos para crear todos los clocks mencionados anteriormente (ya que si se utilizaba una única IP para crear varios clocks, aumenta considerablemente la diferencia entre la frecuencia necesaria y la frecuencia que permite entregar la IP). Este clock extra, es un clock de igual valor que el clock del sistema (100MHz) pero funciona como clock de entrada para una de las IPs.

Módulo UART
El módulo UART (Universal asynchronous receiver-transmitter) fue desarrollado a partir del práctico anterior de la materia. En este se permitió mediante una conexión serial entre la computadora del usuario y la placa FPGA que el usuario sea capaz de realizar modificaciones visuales de la señal.  
Las entradas del módulo son:

clk_uart: es el clock del módulo de 7.38MHz              

locked_clk_uart: flag cuyo valor se coloca en alto una vez que el PLL dentro de los IP de clock alcanzó la frecuencia necesaria

reset: permite resetear el dispositivo

rxd_i: es el canal de entrada a la FPGA por donde entran las tramas enviadas por el usuario

dato_tx_uart: es el dato a enviar por la UART, desde la FPGA

txd_o: canal de salida por donde salen las tramas de la UART, desde la FPGA

Las salidas del módulo son los siguientes comandos, elegidos por el usuario:

dato_rx_uart: dato (caracter) recibido desde la computadora

canal_selector: permite seleccionar el canal dentro del osciloscopio

voltdiv: indica el nivel de amplitud de la señal (8 niveles)

tiempo: indica el la compresión o expansión de la señal indica el nivel de amplitud de la señal (8 niveles)

pausa: permite detener/reanudar el movimiento de la señal en pantalla

tr_level: indica el nivel del trigger

tr_active: permite activar/desactivar el trigger


El módulo UART a su vez, se compone de 4 submódulos:
RX: Receptor UART, permite recibir tramas desde la computadora a la FPGA
TX: Transmisor UART, permite transmitir tramas desde la FPGA a la computadora
mensaje: Envía el mensaje de bienvenida por la UART al iniciar por primera vez (o reiniciar) el dispositivo. En este se detallan todos los posibles comandos junto con las teclas con los cuales se utilizan
comandos: Utilizando el receptor RX y en base al carácter enviado por el usuario, permite modificar alguna de las salidas del módulo detalladas anteriormente.
El funcionamiento de los 2 primeros submódulos fue explicado en el práctico anterior. El módulo mensaje fue desarrollado en base al módulo del práctico anterior, con la diferencia de que se modificó la cadena de caracteres a enviar. 
En cuanto al submódulo “comandos”, sus entradas son las siguientes:

clk_64: clock de la UART, de 7.38MHz

reset: resetea el módulo

locked: flag cuyo valor se coloca en alto una vez que el PLL dentro de los IP de clock alcanzó la frecuencia necesaria

dato_recibido: dato(carácter) que ingresó desde el receptor de la UART

pulso_rx: pulso que se recibió un caracter nuevo

Las salidas del submódulo son:

canal: indica el canal a seleccionar. El valor 0 representa el canal 1 y el valor 1 representa el canal 2.

voltdiv: indica el nivel de amplitud para la señal seleccionado por el usuario

tiempo: implica el nivel de compresión o expansión temporal seleccionado por el usuario

pausa: Con el valor 1 la señal está en movimiento y con un valor 0, la señal se detiene.

tr_level: indica el nivel del trigger seleccionado (5 niveles)

tr_active: permite activar/desactivar el trigger    



Módulo ADC

Un conversor o convertidor de señal analógica a digital (Analog-to-Digital Converter, ADC) es un dispositivo electrónico capaz de convertir una señal analógica, ya sea de tensión o corriente, en una señal digital mediante un cuantificador y una codificación realizada en código binario.
El módulo ADC tiene la función de realizar la lectura del ADC incorporado dentro de la FPGA utilizando una IP (Intellectual Property) provista por Vivado llamada “XADC Wizard”. Dentro de este módulo también, mediante una máquina de estado se permite seleccionar el dato de canal requerido (canal escogido por el usuario para visualizar) y también se permite ajustar el valor del trigger deseado para luego proceder a guardar estos datos en la memoria.
El ADC dentro de la FPGA Basys 3 permite hacer lecturas de señales analógicas comprendidas entre 0 y 1V con una resolución de 16 bits, de los cuales los 4 bits menos significativos de la medición son innecesarios, por lo que deben ser descartados. El ADC de la Basys 3 cuenta con 4 canales. En nuestro caso elegimos el canal 6 y 14 para leer señales.
Para poder obtener un muestreo de 1MSPS en los 2 canales se selecciona la función modo de muestreo simultáneo. Esto hace que cuando seleccionemos el canal 6 en la configuración automáticamente asigna el 14 como el otro canal producto que uno es del canal A y otro del B, lo que permite que trabajen en simultáneo

Las entradas del módulo son:

clk: clock de 104MHz

reset: este es un botón dentro de la FPGA que se encarga de resetear todos los módulos

locked: flag cuyo valor se coloca en alto una vez que el PLL dentro de los IP de clock alcanzó la frecuencia necesaria

vauxp6: pin positivo del canal 6               

vauxn6: pin negativo del canal 6  

vauxp14: pin positivo del canal 14  

vauxn14: pin negativo del canal 14   

canal_selector: valor ingresado por UART, permite seleccionar uno de los dos canales 

tr_level: valor ingresado por UART, indica el nivel del trigger escogido por el usuario

tr_active: valor ingresado por UART, indica si el trigger está activado.

Las salidas del modulo son:

dato_canal_1: dato de salida del ADC.

address: dirección correspondiente para escribir el dato del ADC en la memoria.

Dentro de este módulo se encuentra la instanciación del IP “XADC”, donde los pines más importantes son “den_in”, encargado de habilitar la lectura de la memoria interna del ADC con el dato de salida, “canal” en donde se ingresa la dirección de memoria del canal a leer, “reset” el cual resetea el canal, “ready” indica que ya está disponible el dato convertido del ADC, “dout” el cual es la salida del dato del ADC, “clk” el cual corresponde al clock de 104MHz y “eoc” la cual indica el fin de una conversión.

Para implementar este módulo, se comienza inicializando los registros internos auxiliares que utilizaremos dentro del módulo, así como estableciendo valores por defecto a las salidas. Luego, en el caso de que la flag de entrada “locked” no esté en su valor alto, o en el caso de que ingrese una valor en alto de reset, seguiremos inicializando los registros y valores por defecto de salidas, impidiendo la inicialización normal del módulo.
Una vez que se establezca el valor en alto de “locked” o se detenga el envío de un reset desde un botón de la FPGA, se procede a definir los valores posibles para el trigger dentro del osciloscopio. Estos valores son 5, los cuales se obtienen de dividir el máximo valor posible de lectura del ADC (65536, o 216). Luego se procede a definir una máquina de estado, la cual permitirá obtener datos útiles de los distintos canales de ADC. La máquina de estado tiene 7 estados: el primero de reposo, en donde esperamos el fin de conversión. El segundo, en el que pasamos la dirección de la memoria del primer canal el cual queremos leer dentro de la memoria interna del ADC. Luego, en el tercer estado, damos un pulso a la entrada “den_in” dentro de la IP del ADC, con el objetivo que permita la lectura de memoria. En el cuarto estado, esperamos que este disponible el dato convertido con la señal de salida “ready” para poder copiarlo a un registro llamada “dato_1”. Hasta no obtener el valor en alto en “ready”, nos quedaremos en este estado. En el quinto, sexto y séptimo estado repetimos los pasos del segundo, tercer y cuarto estado, pero utilizando valores del canal 2: Primero pasamos la dirección de memoria del canal 2, habilitamos un pulso en la entrada “den_in” nuevamente y esperamos el próximo “ready” para poderlo guardar el dato convertido en el registro “dato _2”. Una vez finalizado el séptimo estado, pasamos de nuevo al estado inicial, es decir, al primer estado de reposo.
Una vez obtenidos los datos, dependiendo del valor de “canal_selector” que proviene del módulo de la UART detallado más adelante, se escoge con cual de los dos datos nos quedaremos: dato_1 o dato_2.
Por último, para utilizar el trigger dependemos de las últimas 2 entradas al módulo. Si el trigger está desactivado (valor bajo en “tr_active”) los datos serán almacenados en la memoria posterior al módulo del ADC indefinidamente. Cabe resaltar que existe un contador que va desde 0 a 39999 (decimal) para asignar el dato a una dirección de memoria, para lo cual se utiliza la salida “address” para asignar la dirección de memoria a escribir, y “dato_canal_1” para escribir el dato en cuestión.
En el caso de que el trigger está activado (valor alto en “tr_active”) se guarda el valor del dato procesado en el tiempo (t - 1) del ADC para comparar con el valor actual (t). Si el valor del trigger está entre estos 2 valores y además se cumple que el valor en t-1 es menor o igual al valor en t (flanco ascendente), la memoria se escribirá con los siguientes 40000 valores provenientes del ADC. En caso de que no se cumpla alguna de las condiciones anteriores respecto a los valores de t y t-1 se procederá a mostrar los últimos 40000 valores leídos, hasta el momento en el que se cumplan las condiciones definidas anteriormente.
Módulo adaptador

Este módulo se encarga de extraer los datos de la memoria del adc y adaptarlos para su visualización en la pantalla.
Las entradas del módulo son lo siguientes: 
clk: se utiliza el clock del ADC, de 104MHz
reset: se utiliza para resetear el módulo
locked: flag cuyo valor se coloca en alto una vez que el PLL dentro de los IP de clock alcanzó la frecuencia necesaria
dato_entrada: es el dato que ingresa de la memoria al módulo, de 16 bits
voltdiv: valor ingresado por UART, permite ajustar el nivel de la amplitud de la señal.
tiempo: valor ingresado por UART, permite ajustar la escala temporal 
Las salidas del módulo son lo siguientes: 
dir_entrada: es la posición de la memoria del bloque RAM ADC que queremos leer
dato_salida: es el dato ya adaptado en 7 bits (o menos) que luego va a la memoria de vga
dir_salida: es la posición de memoria a la que es asignado el dato_salida dentro de la memoria ram_VGA.

modulo adaptador
Este módulo, se divide en 2 partes: la adaptación de la amplitud y la adaptación del eje temporal. En el primero, dependiendo del valor escogido por el usuario mediante la UART, será la amplitud. Partiendo del dato de 16 bits, leído de la memoria RAM ADC, se comienzan eliminando los 4 bits menos significativos, debido a que estos representan ruido y no son útiles para la medición. Como resultado se obtiene un dato base que será de 12 bits. Luego, utilizando el valor que ingreso el usuario como valor de amplitud, procedimos a realizar el escalamiento de amplitud eliminando n bits, comenzando con los menos significativos. Esto produce que la señal reduzca su amplitud en factores que son potencias de dos. Los valores permitidos de amplitud son los siguientes:
Valor 0: Se devuelve una salida de 9 bits, permitiendo una escala en amplitud de 0.1 V/Div.

Valor 1: Se devuelve una salida de 8 bits, permitiendo una escala en amplitud de 0.2 V/Div.

Valor 2: Se devuelve una salida de 7 bits, permitiendo una escala en amplitud de 0.4 V/Div.

Valor 3: Se devuelve una salida de 6 bits, permitiendo una escala en amplitud de 0.8 V/Div.

Valor 4: Se devuelve una salida de 5 bits, permitiendo una escala en amplitud de 1.6 V/Div.

Valor 5: Se devuelve una salida de 4 bits, permitiendo una escala en amplitud de 3.2 V/Div.

Valor 6: Se devuelve una salida de 3 bits, permitiendo una escala en amplitud de 6.4 V/Div.

Valor 7: Se devuelve una salida de 2 bits, permitiendo una escala en amplitud de 12.8 V/Div.

Para la división temporal, lo que se hizo fue variar la cantidad de muestras que se toma de la memoria RAM ADC. Esto se logró variando los saltos que realiza el contador dentro del módulo, lo que en consecuencia produce que de la memoria se lean más o menos valores. En un primer momento recorremos la memoria variando en 1 en cada posición, para obtener la mayor tasa de muestreo y luego a medida que se incrementa el nivel de escala temporal, las distancias entre las muestras crecen. Es importante que el salto entre casillero y casillero de memoria sea un múltiplo de 40000, para obtener siempre valores enteros y así luego poder llenar correctamente la memoria siguiente (RAM VGA).

Módulo VGA
El VGA (Video Graphics Array) es un estándar de vídeo de alta resolución que se utiliza principalmente en monitores de ordenador. Este utiliza cables separados para transmitir las señales de los componentes de tres colores y las señales de sincronización vertical y horizontal. El vídeo VGA es un flujo de fotogramas: cada fotograma se compone de una serie de líneas horizontales y cada línea se compone de una serie de píxeles. Las líneas de cada cuadro se transmiten en orden de arriba a abajo (VGA no está entrelazado) y los píxeles de cada línea se transmiten de izquierda a derecha. Se utilizan señales de sincronización horizontal y vertical separadas para definir los extremos de cada línea y cuadro. También se codifica una señal de sincronización compuesta (en realidad, un XOR de las señales horizontal y vertical) en el canal de color verde.
En nuestro caso nos permite graficar la grilla y las señales, y se escogió una resolución de 800x600 a una tasa de refresco de 60 Hz.
Las entradas del módulo son las siguientes:

clk: es el clock del módulo, en este caso 40MHz 

reset: resetea el módulo

locked: flag cuyo valor se coloca en alto una vez que el PLL dentro de los IP de clock alcanzó la frecuencia necesaria

mem_ram: dato que ingresa de la memoria RAM VGA. En este está almacenado el valor de la señal que luego se colorea en pantalla.

canal_selector: entrada que indica cuál de los dos canales dentro del ADC se está mostrando

tr_active: entrada con la cual activamos o desactivamos el trigger

tr_level: se selecciona por UART el nivel del trigger.

Las salidas del módulo son:

address_ram: indica el casillero de memoria que deseamos acceder

hs: es el bit de sincronización horizontal

vs: es el bit de sincronización vertical

r: es la salida “red” que indica el nivel de color rojo que tendrá cada pixel. Es de 4 bits

g: es la salida “green” que indica el nivel de color verde que tendrá cada pixel. Es de 4 bits

b: es la salida “blue” que indica el nivel de color azul que tendrá cada pixel. Es de 4 bits


Dentro del módulo, utilizando la resolución antes especificada, definimos dos contadores principales (vertical y horizontal) para poder utilizar periodos de clocks dentro del módulo. Estos periodos de clock nos permiten ajustar sincronismos y enviar los colores al monitor. En base a los valores de la Tabla 1, se enviaron colores por pantalla, y se activaron/desactivaron los pulsos de sincronismos cuando fue necesario.

Una vez definidos los contadores principales, se definieron contadores secundarios para facilitar la tarea de colorear la pantalla. Adicionalmente se definieron constantes que son sumatorias de tiempos de la Tabla 1 para que resulte más sencillo el programa. 
Tras definir todos los contadores, se procedió a colorear la grilla. Para ello se dividió la pantalla en 10 cuadros (valor escogido arbitrariamente) tanto vertical como horizontalmente, lo que conformó la grilla del osciloscopio. 
Luego de colorear la grilla, se colocaron renglones que indican el valor del trigger escogido por el usuario. Estos renglones son representaciones visuales, no realizan ninguna lógica que involucra el procesamiento de la señal, ya que dicha lógica fue realizada en el módulo “adaptador”. Además se agregó en la parte superior de la pantalla, por encima de la grilla, un indicador de canal que sirve para que el usuario identifique cuál de los canales está visualizando.
Después, se graficó la señal utilizando los datos leídos desde la memoria RAM VGA. Antes de graficar, se procedió a invertir los valores respecto a la grilla. Esto se realizó debido a que VGA contabiliza sus valores desde arriba hacia abajo, lo que producía que el valor cero de la señal quede colocado en la parte superior, y que la señal se grafique hacia abajo.
Por último, con una lógica similar a la que se utilizó para detectar el trigger, que involucra el valor actual graficado y el valor anterior que se gráfico, se realizó una interpolación entre puntos, lo que produjo el efecto de continuidad en la señal. Al igual que los renglones del trigger, este efecto de continuidad es visual únicamente.

Posibles mejoras del  sistema

Reducción de la velocidad del clock del ADC: originalmente el sistema del ADC fue pensado para funcionar en modo secuenciador, haciendo que el clock del ADC sea de 52 MHz lo que producía que no exista mucha diferencia con el clock VGA ya que dentro de la memoria RAM VGA, debido a que se utilizan clocks distintos para la escritura y la lectura, si escribimos más rápido de lo que leemos, es posible que algunos datos se sobreescriban. Una de las posibles mejoras es simplificar la máquina de estado utilizada para leer datos de ADC, para que esta pueda funcionar a 52 MHz y con esto reducir la velocidad del clock ADC.
Utilizar escalas de división de tensión distintas a potencias de dos: Si bien las escalas de división de tensión utilizadas permiten visualizar resultados más claros, la visualización de resultados puede ser algo confusa, debido a la variación de valores entre escalas. Para mejorar este aspecto, se puede implementar una lógica de punto flotante dentro del adaptador, lo que permite mostrar resultados dentro de rangos diferentes a potencias de dos.
Visualizar frecuencias menores a 26 KHz: Debido al tamaño de la memoria escogido, no es posible visualizar frecuencias menores a 26 KHz adecuadamente. El valor inicial de la memoria se escogió estratégicamente para facilitar la lectura de datos dentro del módulo “adaptador” y su posterior escritura en la memoria RAM VGA. Para solucionar este problema, una posible solución sería utilizar una memoria más grande, lo que permite almacenar más valores de lectura del ADC, lo que resulta en mayor cantidad de muestras para frecuencias más lentas. Otra alternativa más compleja, que permite mantener el tamaño actual de la memoria, podría ser la implementación de alguna lógica interna que fabrique valores entre dos puntos, en el caso de que la frecuencia sea demasiado baja. Para ello, se puede utilizar algún algoritmo que calcule valores medios entre dos muestras, o que estime valores.
Aumentar la cantidad de información en pantalla: En la pantalla del osciloscopio implementado, solo es posible ver información del canal actual que se está mostrando por pantalla. Para mostrar más información, se puede utilizar algún código externo, ajeno al proyecto implementado, que permita representar caracteres alfanuméricos por la pantalla de un monitor VGA.
Reducción de los tiempos de compilación y mejora en el tiempo WNS: Para mejorar estos dos aspectos, una posible alternativa es utilizar otra placa distinta en conjunto con la utilizada para este proyecto, de tal forma que el módulo de la UART se encuentre separado de los otros módulos del proyecto. Alternativamente, podría eliminarse la UART del proyecto y utilizar los switches/botones incluidos dentro de la placa para ajustar escalas y configuraciones dentro del proyecto.



