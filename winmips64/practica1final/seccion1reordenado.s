.data
A: 	.word 10,11,12,13,14,15,16,17,18,19
B: 	.word 20,21,22,23,24,25,26,27,28,29
C: 	.word 30,31,32,33,34,35,36,37,38,39

.text
	daddi R1,R0,0
	daddi R4,R0,0
	daddi R20,R0,72
	daddi R19,R0,8
	daddi R18,R0,10
	daddi R17,R0,1
	daddi R16,R0,2
	daddi R5,R0,40

bucle:  daddi R1,R1,8
	daddi R4,R4,1
	slt R3,R1,R5
	beq R3,R0,else
	ld R10,A(R1)
        daddi R2,R1,8
	daddi R11,R10,10
        ld R12,B(R2)
	sd R11,A(R1)
	dadd R12,R12,R16
	dadd R12,R11,R12
        dadd R13,R12,R4
	sd R12,B(R1)
	sd R13,C(R1)
	bne R1,R20,bucle
        j fin


else:   dsub R6,R1,R19
        ld R10,A(R6)
	dsub R11,R10,R18
	sd R11,A(R1)
	bne R1,R20,bucle
fin:   	ld R10,A(R0)
	sd R17,B(R0)
	daddi R11,R10,5
	sd R17,C(R0)
	sd R11,A(R0)
	halt
