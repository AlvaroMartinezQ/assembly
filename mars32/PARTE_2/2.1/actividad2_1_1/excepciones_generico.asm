###############################################################
#
# MANEJADOR DE EXCEPCIONES: VARIABLES Y DEFINICIONES
#
###############################################################		
		.kdata

# Zona de salvaguarda de registros
		.align	2
sv_at:		.word	0
sv_a0:		.word	0
sv_v0:		.word	0

# Mensajes
__msgExc__:	.asciiz "Ha ocurrido una excepción\n"
__msgExcCode__:	.asciiz "   Código de excepción  : "
__msgVAddr__:	.asciiz	"   Registro VAddr   ($8): "
__msgStatus__:	.asciiz "   Registro Status ($12): "
__msgCause__:	.asciiz "   Registro Cause  ($13): "
__msgEPC__:	.asciiz "   Registro EPC    ($14): "
__eoln__:	.byte	'\n'
__msgAbort__:	.asciiz	"Programa abortado\n"

###############################################################
#
# MANEJADOR DE EXCEPCIONES: CÓDIGO
#
###############################################################		
		.ktext	0x80000180
EXCEPTION_HANDLER_ENTRY:
# Salvar registros por si hubiera que retornar del manejador
	# No se salvan $k0/$k1: están reservados para uso del kernel
	# No se usa la pila para salvar registros: manejador no reentrante
	# Salvar $at en $k0 (antes de utilizar pseudoinstrucciones)
		move	$k0,$at
	# Salvar copia de $at en memoria
		sw	$k0,sv_at
	# Salvar copia de $v0 en memoria
		sw	$v0,sv_v0
	# Salvar copia de $a0 en memoria
		sw	$a0,sv_a0
# Identificar la causa de la excepción
identify_cause:
   # Copiar registro Cause ($13-coprocesador 0) en $k0
		mfc0	$k0,$13
   # Extraer el campo de código de excepción (ExcCode)
		andi	$k0,$k0,0x7c
# Tratamiento genérico de las excepciones
	# Imprimir mensaje genérico de aviso de excepción
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgExc__
		syscall
	# Imprimir causa de la excepción
		# Imprimir código de causa (decimal)
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgExcCode__
		syscall
		li	$v0,1		# syscall 1 (print_int)
		move	$a0,$k0
		srl	$a0,$a0,2
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
	# Imprimir contenido de los registros Status, Cause, EPC y VAddr
		# VAddr
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgVAddr__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$8
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# Status
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgStatus__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$12
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# Cause
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgCause__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$13
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
		# EPC
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgEPC__
		syscall
		li	$v0,34		# syscall 34 (print_int_hexadecimal)
		mfc0	$a0,$14
		syscall
		li	$v0,11		# syscall 11 (print_char)
		lb	$a0,__eoln__
		syscall
	# Abortar la ejecución del programa que generó la excepción
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,__msgAbort__
		syscall
		li	$v0,17		# syscall 17 (exit with code)
		li	$a0,1		# Error
		syscall
# Los siguientes pasos nunca se van a ejecutar en esta versión del manejador
# Restaurar registros salvados
   # Restaurar $v0
		lw	$v0,sv_v0
   # Restaurar $a0
		lw	$s0,sv_a0
   # Restaurar $at
		lw	$at,sv_at
# Retornar del manejador de excepción
return_exception:
		eret

