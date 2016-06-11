ST7/

;************************************************************************
; TITLE:           initPort.asm     
; AUTHOR:          Joseph CAILLET & Thomas COUSSOT     
; DESCRIPTION:     initialisation des port spi pour l'écran
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

var DS.B 1	;var temporaire pour contrer limitation mode d'adressage

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
MandComp MACRO dest mask
	LD	X,mask
	CPL	X
	LD	var,X
	LD	A,dest
	AND	A,var
	LD	dest,A
	MEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'or' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mor MACRO dest src
	LD	A,dest
	OR	A,src
	LD	dest,A
	MEND
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'and' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mand MACRO dest src
	LD	A,dest
	AND	A,src
	LD	dest,A
	MEND


	
;Les fonction d'init qui ne seront apelé qu'une fois en début de prgm ne sauvent pas les registres.

;;;;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
initPortSPI:
	LD	A,#$0C	;ctrl spi
	LD	SPICR,A
	
	LD	A,#$03	;status spi
	LD	SPISR,A	
	LD	A,#$5C	;ctrl spi
	LD	SPICR,A
	
	
	Mor PBOR, #$04
	Mor PBDDR, #$04
	
	Mor PBOR, #$10
	Mor PBDDR, #$10
	
	Mor PBOR, #$20
	Mor PBDDR, #$20
	
	Mand PBDR, #$FB
	Mand PBDR, #$EF
	Mor PBDR, #$20
	
	Mor PAOR, #$04
	Mor PADDR, #$04
	Mor PADR, #$04
	
	RET

;************************************************************************

	END

;************************************************************************