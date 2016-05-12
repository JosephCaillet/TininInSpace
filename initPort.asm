ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "initPort.asm"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"

	; Enlever le commentaire si vous utilisez les afficheurs
;	#include "MAX7219.INC"


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
	
	
	LD	A,PBOR	;PB2
	OR	A,$04
	LD	A,PBOR
	
	LD	A,PBDDR
	OR	A,$04
	LD	A,PBDDR
	
	
	LD	A,PBOR	;PB4
	OR	A,$10
	LD	A,PBOR
	
	LD 	A,PBDDR
	OR	A,$10
	LD	A,PBDDR
	
	
	LD	A,PBOR	;PB5
	OR	A,$20
	LD	A,PBOR
	
	LD	A,PBDDR
	OR	A,$20
	LD	A,PBDDR
	
	
	LD	X,$04	;PB2
	CPL	X
	LD	var,X
	LD	A,PBDR
	AND	A,var
	LD	PBDR,A
	
	LD	X,$10	;PB4
	CPL	X
	LD	var,X
	LD	A,PBDR
	AND	A,var
	LD	PBDR,A
	
	LD	A,PBDR	;PB5
	OR	A,$20
	LD	A,PBDR
	
	
	LD	A,PAOR	;PA2
	OR	A,$04
	LD	A,PAOR
	
	LD	A,PADDR	;PA2
	OR	A,$04
	LD	A,PADDR
	
	LD	A,PADR	;PA2
	OR	A,$04
	LD	A,PADR
	
	RET

;************************************************************************

	END

;************************************************************************

















