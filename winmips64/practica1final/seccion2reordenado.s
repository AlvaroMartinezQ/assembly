.data
x:     	.word 0xFFFFFFFFFFFFFFFF
y:      .word 0xFFFFFFFFFFFFFFFF
w:     	.word 0,0

.text
start:  jal mul         
       	nop			
       	halt
mul:    daddi r1,r0,64   
       	daddi r5,r0,63   
       	daddu r2,r0,r0   
       	daddu r10,r0,r0   
       	ld r3,x(r0)      
       	ld r4,y(r0)      
      	andi r9,r3,1     
       	dsub r9,r0,r9    
       	dsrl r3,r3,1     
again:   and r6,r4,r9
        daddu r2,r2,r6
        sltu r7,r2,r6    
        dsllv r7,r7,r5   
        andi r10,r2,1    
        dsllv r10,r10,r5 
        dsrl r2,r2,1     
        or r2,r2,r7      
        andi r9,r3,1     
        dsub r9,r0,r9    
        dsrl r3,r3,1	 
        daddi r1,r1,-1   
        or r3,r3,r10     
        bnez r1,again

        sd r2,w(r0)     
        sd r3,w+8(r0)	 
        jr r31
