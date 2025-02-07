#####################################################################
#
# Proyecto de Arquitecturas Gráficas - URJC
#
# Autores:
# - Rodriguez Garcia, Irene
# - Bellido Euribe, Rosa Ghaudy
# - Sanz Tardón, Miriam
#
# Bitmap Display:
# - Unit width in pixels: 8
# - Unit height in pixels: 8 
# - Display width in pixels:512
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Máximo objetivo alcanzado en el proyecto:
# - Juego base/3 ampliaciones 
#
# Ampliaciones implementadas 
# - Punto(s) 4/5/6 
#
# Instrucciones del juego:
# - El juego da comienzo con la serpiente, la cual controla el jugador en una posición determinada. A partir de este punto la serpìente comienza a desplazarse y a moverse. El jugador puede controlar el movimiento 
# de esta a través del teclado, con las teclas a (izquierda), d (derecha), w (arriba) y s (abajo), sin embargo los controles no funcionan libremente, es decir, no se pueden hacer giros de 180 grados, por lo tanto 
#no se puede girar de arriba a abajo o de derecha a izquierda sin antes pasar por otra dirección. Además, el movimiento de la serpiente no se detiene. Al inciar el juego también se podrá ver un pixel de comida, siendo 
#el objetivo de la serpiente y del jugador comerselo, una vez se lo ha comido aparecerá otro de forma automática en un lugar aleatoria. También se debe tener en cuenta que hay obstaculos y límites en la pantalla donde
#se juega. Los bordes, superior, inferior, derecho e izquierdo no pueden tocarse y los obstaculos tampoco, en caso de hacerlo se perderá una de las tres vidas que se dan inicialmente. Si pierdes todas las vidas el juego 
#finaliza.
#####################################################################

#DECLARACIÓN DE LAS VARIABLES QUE SE VAN A UTILIZAR

.data
displayAddress:			.word 0x10008000
comida:				.space 8
direccion:			.word 4
vidas:				.word 3
color_fondo:			.word 0x2596be
color_serpiente:		.word 0x00F10169
color_comida:			.word 0xe83137
color_pared:			.word 0x6f41b9
color_vidas:			.word 0xeee874
serpiente_x:			.space 4
serpiente_y:			.space 4
posicion: 			.space 8	

.text

#INICIO DEL PROGRAMA

inicio:

#Se pinta el fondo.
fondo:
	lw $t0, displayAddress  #Se carga el valor de la dirección de inicio de memoria
	addu $t1, $t0, 8192	#se suma al registro t0 8192 que es el final de la pantalla
	lw $t2, color_fondo     #Carga el valor almacenado en color_fondo
fondo_bucle:
	sw $t2, ($t0)
	addu $t0, $t0, 4   #se va sumando 4 al registro
	bne $t0, $t1, fondo_bucle  #se comparan los dos registros. Si no son iguales vuelve a fondo_bucle.

#Se definen los bordes de la pantalla, para ello se van calculando las posiciones de cada borde de la pantalla.
#Las posiciones calculados a lo largo del programa se han hecho generalmente siendo 256 por el número de filas y 4 por el número de columnas.
bordes:
	lw $t0, displayAddress
	#se hacen sumas con los registros en función de la sposiciones de cada borde para luego pintarlos.
	addu $t1, $t0, 1024	
	addu $t2, $t0, 1276 	#63x4 (esquina superior derecha, recorriendo las columnas hasta el final)
	addu $t3, $t0, 7936	#256x31 (esquina inferior izquierda, recorriendo las filas hasta abajo)
	addu $t4, $t0, 8192	#esquina inferior derecha
	addu $t0, $t0, 1024	#256x4 (en $t1 y $t0 se carga la esquina superior izquierda)
	lw $t5, color_pared

#Se pasan a pintar los bordes. Esto se hace sumando en los registros y comparandolos para comprobar si se salta al bucle de nuevo o no. Si no son iguales se salta.
bordes_bucle1:
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 4 #se suma 4 para que vaya variando el registro en el eje x
	addu $t1, $t1, 256 #se suma 256 para que vaya variando el registro en el eje y, va en funcion de las posiciones calculadas anteriormente.
	#de esta forma se va avanzando y pintando hasta que los registros indicados coincidan
	bne $t1, $t3, bordes_bucle1  #Comparacion de registros, si no son iguales (no nos encontramos en la esquina correspondiente) salta al bucle
#funcionan de igual forma que el bucle anterior
bordes_bucle2:
#ambos se mueven en x hasta que se llega a la esquina superior derecha
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 4 
	addu $t1, $t1, 4
	bne $t0, $t2, bordes_bucle2
