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

ship_state DS.B 1


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

;----------------------------------------------------;
;-                       init                       -;
;----------------------------------------------------;
init:
	RSP			; Reset Stack Pointer
	CALL	initPortSPI
	CALL	initOsc
	CALL	initTFT

	call init_masks
	call init_game

	ret


;----------------------------------------------------;
;-                    init masks                    -;
;----------------------------------------------------;
init_masks:
	ld a,paddr
	and a,#%11110111
	ld paddr,a

	ld a,paor
	or a,#%00001000
	ld paor,a

	ld a,pbddr
	and a,#%11111110
	ld pbddr,a

	ld a,pbor
	or a,#%00000001
	ld pbor,a

	ld a,eicr
	;and a,#%10111110
	or a,#%11000011
	ld eicr,a

	ld a,eisr
	and a,#%11111100
	or a,#%11000000
	ld eisr,a

	ret


;----------------------------------------------------;
;-                    init game                     -;
;----------------------------------------------------;
init_game:
	push a

	LD	A,#$00
	LD	colorMSB,A
	LD	A,#$00
	LD	colorLSB,A
	LD	A,#0
	LD	x0win,A
	LD	y0win,A
	LD	A,#128
	LD	width,A
	LD	A,#160
	LD	height,A
	CALL	fillRectTFT

	pop a
	ret


;----------------------------------------------------;
;-               display title screen               -;
;----------------------------------------------------;
display_title_screen:
	push a

	LD	A,#20
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#0
	LD	dsp0X,A
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#22
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#40
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#24
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#80
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#26
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#120
	LD	dsp0Y,A
	CALL	dspSprite

	pop a
	ret



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
	call init

	call display_title_screen

boucl

	
	JP	boucl



;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Procédure vide : retour au programme principal.

ship_forward:
	BTJT	PBDR,#0,pb0_push
	clr ship_state
	iret
pb0_push
	ld a,#1
	ld ship_state,a
	iret

ship_backward:
	BTJT	PADR,#3,pa3_push
	clr ship_state
	iret
pa3_push
	ld a,#2
	ld ship_state,a
	iret


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
ext3_it		DC.W	ship_forward	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	ship_backward	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
