     AREA     factorial, CODE, READONLY
     EXPORT __main
     IMPORT printMsg
	 ;IMPORT printMsg2p
	 ;IMPORT printMsg4p


     ENTRY 
__main  FUNCTION	
	
         VLDR.F32   S3, =15
		 VLDR.F32   s9, =1   ; for increment
	     ;MOV  R3, =15
		 ;MOV  R2, =1
		 ;MOV  R4, #0x13
		 ;STR  R4,[R3] 
		 VLDR.F32   s5, =1	; value x
		; testing value for x = 5 
loopa   BL exp		;calculating exponential result stored in s14
		VADD.F32 s14, s14, s9
		VDIV.F32 s14, s9, s14
		VADD.F32 S5, S5, s9
		VMOV.F32 r0, s14
		BL printMsg
		VCMP.F32 s5, s3
		VMRS APSR_nzcv,FPSCR
		BNE loopa
		
        MOV  R2,  #0x20000000              ; Base Address
        LDR R0, [R2, #0x5]              ; 0x5 is the offset  
        LSL r1, r0, #1 ; shift 1 bit left
        LSL r2, r1, #1 ; shift 1 bit left
		MOV R0, #0x12
		;BL printMsg
		MOV R0, #0x12
		MOV R1, #0x13
        ;BL printMsg2p
		MOV R0, #0xAAAA
		MOV R1, #0xBBBB
		MOV R2, #0xCCCC
		MOV R3, #0xDDDD
		MOV R4, #0xEEEE
		;BL printMsg4p


 ;subr   VLDR.F32   r3, = 2	; value x
	;    VLDR.F32   r0, = 1	; value y
    ;	VADD.F32 r0, r3, r0
	 ;   BX lr
stop   B stop ; stop program
exp   	VLDR.F32   s4, = 1	; Result
      
		VLDR.F32   s14, = 0	; denominator
		;  VLDR.F32   s13, = 0	; iteration for denomination
		VLDR.F32   s7, = 1	; intermediate register a
		VLDR.F32	  s8, = 1	; flag for the sign 

		; VADD.F32	  s4, s5, s4 ; first number
		VLDR.F32   s0, =3    ; Number of iterations
		; This loop will calculate each term one by and 
		; either add or substract from the result register s4
	
	   
loop	VMUL.F32 s7, s7, s5 ;     ; Calculate the next term of the series 
		VADD.F32 s14, s14, s9		; increment the iterator value
		;VMUL.F32 s14, s14, s13 ;
		VDIV.F32 s7, s7, s14		; divide the denominator, and the result will be next term
			
		; This s7 register holds the next term of the series which has to either added or subtracted 
		VCMP.F32 s8, s9          ; For this s8 is used as a flag register which toogles between 0, 1 
		VMRS APSR_nzcv,FPSCR
		VADD.F32 s4, s4, s7     ; then the next term is added if the s8 is equal to 0
		VADDNE.F32 s8, s8, s9
		VSUBEQ.F32 s4, s4, s7		; then the next term is substracted if the s8 is equal to 1
		VSUBEQ.F32 s8, s8, s9
		VSUB.F32 s0, s0, s9
		VCMP.F32 s0, s9
		VMRS APSR_nzcv,FPSCR
		
		BNE loop
		BX lr
     ENDFUNC
     END 