bordes_bucle3:
#ambos se mueven al contrario que al principio hasta que se llega al final de la ventana
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 256
	addu $t1, $t1, 4
	bne $t1, $t4, bordes_bucle3

#Se pintan los obstaculos calculando la dirección a partir de las posiciones elegidas.
obstaculos:
	lw $t0, displayAddress
	addu $t0, $t0, 7168	#28x256
	addu $t0, $t0, 12 	#3x4
	addu $t1, $t0, 4 	
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 256 	
	addu $t1, $t1, 256 
	sw $t5, ($t0)
	sw $t5, ($t1)
	lw $t0, displayAddress
	addu $t0, $t0, 1792	#7x256
	addu $t0, $t0, 160 	#40x4
	addu $t1, $t0, 256
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 4	
	addu $t1, $t1, 4
	sw $t5, ($t0)
	sw $t5, ($t1)
	addu $t0, $t0, 4	
	addu $t1, $t1, 4
	sw $t5, ($t0)
	sw $t5, ($t1)

#Se pinta la primera comida que tendrá una posición determinada.
poner_comida:
	lw $t0, displayAddress
	addu $t0, $t0, 5340	#256x20+4x55
	li $t1, 20
	li $t2, 55
	sw  $t1, comida
	la $t3, comida	
	addu $t3, $t3, 4	
	sw $t2, ($t3)
	lw $t4, color_comida
	sw $t4, ($t0)

#Se pintan las vidas que tendrá el jugador	
pinta_vidas:
	lw $t0, displayAddress
	lw $t1, color_vidas
	addu $t0, $t0, 276	#256x1+4x5
	sw $t1, ($t0)
	addu $t0, $t0, 8
	sw $t1, ($t0)
	addu $t0, $t0, 8
	sw $t1, ($t0)

#Se pinta la serpiente en su posición determinada inicial.
carga_serpiente_inicial:
	lw $t0, displayAddress	#partiendo de la posición inicial que se muestra por pantalla (esquina superior izquierda)
	addu $t0, $t0, 3948	#256x15+4x27 (se carga el punto de la fila 5 columna 8 en t0)
	sw $t0, posicion 	#guarda la posición en memoria
	lw $t2, color_serpiente	#carga el color de la serpiente en t2
	sw $t2, ($t0)		#pinta la cabeza
	addu $t0, $t0, 256	#se carga la posición una fila más abajo (fila 6 columna 8)
	la $t1, posicion	#se carga la posicion en memoria de "pocision" en t1
	addu $t1, $t1, 4	#se le suma 4 para acceder al siguiente elemento del vector
	sw $t0, ($t1)		#se guarda la posición del primer segmento (en t0) en memoria (en la posicion de t1)
	li $t3, 15
	li $t4, 27
	sw $t3, serpiente_y
	sw $t4, serpiente_x

#Función main que hará funcionar al juego y que se pueda ir jugando.
main:
	jal control
	j pintar_serpiente
	
#Se va pintando la serpiente en funcion de su posicion y de como se vaya moviendo	
pintar_serpiente:
	la $t1, posicion        # Se guarda su posicion en una variable temporal $t1
	addu $t1, $t1, 4        # Para que se mueva se le agrega a la propia variable de la posicion 4 
	lw $t3, ($t1)           # Carga el valor de la posicion en $t3
	lw $t2, color_serpiente # Al moverse se pinta el bit del color de la serpiente y lo que ya no forma parte de la serpiente se vuelve del color del fondo.
	lw $t0, posicion
	sw $t2, ($t0)	 	
	
	# Detección de saltos de manera que al actualizar la posición lo siquiente que debe de ver es si hay colisión con la ventana
	jal actualizar_pos
	jal colision
	
	#Llamada a esperar para controlar el tiempo
	li $a0, 120			
	li $v0, 32
	syscall	
	
	lw $t2, color_fondo
	sw $t2, ($t3)

	#Implementación del sonido	
	li $a0, 25
	li $a1, 500
	li $a2, 109
	li $a3, 70
	li $v0, 31			
	syscall
	
	# Tras terminar con pintar la serpiente volvemos al main
	j main
	
#se actualiza la posición de la serpiente.	
actualizar_pos:
        # Tenemos una matriz bidimensional eso significa que tenemos dos ejes x e y
	lw $t0, posicion        # Poscición en el eje X
	la $t1, posicion        # Poscición en el eje Y
	addu $t1, $t1, 4        # Se le suma 4 en el posición Y 
	sw $t0, ($t1)           # Luego se le carga el valor del eje Y al eje x
	lw $t4, direccion       # Con la direccion vamos a saber a donde tiene orientado la cabeza de la serpiente, de forma que podemos añadir un condicional a la hora de moverse
	beq $t4, 1, arriba
	beq $t4, 2, abajo
	beq $t4, 3, izquierda
	beq $t4, 4, derecha
	jr $ra
