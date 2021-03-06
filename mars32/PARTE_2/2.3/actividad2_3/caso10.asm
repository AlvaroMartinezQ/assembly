	.data
m1:	.asciiz "Caso de prueba 10\n"
m2:	.asciiz "Fin del caso de prueba 10\n"
str_pedir:
	.asciiz	"Introduzca un dato num�rico positivo: "
str_indice:
	.asciiz	"Indice = "
eoln:	.byte	'\n'
	.text
# Comienzo
main:
# Mensaje inicial
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m1
	syscall
# Proceso
	# Cargar y conectar la herramienta Digital Lab Sim
# Activar interrupciones del temporizador
activar:
	li	$v0,1002
	li	$a0,1
	syscall
# Pedir el dato de entrada
pedir_dato:
	li	$v0,4		# Escribir tira de caracteres
	la	$a0,str_pedir
	syscall
	li	$v0,5		# Leer entero
	syscall
	ble	$v0,$zero,pedir_dato
# Iniciar �ndice de bucle
	move	$t0,$v0
# Bucle
bucle:
	li	$v0,4		# Escribir tira de caracteres
	la	$a0,str_indice
	syscall
	li	$v0,1		# Escribir entero
	move	$a0,$t0
	syscall
	li	$v0,11		# Escribir salto de l�nea
	lbu	$a0,eoln
	syscall
	addi	$t0,$t0,-1	# Decrementar �ndice
	bne	$t0,$zero,bucle	# Comprobar condici�n
# Desactivar interrupciones del temporizador
desactivar:
	li	$v0,1002
	li	$a0,0
	syscall
# Mensaje final
final:
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m2
	syscall
# Terminar
	li	$v0,17	# syscall 4 (print_str)
	li	$a0,0
	syscall
