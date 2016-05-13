ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "screen_lib.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"
	#include "time.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************
	
DELAY EQU $80

	EXTERN wait500ms
	EXTERN wait

	EXTERN waitTime.B
;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
	BYTES
	segment byte 'ram0'

var	DS.B	1	;fourre tout pour contrer limitation mode d'adressage

dataout	DS.B	1;p write*
temp	DS.B	1

;commandList
addr	DS.B	1; p
numCmd	DS.B	1
numArg	DS.B	1
ms	DS.B	1;

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************
	WORDS
	segment byte 'rom'
	
Rcmd1	DC.B 5

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'et' bit à bit et complement a un ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MandComp MACRO dest mask
	PUSH	X
	PUSH	A
	LD	X,mask
	CPL	X
	LD	var,X
	LD	A,dest
	AND	A,var
	LD	dest,A
	POP A
	POP X
	MEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'or' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mor MACRO dest src
	PUSH X
	PUSH A
	LD	A,dest
	OR	A,src
	LD	A,dest
	POP A
	POP X
	MEND
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de donnees sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
;u: temp
writeSPI:
	PUSH A
	LD	A,dataout
	LD	SPIDR,A
boucle_wait_spi:
	LD	A,SPISR
	AND A,128
	JRNE boucle_wait_spi
	LD	A,SPISR
	LD	temp,A
	LD	A,SPIDR
	LD	temp,A
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de cmd sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
writeCmd:
	PUSH	A 
	MandComp PBDR, $04
	MandComp PBDR, $20
	CALL writeSPI
	Mor PBDR, $20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de data sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
writeData:
	PUSH	A 
	Mor PBDR, $04
	MandComp PBDR, $20
	CALL writeSPI
	Mor PBDR, $20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;
; execute liste de cmd ;
;;;;;;;;;;;;;;;;;;;;;;;;
;p: addr
cmdList:
	PUSH	X
	PUSH	A
	
	CLR	X
	LD	A,(addr,X)
	LD	numCmd,A
	INC	X

while_num_cmd:
	;for each cmd
	DEC	numCmd
	JREQ end_while_num_cmd
	
	LD	A,(addr,X)	;write cmd
	INC	X
	LD	dataout,A
	CALL writeCmd
	
	LD	A,(addr,X)	;numARg=
	INC	X
	LD	numArg,A
	
	;LD A,numArg	;ms =
	ADD	A,DELAY
	LD	ms,A
	
	MandComp numArg, DELAY	;numArg&=
	
while_num_arg:
	DEC	numArg
	JREQ	end_while_num_arg
	
	LD	A,(addr,X)	;write cmd
	INC	X
	LD	dataout,A
	CALL writeData
	JP while_num_arg
end_while_num_arg:
	
	LD	A,ms
	CP	A,#0
	JREQ while_num_cmd
	
	LD	A,(addr,X)
	INC	X
	LD	ms,A
	
	;LD A,ms
	CP	A,#255
	JRNE skip_ms_eq_255
	CALL wait500ms
	JP while_num_cmd
	
skip_ms_eq_255:
	LD	ms,A
	LD	A,waitTime
	CALL	wait
	JP while_num_cmd
	
end_while_num_cmd:
	POP	A
	POP	X
	RET

;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation ecran ;
;;;;;;;;;;;;;;;;;;;;;;;;
initTFT:
	PUSH A
	
	Mor	PBDR, $10
	MandComp	PBDR, $20
	CALL wait500ms
	
	MandComp	PBDR, $10
	CALL wait500ms
	
	Mor PBDR, $10
	CALL wait500ms
	
	Mor	PBDR, $20
	
	LD	A,Rcmd1
	LD	addr,A
	CALL cmdList
	
	LD	A,Rcmd2red
	LD	addr,A
	CALL cmdList
	
	LD	A,Rcmd3
	LD	addr,A
	CALL cmdList
	
	LD	A,ST7735_MADCTL
	LD	dataout,A
	CALL	writeCmd
	
	LD	A,$C0
	LD	dataout,A
	CALL	writeData
	
	POP A
	RET
	
	

setAddrWindow:



fillRectTFT:



fillScreenTFT:



drawPixel:






;************************************************************************

	END

;************************************************************************