# Si la cabeza esta orientada hacia arriba es decir Eje Y positivo
# Pero el comienzo del display es el 0,0 en la esquina superior izquierda por lo tanto se pone como negativo	
arriba:	
	addu $t0, $t0, -256    
	sw $t0, posicion       
	lw $t1, serpiente_y
	add $t1, $t1, -1 #se pone negativo
	sw $t1, serpiente_y #se guarda el registro para la posicion del eje de la serpiente, es decir, para ver en que direccion va para de esta forma poder pintarlo correctamente
	jr $ra
# Abajo, es decir eje y negativo, que debido a el formato del display se pone positivo.	
abajo:	
	addu $t0, $t0, 256
	sw $t0, posicion
	lw $t1, serpiente_y
	add $t1, $t1, 1 #se pone positivo
	sw $t1, serpiente_y #se guarda el registro para la posicion del eje de la serpiente, es decir, para ver en que direccion va para de esta forma poder pintarlo correctamente
	jr $ra
# Izquierda cabeza en el eje negativo del eje X
izquierda:
	addu $t0, $t0, -4
	sw $t0, posicion
	lw $t1, serpiente_x
	add $t1, $t1, -1 #se pone negativo
	sw $t1, serpiente_x #se guarda el registro para la posicion del eje de la serpiente, es decir, para ver en que direccion va para de esta forma poder pintarlo correctamente	
	jr $ra
# Derecha orientada la cabeza por lo tanto en el eje X positivo
derecha:
	addu $t0, $t0, 4
	sw $t0, posicion 
	lw $t1, serpiente_x
	add $t1, $t1, 1 #se pone positivo
	sw $t1, serpiente_x #se guarda el registro para la posicion del eje de la serpiente, es decir, para ver en que direccion va para de esta forma poder pintarlo correctamente
	jr $ra



# Esto es el control de direccion de la serpiente de forma que tenga que girar a los dos ojos si quiere hacer un cambio de direccion y sentido
# De forma que con la variable direccion le obligamos a que si se esta moviendo en el eje horizontal tenga que moverse en el vertical y viceversa
control:
	lw $t0, 0xFFFF0004
	lw $t1, direccion
	
	#compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta  que corresponda
	beq $t1, 1, vertical
	beq $t1, 2, vertical
	beq $t1, 3, horizontal
	beq $t1, 4, horizontal
	jr $ra
# Se asigna que el eje vertical es cuando se pusa los botones a y d	
vertical:
	beq $t0, 97, izq		#a #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta izq
	beq $t0, 100, der		#d #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta der
	jr $ra
# Se asigna que el eje horizontal es cuando se pusa los botones w y s
horizontal:
	beq $t0, 119, arr		#w
	beq $t0, 115, aba		#s
	jr $ra
# Aqui se cargan cada dirreccion izquierda, derecha, arriba y abajo y se fija en la direccion.
izq:
	li $t1, 3
	sw $t1, direccion
	jr $ra
der:
	li $t1, 4
	sw $t1, direccion
	jr $ra
arr:
	li $t1, 1
	sw $t1, direccion
	jr $ra
aba:
	li $t1, 2
	sw $t1, direccion
	jr $ra
	
	
# Funcion que dentro contiene a otras que cada obstaculo presenta una funcion que comprueba si hay o no colision	
colision:
# Las paredes de la ventana de forma que si choca con cualquiera de las 4 lineas que conforma la ventana hace un salto a la funcion morir.
con_paredes:
	lw $t0, serpiente_x
	lw $t1, serpiente_y
	#Se comparan los registros y en caso de y en caso de que sean iguales salta a la etiqueta morir
	beq $t0, 0, morir
	beq $t1, 4, morir
	beq $t0, 63, morir
	beq $t1, 31, morir
# Si la posición de la cabeza de la srpiente después de actualizarse se encuentra dentro de el obstáculo 1 se hace un salto a la función morir.
con_obs1:
	sle $t4, $t0, 4  #compara si el registro es menor o igua
	sle $t5, $t1, 29
	sge $t6, $t0, 3  #compara si el registro es mayor o igua
	sge $t7, $t1, 29
	and $t8, $t4, $t5
	and $t4, $t6, $t7
	and $t5, $t4, $t8
	beq $t5, 1, morir
