# Segmento de código
	.data
# Primer vector
V1:	.word	1,2,3,4,5,6,7,8,9,10
# Hacer que el segundo vector esté en la siguiente fila
# de la ventana del segmento de datos del simulador
	.space	88
# Segundo vector
V2:	.word	10,20,30,40,50,60,70,80,90,100

# Segmento de código
	.text
# Cargar punteros a vectores
	la	$t0,V1          # $t0: al principio de V1
	addi	$t1,$t0,40      # $t1 al final de V1
	la	$t2,V2          # $t2 al principio de V2
# Bucle de suma de elementos
Bucle:
	lw	$t3,-4($t1)     # Leer elemento de V1 (de atrás hacia adelante)
	lw	$t4,0($t2)      # Leer elemento de V2 (de adelante hacia atrás)
	add	$t4,$t4,$t3     # Sumar elementos
	sw	$t4,0($t2)      # Almacenar suma en elemento de V2
	addi	$t1,$t1,-4      # Decrementar $t1
	addi	$t2,$t2,4       # Incrementar $t2
	bne 	$t1,$t0, Bucle  # Salir cuando $t1 apunte al principio de V1
# Fin del programa
	li	$v0,10
	syscall
