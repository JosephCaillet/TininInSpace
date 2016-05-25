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
	EXTERN	dspNum
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

;dspNum
	EXTERN	scoreD.B
	EXTERN	scoreU.B
	EXTERN	numX.B
	EXTERN	numY.B


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

shipState DS.B 1
shipY DS.B 1
shipYPrev DS.B 1
shipMooveStep DS.B 1

scoreCarry DS.B 1

;------ timer -------;
timer	DS.B	1
subTimer	DS.B	1

;------ tc -------;
obsTab DS.B 27

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
	CALL	initPortSPI
	CALL	initOsc
	CALL	initTFT
	
	LD	A,#0;YOLO ! MAXIMUM OSC SPEED !!!!!!!
	ld	RCCR,A
	
	call init_masks
	rim

	ld a,#0
	ld shipState,a

	ret


;----------------------------------------------------;
;-                    init masks                    -;
;----------------------------------------------------;
init_masks:
	ld a,PADDR
	and a,#%11110111
	ld PADDR,a

	ld a,PAOR
	or a,#%00001000
	ld PAOR,a

	ld a,PBDDR
	and a,#%11111110
	ld PBDDR,a

	ld a,PBOR
	or a,#%00000001
	ld PBOR,a

	ld a,EICR
	;and a,#%10111110
	or a,#%11000011
	ld EICR,a

	ld a,EISR
	and a,#%00111111
	or a,#%00000011
	ld EISR,a

	ret


;----------------------------------------------------;
;-                    init game                     -;
;----------------------------------------------------;
init_game:
	LD	A,#$00
	LD	colorMSB,A
	LD	colorLSB,A
	LD	A,#0
	LD	x0win,A
	LD	y0win,A
	LD	A,#128
	LD	width,A
	LD	A,#160
	LD	height,A
	CALL	fillRectTFT

	ld a,#140
	ld shipY,a
	ld shipYPrev,a
	ld a,#5
	ld shipMooveStep,a
	ld a,#0
	ld shipState,a

	clr scoreD
	clr scoreU
	clr scoreCarry
	ld a,#145
	ld numY,a
	ld a,#5
	ld numX,a
	ld a,#1
	ld dspCoef,a

	call dspNum
	
	;timer init
	CALL initTimer
	;tc
	
	ret


;----------------------------------------------------;
;-               display title screen               -;
;----------------------------------------------------;
dsp_title_screen:
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

;----------------------------------------------------;
;-                   display ship                   -;
;----------------------------------------------------;
dsp_ship:

	ld a,shipY
	ld dsp0Y,a
	ld a,#59
	ld dsp0X,a
	ld a,#1
	ld dspCoef,a
	ld a,#28
	ld numSprite,a
	call setSprite
	call dspSprite

	ld a,shipY
	cp a,shipYPrev
	jrugt dsp_ship_cp_x_axe
		add a,#18
		ld y0win,a
		jp dsp_ship_cp_x_axe_end
dsp_ship_cp_x_axe
	sub a,shipMooveStep
	ld y0win,a
dsp_ship_cp_x_axe_end		
	LD	A,#$00
	LD	colorMSB,A
	LD	colorLSB,A
	ld a,dsp0X
	ld x0win,a
	ld a,shipMooveStep
	ld height,a
	ld a,#11
	ld width,a
	call fillRectTFT

	ret


;----------------------------------------------------;
;-                    moove ship                    -;
;----------------------------------------------------;
moove_ship:
	ld a,shipY
	ld shipYPrev,a 	;: shipYPrev = shipY
	
	;:: if(shipState != 0) then
	ld a,shipState
	cp a,#0
	jreq moove_ship_nothing
		;:: if(shipState = 1) then
		ld a,shipState
		cp a,#1
		jrne moove_ship_backward
			;:: if(shipY - shipMooveStep <= 0) then
			ld a,shipY
			sub a,shipMooveStep
			cp a,#0
			jrugt moove_ship_forward
				ld a,#140
				ld shipY,a ;: shipY = 140
				ld shipYPrev,a

				LD	A,#$00
				LD	colorMSB,A
				LD	colorLSB,A
				LD	A,dsp0X
				LD	x0win,A
				ld a,#0
				LD	y0win,A
				LD	A,#11
				LD	width,A
				LD	A,#18
				add a,shipMooveStep
				LD	height,A
				CALL	fillRectTFT
				call dsp_ship
				call lvlUp
				ret
			;:: end if
moove_ship_forward
			ld shipY,a 				;: shipY -= shipMooveStep
			jp moove_ship_nothing
		;:: end if