# Si la posición de la cabeza de la srpiente después de actualizarse se encuentra dentro de el obstáculo 2 se hace un salto a la función morir.
con_obs2:
	sle $t4, $t0, 42 #compara si el registro es menor o igual
	sle $t5, $t1, 8
	sge $t6, $t0, 40 #compara si el registro es mayor o igual
	sge $t7, $t1, 7
	and $t8, $t4, $t5
	and $t4, $t6, $t7
	and $t5, $t4, $t8
	beq $t5, 1, morir #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta morir
# Se carga la posición de la comida en los dos ejes y si la serpiente colisiona con ella, salta a otra función llamada `come`	
con_comida:
	lw $t4, comida		#y de la comida
	la $t5, comida
	addu $t5, $t5, 4
	lw $t6, ($t5)		#x de la comida

	seq $t7, $t0, $t6
	seq $t8, $t1, $t4
	and $t4, $t7, $t8
	beq $t4, 1, come #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta come
	jr $ra
# Cuando muere se restauran las variables y se le quita una vida si todavía tiene 	
morir:
	#primero mediante una llamada se emite el sonido elegido
	li $a0, 25
	li $a1, 500
	li $a2, 56
	li $a3, 111
	li $v0, 31			
	syscall
	
	lw $t0, vidas
	bgt $t0, 0, pierde_vida #compara si se cumnple que el registro es mayor y si se cumple va a pierde_vida
# Funcion que muestra por pantallas las vidas, lleva el recuento y si llega a 0 se fuerza el cierre del programa	
pierde_vida:
	add $t0, $t0, -1
	sw $t0, vidas
	lw $t1, color_fondo
	sw $t1, ($t3)
	la $t2, posicion
	addu $t2, $t2, 4
	lw $t3, ($t2)
	sw $t1, ($t3)
	beq $t0, 2, dos #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta dos
	beq $t0, 1, uno #compara los registros para ver si se cumple que son iguales yt saltar a la etiqueta uno
	li $v0, 10 		# termina el programa
	syscall
# Función de mostrar cuando le queda dos vidas, la cual pinta la vida que se ha quitado del mismo color que el fondo
dos:
	lw $t0, displayAddress
	lw $t1, color_fondo
	addu $t0, $t0, 292	#256x1+4x5
	sw $t1, ($t0)
	j carga_serpiente_inicial
# Función de mostrar cuando le queda una vida, la cual pinta las vidas que se ha quitado del mismo color que el fondo
uno:
	lw $t0, displayAddress
	lw $t1, color_fondo
	addu $t0, $t0, 284	#256x1+4x5
	sw $t1, ($t0)
	j carga_serpiente_inicial
	
# La comida desaparece cuando se dibuja la serpiente encima.
#Para calcular donde sale la comida se ha intentado hacer una implemnetación pseudoaleatoria, ya que no tiene posición predeterminada y va en funcion de diferentes condiciones.
#Mediante operaciones, se suma en un eje y se resta en otro, se calcula la nueva posicion de la comida, si esta nueva posicion se sale de los bordes entonces se suma o se resta 
#dependiendo del borde y a continuación se pinta.

come:
	#se altera su posición, se comprueba si esta se sale de los bordes de la ventana del juego y se guarda la nueva posición en memoria
	add $t0, $t0, 12
	add $t1, $t1, -7
	bge $t0, 63, sale_d #compara si es mayor o igual a 0 y en caso de que se cumpka va a la etiqueta sale_d
	ble $t1, 4, sale_a #compara si es menor o igual a 0 y si se cumple va a la etiqueta sale_a
	sw $t0, ($t5)
	sw $t1, comida
 
arreglado:
	#se calcula con el tamaño de las filas y columnas donde se pinta esa nueva comida con su posición a partir de la displayAddress
	li $t6, 4
	li $t7, 256
	mul  $t0, $t0, $t6
	mul $t1, $t1, $t7
	lw $t4, displayAddress
	add $t4, $t4, $t0
	add $t4, $t4, $t1
	lw $t5, color_comida
	sw $t5, ($t4)
	
	#se realiza una llamada para emitir el sonido de comer
	li $a0, 25
	li $a1, 500
	li $a2, 71
	li $a3, 98
	li $v0, 31			
	syscall
	
	jr $ra
	
sale_d:
	#si se sale en las dimensiones horizontales por la derecha se resta su posición x y se guardan en memoria
	add $t0, $t0, -60
	sw $t0, ($t5)
	sw $t1, comida
	j arreglado

sale_a:
	#si se sale en las dimensiones verticales por arriba se aumenta su posición x y se guardan en memoria
	add $t1, $t1, 28
	sw $t1, comida
	sw $t0, ($t5)
	j arreglado
