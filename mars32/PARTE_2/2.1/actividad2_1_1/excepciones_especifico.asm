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

# Mensajes específicos para cada excepción
INT_MSG:	.asciiz	" [Interrupción]"
MOD_MSG:	.asciiz	" [TLB]"
TLBL_MSG:	.asciiz	" [TLBL]"
TLBS_MSG:	.asciiz	" [TLBS]"
ADEL_MSG:	.asciiz	" [Error de dirección en lectura de dato o instrucción]"
ADES_MSG:	.asciiz	" [Error de dirección en almacenamiento]"
IBE_MSG:	.asciiz	" [Dirección errónea de instrucción]"
DBE_MSG:	.asciiz	" [Dirección errónea de dato]"
SYSCALL_MSG:	.asciiz	" [Llamada a sistema no implementada]"
BKPT_MSG:	.asciiz	" [Punto de ruptura]"
RI_MSG:		.asciiz	" [Instrucción reservada]"
CpU_MSG:	.asciiz	""
OV_MSG:		.asciiz	" [Desbordamiento aritmético]"
TRAP_MSG:	.asciiz	" [Trap]"
R14_MSG:	.asciiz	""
DIVZ_MSG:	.asciiz	" [División por cero]"
ID16_MSG:	.asciiz	""
ID17_MSG:	.asciiz	""
C2E_MSG:	.asciiz	" [Coprocesador 2]"
R19_MSG:	.asciiz	""
R20_MSG:	.asciiz	""
R21_MSG:	.asciiz	""
MDMX_MSG:	.asciiz	" [MDMX]"
WATCH_MSG:	.asciiz	" [Watch]"
MCHECK_MSG:	.asciiz	" [Chequeo de máquina]"
R25_MSG:	.asciiz	""
R26_MSG:	.asciiz	""
R27_MSG:	.asciiz	""
R28_MSG:	.asciiz	""
R29_MSG:	.asciiz	""
CACHE_ERR_MSG:	.asciiz	" [Cache]"
R31_MSG:	.asciiz	""
# Tabla de punteros a los mensajes de excepción
		.align	2
MSG_TABLE:	.word	INT_MSG, MOD_MSG, TLBL_MSG, TLBS_MSG	 	# Excepciones 0-3
		.word	ADEL_MSG, ADES_MSG, IBE_MSG, DBE_MSG 		# Excepciones 4-7
		.word	SYSCALL_MSG, BKPT_MSG, RI_MSG, CpU_MSG	 	# Excepciones 8-11
		.word	OV_MSG, TRAP_MSG, R14_MSG, DIVZ_MSG 		# Excepciones 12-15
		.word	ID16_MSG, ID17_MSG, C2E_MSG, R19_MSG	 	# Excepciones 16-19
		.word	R20_MSG, R21_MSG, MDMX_MSG, WATCH_MSG 		# Excepciones 20-23
		.word	MCHECK_MSG, R25_MSG, R26_MSG, R27_MSG 		# Excepciones 24-27
		.word	R28_MSG, R29_MSG, CACHE_ERR_MSG, R31_MSG 	# Excepciones 28-31

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
		srl	$a0,$k0,2
		syscall
		# Imprimir mensaje indicando la excepción producida
		li	$v0,4		# syscall 4 (print_str)
		la	$a0,MSG_TABLE
		addu	$a0,$a0,$k0
		lw	$a0,0($a0)
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
	# (nunca se va a ejecutar en esta versión del manejador)
return_exception:
		eret

