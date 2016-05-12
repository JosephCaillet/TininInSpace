ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "initPort.asm"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	PUBLIC	initPortSPI


;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
	BYTES
	segment byte 'ram0'

var DS.B 1	;fourre tout pour contrer limitation mode d'adressage

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************
	WORDS
	segment byte 'rom'
	

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'et' bit à bit et complement a un ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mor MACRO dest src
	LD	X,src
	CPL	X
	LD	var,X
	LD	A,dest
	AND	A,var
	LD	dest,A
	MEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'or' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MandComp MACRO dest mask
	LD	A,dest
	OR	A,mask
	LD	A,dest
	MEND
	
;LEs fonction d'init qui ne seront apelé qu'une fois en début de prgm ne sauvent pas les registres.

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
initPortSPI:
	LD	A,$0C	;ctrl spi
	LD	SPICR,A
	
	LD	A,$03	;status spi
	LD	SPISR,A	
	LD	A,$5C	;ctrl spi
	LD	SPICR,A
	
	
	Mor PBOR, $04
	;LD	A,PBOR	;PB2
	;OR	A,$04
	;LD	A,PBOR
	
	Mor PBDDR, $04
	;LD	A,PBDDR
	;OR	A,$04
	;LD	A,PBDDR
	
	
	Mor PBOR, $10
	;LD	A,PBOR	;PB4
	;OR	A,$10
	;LD	A,PBOR
	
	Mor PBDDR, $10
	;LD 	A,PBDDR
	;OR	A,$10
	;LD	A,PBDDR
	
	
	Mor PBOR, $20
	;LD	A,PBOR	;PB5
	;OR	A,$20
	;LD	A,PBOR
	
	Mor PBDDR, $20
	;LD	A,PBDDR
	;OR	A,$20
	;LD	A,PBDDR
	
	
	MandComp PBDR, $04
	;LD	X,$04	;PB2
	;CPL	X
	;LD	var,X
	;LD	A,PBDR
	;AND	A,var
	;LD	PBDR,A
	
	MandComp PBDR, $10
	;LD	X,$10	;PB4
	;CPL	X
	;LD	var,X
	;LD	A,PBDR
	;AND	A,var
	;LD	PBDR,A
	
	Mor PBDR, $20
	;LD	A,PBDR	;PB5
	;OR	A,$20
	;LD	A,PBDR
	
	
	Mor PAOR, $04
	;LD	A,PAOR	;PA2
	;OR	A,$04
	;LD	A,PAOR
	
	Mor PADDR, $04
	;LD	A,PADDR	;PA2
	;OR	A,$04
	;LD	A,PADDR
	
	Mor PADR, $04
	;LD	A,PADR	;PA2
	;OR	A,$04
	;LD	A,PADR
	
	RET

;************************************************************************

	END

;************************************************************************

