moove_ship_backward
		;:: if(shipY + shipMooveStep < 140) then
		ld a,shipY
		add a,shipMooveStep
		cp a,#140
		jruge moove_ship_nothing 
			ld shipY,a 				;: shipY += shipMooveStep
		;:: end if
moove_ship_nothing
	
	ret


;----------------------------------------------------;
;-                 Increment score                  -;
;----------------------------------------------------;
inc_score:
	
	ld a,scoreU
	;--- if(a == 9) ---
	cp a,#9
	jrne inc_score_inc_u
	;--- then{ ---
	clr scoreU
	ld x,scoreCarry
	inc x
	ld scoreCarry, x
	jp inc_score_n_inc_u
	;--- }end_then ---
	;--- else{ ---
inc_score_inc_u
	inc a
	ld scoreU, a
	;--- }end_else ---
	
inc_score_n_inc_u
	ld x,scoreCarry
	;--- if(x != 0) ---
	cp x,#0
	jreq inc_score_n_inc_d
	;--- then{ ---
	ld a,scoreD
		;--- if(a == 9) ---
	cp a,#9
	jrne inc_score_inc_d
		;--- then{ ---
	clr scoreD
	clr scoreCarry
	jp inc_score_n_inc_d
		;--- }end_then ---
		;--- else{ ---
inc_score_inc_d
	add a,scoreCarry
	ld scoreD, a
		;--- }end_else ---
	clr scoreCarry
	;-- }end_then ---
inc_score_n_inc_d

	ret

;----------------------------------------------------;
;-                 init timer                     -;
;----------------------------------------------------;
initTimer:
	PUSH	A
	
	LD	A,#0 ; 0->159
	LD	timer,A
	LD	A,#0 ; 0->255
	LD	subTimer,A
	
	LD	A,#$F8
	LD	colorMSB,A
	LD	A,#$00
	LD	colorLSB,A
	LD	A,#122
	LD	x0win,A
	LD	A,#0
	LD	y0win,A
	LD	A,#6
	LD	width,A
	LD	A,#160
	LD	height,A
	CALL	fillRectTFT
	
	POP	A
	RET



;----------------------------------------------------;
;-                 update timer                  -;
;----------------------------------------------------;
;if sub == 255
;		efacer barre timer
;		sub = 0
;		timer--
;else
;		sub++
;end
updateTimer:
	PUSH	A
	
	LD	A,subTimer
	CP	A,#10
	JRNE	inc_subTimer
	
	LD	A,#$00
	LD	colorMSB,A
	LD	A,#$00
	LD	colorLSB,A
	LD	A,#122
	LD	x0win,A
	LD	A,timer
	LD	y0win,A
	LD	A,#6
	LD	width,A
	LD	A,#1
	LD	height,A
	CALL	fillRectTFT
	
	CLR	subTimer
	INC	timer
	JP	end_if_upd_timer
	
inc_subTimer:
	INC	subTimer
	
end_if_upd_timer:
	POP	A
	RET



;----------------------------------------------------;
;-                 game over                  -;
;----------------------------------------------------;
gameOver:
	PUSH	A

	LD	A,#30
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#35
	LD	dsp0X,A
	LD	A,#18
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#32
	LD	numSprite,A
	CALL	setSprite
	LD	A,#36
	LD	dsp0X,A
	LD	A,#57
	LD	dsp0Y,A
	CALL	dspSprite
	
	POP	A
	RET
	
	
;----------------------------------------------------;
;-                 fct 3                  -;
;----------------------------------------------------;
lvlUp:
	call	inc_score
	call	dspNum
	CALL	initTimer
	ret

;----------------------------------------------------;
;-                 fct 4                  -;
;----------------------------------------------------;
dspObs:
	

	
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
	RSP
	call init

	call dsp_title_screen
wait_game_start
	ld a,shipState
	cp a,#0
	jreq wait_game_start

	call init_game
boucl
	
	call dsp_ship
	call moove_ship
	CALL	updateTimer
	
	JP	boucl



;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Proc�dure vide : retour au programme principal.

i_ship_forward:
	BTJF	PBDR,#0,pb0_push
	clr shipState
	iret
pb0_push
	ld a,#1
	ld shipState,a
	iret

i_ship_backward:
	BTJF	PADR,#3,pa3_push
	clr shipState
	iret
pa3_push
	ld a,#2
	ld shipState,a
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
ext3_it		DC.W	i_ship_forward	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	dummy_rt	; Adresse FFF6-FFF7h
ext0_it		DC.W	i_ship_backward	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
