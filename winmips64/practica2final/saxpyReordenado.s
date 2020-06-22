; saxpy: s = ax + y
	
.data

x: 	.double 1.2,3.4,5.6,7.8,9.0,0.9,1.8,2.7,3.6,4.5

y: 	.double 1.0,2.0,3.0,4.0,5.0,6.0,7.0,8.0,9.0,0.0

s: 	.double 0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0

	
.text
	 
	daddi r1,r0,0
	
	daddi r2,r0,2		;alpha
	daddi r3,r0,80

loop:	
	l.d f1,x(r1)
	
	mtc1 r2,f2		
	cvt.d.l f2,f2
	
	mul.d f3,f1,f2
	
	l.d f4,y(r1)
	
	add.d f5,f3,f4

	cvt.l.d f6,f5
		
	s.d f5,s(r1)
	
	daddi r1,r1,8

	bne r1,r3,loop

	halt
