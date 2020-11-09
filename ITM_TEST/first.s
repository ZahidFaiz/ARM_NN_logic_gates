     AREA     factorial, CODE, READONLY
     EXPORT __main
     ;IMPORT printMsg
	 ;IMPORT printMsg2p
	 IMPORT printMsg4p
	 IMPORT printfMsgAND	 
     IMPORT printfMsgOR
	 IMPORT printfMsgNOT
	 IMPORT printfMsgNAND
	 IMPORT printfMsgNOR 
     ENTRY 
__main  FUNCTION	
	
		 MOV r6, #1
        ; VLDR.F32   s3, =25  ;number of terms
		 VLDR.F32   s9, =1   ; for increment
		 VLDR.F32   s5, =-5	; value x
		 VLDR.F32   s1, =0.5  ;comparison condition
	
	  ;AND
logic_and VLDR.F32 S7,=-0.1  
		VLDR.F32 S8,=0.2
		VLDR.F32 S12,=0.2
		VLDR.F32 S10,=-0.2
		MOV r5, #1
		BL printfMsgAND
		B input
	  ;OR		
OR		VLDR.F32 S7,=-0.1  
		VLDR.F32 S8,=0.7
		VLDR.F32 S12,=0.7
		VLDR.F32 S10,=-0.1
		MOV r5, #1
		BL printfMsgOR
		B input
	   ;NOT
NOT		VLDR.F32 S7,=0.5  
		VLDR.F32 S8,=-0.7
		VLDR.F32 S12,=0
		VLDR.F32 S10,=0.1
		MOV r5, #1
		BL printfMsgNOT
		B input
		;NAND	
NAND	VLDR.F32 S7,=0.6  
		VLDR.F32 S8,=-0.8
		VLDR.F32 S12,=-0.8
		VLDR.F32 S10,=0.3
		MOV r5, #1
		BL printfMsgNAND
		B input
		;Nor
NOR		VLDR.F32 S7,=0.5  
		VLDR.F32 S8,=-0.7
		VLDR.F32 S12,=-0.7
		VLDR.F32 S10,=0.1
		MOV r5, #1
		BL printfMsgNOR
		B input
		
	
input 		MOV R1, #1
			VMOV.F32 S16,R1
			VCVT.F32.S32 S16,S16 
			MOV R2, #0
			VMOV.F32 S17, R2
			VCVT.F32.S32 S17,S17 
			MOV R3, #0; input C 
			VMOV.F32 S18,R3
			VCVT.F32.S32 S18,S18
			B WEIGHT
			
input2		MOV R1, #1
			VMOV.F32 S16,R1
			VCVT.F32.S32 S16,S16
			MOV R2, #0
			VMOV.F32 S17, R2
			VCVT.F32.S32 S17,S17
			MOV R3, #1 
			VMOV.F32 S18,R3
			VCVT.F32.S32 S18,S18
			B WEIGHT
			
input3		MOV R1, #1
			VMOV.F32 S16,R1 
			VCVT.F32.S32 S16,S16
			MOV R2, #1
			VMOV.F32 S17, R2
			VCVT.F32.S32 S17,S17
			MOV R3, #0
			VMOV.F32 S18,R3
			VCVT.F32.S32 S18,S18
			B WEIGHT

input4		MOV R1, #1
			VMOV.F32 S16,R1
			VCVT.F32.S32 S16,S16
			MOV R2, #1
			VMOV.F32 S17, R2
			VCVT.F32.S32 S17,S17
			MOV R3, #1
			VMOV.F32 S18,R3
			VCVT.F32.S32 S18,S18
			B WEIGHT
next_gate	ADD r6, #1
			CMP r6, #2
			BEQ OR
			CMP r6, #3
			BEQ NOT
			CMP r6, #4
			BEQ NAND
			CMP r6, #5
			BEQ NOR
stop    	B stop 

WEIGHT		VMUL.F32 S19,S7,S16;
			VMOV.F32 S22,S19
			VMUL.F32 S20,S8,S17
			VADD.F32 S22, S22, S20
			VMUL.F32 S21,S12,S18
			VADD.F32 S22, S22, S21
			VADD.F32 S22, S22, S10; 
			VMOV.F32 S5,S22
			B sigmoid	

sigmoid 	BL exp		;calculating exponential result stored in s4
			VADD.F32 s4, s4, s9
			VDIV.F32 s4, s9, s4    ;s4 = 1/(1+e^-x) ;sigmoid
			;VADD.F32 S5, S5, s9
			VCMP.F32 s4, s1
			VMRS.F32 APSR_nzcv,FPSCR
			ITE HI
			MOVHI r0, #1     ;result in r0
			MOVLS r0, #0	 ;result in r0
			BL printMsg4p
			ADD r5, #1
			CMP r5, #2
			BEQ input2
			CMP r5, #3 
			BEQ input3
			CMP r5, #4
			BEQ input4
			CMP r5, #5
			BEQ next_gate
;s5 holds value of x and s4 holds value of exponential 
exp   	VLDR.F32   s4, =1	; Result
      
		VLDR.F32   s14, =0	; denominator
		VMOV.F32   s7, #1	; intermediate register a
		VLDR.F32	  s8, =1	; flag for the sign 
		VLDR.F32   s0, =10    ; Number of iterations
		; This loop will calculate each term one by and 
		; either add or substract from the result register s4
	
	   
loop	VMUL.F32 s7, s7, s5 ;     ; Calculate the next term of the series 
		VADD.F32 s14, s14, s9		; increment the iterator value
		VDIV.F32 s7, s7, s14		; divide the denominator, and the result will be next term
			
		; This s7 register holds the next term of the series which has to either added or subtracted 
		VCMP.F32 s8, s9          ; For this s8 is used as a flag register which toogles between 0, 1 
		VMRS APSR_nzcv,FPSCR
		VADDNE.F32 s4, s4, s7     ; then the next term is added if the s8 is equal to 0
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