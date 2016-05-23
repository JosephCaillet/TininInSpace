ST7/

;************************************************************************
; TITLE:                
; AUTHOR:               
; DESCRIPTION:          
;************************************************************************

	TITLE "SQUELET.ASM"
	
	MOTOROLA
	
	#include "ST7Lite2.INC"
	#include "screenLib.inc"
	#include "initPort.inc"
	#include "time.inc"


;************************************************************************
;
;  ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	EXTERN	initPortSPI
	;EXTERN	wait2ms
	EXTERN	waitTime.B
	;EXTERN	initOsc
	
	EXTERN	temp
	
	EXTERN initTFT
	
	EXTERN	fillRectTFT
	EXTERN	fillScreenTFT
	EXTERN	drawPixel
	EXTERN	setSprite
	EXTERN	dspSprite
;drawpixel & fillrect
	EXTERN	x0win.B
	EXTERN	y0win.B
	EXTERN	x1win.B
	EXTERN	y1win.B

;drawrect
	EXTERN	colorMSB.B
	EXTERN	colorLSB.B
	EXTERN	width.B
	EXTERN	height.B

;setSprite
	EXTERN	numSprite.B

;displaySrite
	EXTERN	dspCoef.B
	EXTERN	dsp0X.B
	EXTERN	dsp0Y.B


;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	
	BYTES
	
	segment byte 'ram0'

test DS.B 1
;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************




;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************


	WORDS

	segment byte 'rom'

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************




;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************

;------------------------------------------------------------------------

;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************





;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;************************************************************************
;
;  PROGRAMME PRINCIPAL
;
;************************************************************************

main:
	RSP			; Reset Stack Pointer
	CALL	initPortSPI
	CALL	initOsc
	CALL	initTFT
boucl

	
	JP	boucl



;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Procédure vide : retour au programme principal.



;************************************************************************
;
;  ZONE DE DECLARATION DES VECTEURS D'INTERRUPTION
;
;************************************************************************


	segment 'vectit'


		DC.W	dummy_rt	; Adresse FFE0-FFE1h
SPI_it		DC.W	dummy_rt	; Adresse FFE2-FFE3h
lt_RTC1_it	DC.W	dummy_rt	; Adresse FFE4-FFE5h
lt_IC_it	DC.W	dummy_rt	; Adresse FFE6-FFE7h
at_timerover_it	DC.W	dummy_rt	; Adresse FFE8-FFE9h
at_timerOC_it	DC.W	dummy_rt	; Adresse FFEA-FFEBh
AVD_it		DC.W	dummy_rt	; Adresse FFEC-FFEDh
		DC.W	dummy_rt	; Adresse FFEE-FFEFh
lt_RTC2_it	DC.W	dummy_rt	; Adresse FFF0-FFF1h
ext3_it		DC.W	dummy_rt	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	dummy_rt	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
