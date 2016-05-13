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
	
	

;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
	BYTES
	segment byte 'ram0'

;writeSpi
dataout	DS.B 1 ;p
temp DS.B 1
;writeCmd
cmdout DS.B ;p

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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de cmd sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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



writeCmd:



writeData:



initTFT:



cmdList:



setAddrWindow:



fillRectTFT:



fillScreenTFT:



drawPixel:






;************************************************************************

	END

;************************************************************************
