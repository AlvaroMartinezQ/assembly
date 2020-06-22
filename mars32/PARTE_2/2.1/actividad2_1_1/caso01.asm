	.data
hueco:	.space	2
dato:	.word	10
m1:	.asciiz "Caso de prueba 1\n"
m2:	.asciiz "Fin del caso de prueba 1\n"
	.text
# Comienzo
main:
# Mensaje inicial
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m1
	syscall
# Proceso
	la	$t0,dato
	lw	$3,2($t0)
	lw	$3,4($t0)
	lw	$3,6($t0)
# Mensaje final
	li	$v0,4	# syscall 4 (print_str)
	la	$a0,m2
	syscall
# Terminar
	li	$v0,17	# syscall 4 (print_str)
	li	$a0,0
	syscall
