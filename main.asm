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
	EXTERN	clrScreenZoomIn
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
;setPalet
	EXTERN	setPalet1
	EXTERN	setPalet2

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
shipX EQU 59
;obstacles
OBS_MAX   EQU  27

;timer
SUB_TIMER_INIT EQU 2
SUB_TIMER_DIF_2 EQU 1
SUB_TIMER_DIF_3 EQU 0

lvl DS.B 1

shipState DS.B 1
shipY DS.B 1
shipYPrev DS.B 1
shipMoveStep DS.B 1

scoreCarry DS.B 1

;------ timer -------;
timer	DS.B	1
subTimer	DS.B	1
timerLvl DS.B 1

;------ obstacle -------;
obsTab DS.B 27
obsMoveStep DS.B 1
obsDir DS.B 1
obsNb DS.B 1

xObsHB	DS.B	1;HB = hitbox
yObsHB	DS.B	1
x1ShipHB	DS.B	1
x2ShipHB	DS.B	1
yShipHB	DS.B	1

norrisMode	DS.B	1; 0 = 1joueur, 1 = 2joueur
p2Lose	DS.B	1;is second player winner

;------ Surprise ! -------;
easterCpt DS.B 1


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

	call init_st7_timer

	ld a,#0
	ld shipState,a
	
	CALL	setPalet1

	ret


;----------------------------------------------------;
;-                    init masks                    -;
;----------------------------------------------------;
init_masks:
	ld	a,PADDR
	and	a,#%11110111
	ld	PADDR,a

	ld	a,PAOR
	or	a,#%00001000
	ld	PAOR,a

	ld	a,PBDDR
	and	a,#%11111110
	ld	PBDDR,a

	ld	a,PBOR
	or	a,#%00000001
	ld	PBOR,a

	ld	a,EICR
	;and a,#%10111110
	or	a,#%11000011
	ld	EICR,a

	ld	a,EISR
	and	a,#%00111111
	or	a,#%00000011
	ld	EISR,a
	
	;liaison série PA7 reception, PA4 emmission, switch PA0
	LD	A,PADDR
	AND	A,#%01111110
	OR	A,#%00010000
	LD	PADDR,A

	LD	A,PAOR
	OR	A,#%10010001
	LD	PAOR,A
	
	LD	A,EICR
	AND	A,#%11111011
	OR	A,#%00001000
	LD	EICR,A

	LD	A,EISR
	OR	A,#%00001100
	ld	EISR,a

	ret


;----------------------------------------------------;
;-                  init st7 timer                  -;
;----------------------------------------------------;

init_st7_timer:
	LD	A,LTCSR2
	or a,#%00000010
	LD	LTCSR2,A

	ld a,#$e5
	ld LTCARR,a

	ret


;----------------------------------------------------;
;-                    init obsTab                   -;
;----------------------------------------------------;
initObsTab:
	
	clr y
	ld a,#$ff

initObsTabWhile
	;:: while (y <= 27)
	cp y,#27
	jruge initObsTabEndWhile

		ld (obsTab,y),a

	inc y
	jp initObsTabWhile
initObsTabEndWhile
	;:: end while

	ld y,#4
	ld a,#%00110000
	ld (obsTab,y),a
	ld y,#10
	ld a,#%10111001
	ld (obsTab,y),a
	ld y,#20
	ld a,#%00000100
	ld (obsTab,y),a

	ret


;----------------------------------------------------;
;-                    init game                     -;
;----------------------------------------------------;
init_game:
	
	LD	A,#$00
	LD	colorMSB,A
	LD	A,#$00
	LD	colorLSB,A
	
	CALL	clrScreenZoomIn

	ld a,#140
	ld shipY,a
	ld shipYPrev,a
	ld a,#3
	ld shipMoveStep,a
	ld a,#0
	ld shipState,a

	clr lvl
	clr easterCpt

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
	ld a,#SUB_TIMER_INIT
	ld timerLvl,a
	CALL initTimer
	;obstacles
	ld a,#1
	ld obsMoveStep,a
	ld a,#3
	ld obsNb,a

	clr obsDir
	
	;secondplayer
	CLR	p2Lose

	call initObsTab
	call checkNorrisMode
	
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
	LD	A,#40
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#24
	LD	numSprite,A
	CALL	setSprite
	LD	A,#80
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#26
	LD	numSprite,A
	CALL	setSprite
	LD	A,#120
	LD	dsp0Y,A
	CALL	dspSprite

	pop a
	ret


;----------------------------------------------------;
;-                   check easter                   -;
;----------------------------------------------------;
checkEaster:
	ld a,easterCpt
	cp a,#20
	jrne checkEaster_ret
		call dspBsodScreen
checkEaster_ret
	ret

checkEasterBP:
	BTJT	PBDR,#0,checkEasterBP_ret
	BTJT	PADR,#3,checkEasterBP_ret
	inc easterCpt
checkEasterBP_ret
	ret
	


;----------------------------------------------------;
;-               display bsod screen                -;
;----------------------------------------------------;
dspBsodScreen:
	PUSH A
	
	CALL	setPalet2
	
	LD	A,#36
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#0
	LD	dsp0X,A
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#38
	LD	numSprite,A
	CALL	setSprite
	LD	A,#40
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#40
	LD	numSprite,A
	CALL	setSprite
	LD	A,#60
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#42
	LD	numSprite,A
	CALL	setSprite
	LD	A,#80
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#44
	LD	numSprite,A
	CALL	setSprite
	LD	A,#120
	LD	dsp0Y,A
	CALL	dspSprite
	
	CALL	setPalet1

dspBsodScreen_yolo
	wfi ;#saveTheTrees
	jp dspBsodScreen_yolo
	
	POP	A
	RET



;----------------------------------------------------;
;-                   display ship                   -;
;----------------------------------------------------;
dsp_ship:

	ld a,shipY
	ld dsp0Y,a
	ld a,#shipX
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
	sub a,shipMoveStep
	ld y0win,a
dsp_ship_cp_x_axe_end		
	LD	A,#$00
	LD	colorMSB,A
	LD	colorLSB,A
	ld a,dsp0X
	ld x0win,a
	ld a,shipMoveStep
	ld height,a
	ld a,#11
	ld width,a
	call fillRectTFT

	ret


;----------------------------------------------------;
;-                display broken ship               -;
;----------------------------------------------------;
dsp_broken_ship:
	push a

	ld a,shipY
	ld dsp0Y,a
	ld a,#shipX
	ld dsp0X,a
	ld a,#1
	ld dspCoef,a
	ld a,#34
	ld numSprite,a
	call setSprite
	call dspSprite

	pop a
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
			;:: if(shipY - shipMoveStep <= 0) then
			ld a,shipY
			cp a,shipMoveStep
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
				add a,shipMoveStep
				LD	height,A
				CALL	fillRectTFT
				call dsp_ship
				call lvlUp
				ret
			;:: end if
moove_ship_forward
			sub a,shipMoveStep
			ld shipY,a 				;: shipY -= shipMoveStep
			jp moove_ship_nothing
		;:: end if
moove_ship_backward
		;:: if(shipY + shipMoveStep < 140) then
		ld a,shipY
		add a,shipMoveStep
		cp a,#140
		jruge moove_ship_nothing 
			ld shipY,a 				;: shipY += shipMoveStep
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
	call dspBsodScreen
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
	CP	A,timerLvl
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
	
	;CALL	checkNorrisMode
	
	LD	A,#$00
	LD	colorMSB,A
	LD	A,#$00
	LD	colorLSB,A
	LD	A,#5
	LD	x0win,A
	LD	A,#145
	LD	y0win,A
	LD	A,#14
	LD	width,A
	LD	A,#10
	LD	height,A
	CALL	fillRectTFT
	
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
	
	LD	a,#96
	LD	numY,a
	LD	a,#49
	LD	numX,a
	call	dspNum
	
	
	LD	A,#46
	LD	numSprite,A
	CALL	setSprite
	LD	A,#30
	LD	dsp0X,A
	LD	A,#130
	LD	dsp0Y,A
	LD	A,#1
	LD	dspCoef,A
	CALL	dspSprite
	
	LD	A,p2Lose
	CP	A,#1	;si p2 perd
	JREQ	draw_p1Win	;p1 gagne
	
draw_p1Lose
	LD	A,#48
	LD	numSprite,A
	CALL	setSprite
	LD	A,#65
	LD	dsp0X,A
	CALL	dspSprite
	JP	end_gameOver
	
draw_p1Win
	LD	A,#50
	LD	numSprite,A
	CALL	setSprite
	LD	A,#73
	LD	dsp0X,A
	CALL	dspSprite

end_gameOver
	POP	A
	RET
	
	
;----------------------------------------------------;
;-                    next level                    -;
;----------------------------------------------------;
lvlUp:
	PUSH	A
	
	inc lvl
	call	inc_score
	
	LD	a,#145
	LD	numY,a
	LD	a,#5
	LD	numX,a
	LD	a,#1
	LD	dspCoef,a
	call	dspNum
	
	ld a,lvl
	cp a,#5
	jrne lvlUp_skip_5
		ld a,#SUB_TIMER_DIF_2
		ld timerLvl,a
lvlUp_skip_5
	cp a,#15
	jrne lvlUp_skip_15
		ld a,#SUB_TIMER_DIF_3
		ld timerLvl,a
lvlUp_skip_15

	CALL	initTimer

	call incObs
	
	POP	A
	ret


;----------------------------------------------------;
;-                   inc obstacle                   -;
;----------------------------------------------------;
incObs:
	
	;:: if(obsNb < OBS_MAX) then
	ld a,obsNb
	cp a,#OBS_MAX
	jruge incObsEndIf1
		inc obsNb
		ld y,LTCNTR
		cpl y
incObsWhile1
		;:: while( obsTab[y] != $ff ) do
		ld a,(obsTab,y)
		cp a,#$ff
		jreq incObsEndWhile1
			inc y
			;:: if(y >= 27) then
				cp y,#27
				jrult incObsEndIf3
					clr y
			;:: end if
incObsEndIf3
			jp incObsWhile1
incObsEndWhile1
		ld a,#0
		add a,obsMoveStep
			;:: if(obsDir != 0) then
			ld x,obsDir
			cp x,#0
			jreq incObsEndIf2
				;or a,#%10000000
				add a,#128
incObsEndIf2
			;:: end if
		ld (obsTab,y),a
incObsEndIf1
	;:: end if

	ret

;----------------------------------------------------;
;-                 display obstacle                 -;
;----------------------------------------------------;
dspObs:
	clr y
	;LD	colorMSB,A
	;LD	colorLSB,A
	ld a,#2
	ld width,a
	ld a,#1
	ld height,a
	;LD	x0win,A
	;LD	y0win,A
	;CALL	fillRectTFT

dspObsWhile
	;:: while(y <= 27)
	cp y,#27
	jruge dspObsEndWhile

		;:: if(obsTab[y] != oxff) then
		ld a,(obsTab,y)
		cp a,#$ff
		jreq dspObsEndIf1

			ld a,y
			ld x,#5
			mul x,a
			add a,#2
			ld y0win,a 		;: y0win = (y*5)+2

			;:: if(obsTab[y] & %10000000 == 0)
			ld a,(obsTab,y)
			and a,#%10000000
			cp a,#0
			jrne dspObsElseIf2

				ld a,#$00
				ld colorMSB,a
				ld colorLSB,a
				ld a,(obsTab,y)
				and a,#%01111111
				sub a,obsMoveStep
				ld x0win,a
				call fillRectTFT

				ld a,#$ff
				ld colorMSB,a
				ld colorLSB,a
				ld a,(obsTab,y)
				and a,#%01111111
				ld x0win,a
				call fillRectTFT

			jp dspObsEndIf2
dspObsElseIf2
			;:: else

				ld a,(obsTab,y)
				and a,#%01111111
				add a,obsMoveStep

				;:: if( (obsTab[y] & %01111111) + obsMoveStep <= 120 )
				cp a,#120
				jrugt dspObsEndIf3
					ld a,(obsTab,y)
					and a,#%01111111
					add a,obsMoveStep
					ld x0win,a
					ld a,#$00
					ld colorMSB,a
					ld colorLSB,a
					call fillRectTFT
dspObsEndIf3
				;:: end if

				ld a,#$ff
				ld colorMSB,a
				ld colorLSB,a
				ld a,(obsTab,y)
				and a,#%01111111
				ld x0win,a
				call fillRectTFT

dspObsEndIf2
			;:: end if

dspObsEndIf1
		;:: end if

	inc y
	jp dspObsWhile
dspObsEndWhile
	;:: end while

	ret
	
	
;----------------------------------------------------;
;-                 move obstacle                 -;
;----------------------------------------------------;
moveObs:
	PUSH	A
	PUSH	X
	
	CLR	X
	;for i=0, i<27, i++
for_move_obs
	CP	X,#27
	JRUGE	end_for_move_obs
		
		;if obsTab[i] != FF //si ennemi actif
		LD	A,(obsTab,X)
		CP	A,#$FF
		JREQ	end_if_ennemi_actif
			;if obsTab[i] >> 7 == 0 //si ennemi va a droite
			AND	a,#%10000000
			CP	A,#0
			JRNE	ennemi_va_gauche
				;if obsTab[i] == 127-6-2-2 // si ennemi à etremité droite
				LD	A,(obsTab,X)
				CP	A,#117
				JRNE	else_va_gauche
					;effacer ennemie
					call erase_obs

					LD	A,#0
					LD	(obsTab,X),A;obsTab[i] = 0 ;positionner ennemi tout à gauche
					JP	end_if_ennemi_actif
				;else
else_va_gauche
					ADD	A,obsMoveStep;obsTab[i]+=step
					LD	(obsTab,X),A
					JP	end_if_ennemi_actif
				;end
			;else //si ennemi va à gauche
ennemi_va_gauche
				;if obsTab[i] == 0 //si ennemie à extremité gauche
				LD	A,(obsTab,X)
				CP	A,#%10000000
				JRNE	else_va_droite
					;effacer ennemies
					call erase_obs
					LD	A,#245;117+128
					LD	(obsTab,X),A;obsTab[i] = 127-6-2-2 // positionner ennemie tout à droite
					JP	end_if_ennemi_actif
				;else
else_va_droite
					SUB	A,obsMoveStep;if obsTab[i] -=step
					LD	(obsTab,X),A
					JP	end_if_ennemi_actif
				;end
			;end
		;end
end_if_ennemi_actif
	INC X
	JP	for_move_obs
	;end
end_for_move_obs
	POP	X
	POP	A
	RET

;-- extension of move obs fct --;
erase_obs:
	ld a,(obsTab,x)
	and a,#%01111111
	ld x0win,a
	ld a,x
	ld y,#5
	mul y,a
	add a,#2
	ld y0win,a 		;: y0win = (y*5)+2
	ld a,#1
	ld height,a
	ld a,#2
	ld width,a
	ld a,#$00
	ld colorMSB,a
	ld colorLSB,a
	call fillRectTFT
	ret
	
	
	
;----------------------------------------------------;
;-            test collision obstacle               -;
;----------------------------------------------------;
collisionObs:
	PUSH	X
	PUSH	Y
	PUSH	A
	
	CLR	X
	;for(i=0, i<27, i++)
for_collision
		CP	X,#27
		JRUGE	end_for_collision
		
		;if obsTab[i] != FF //si ennemi actif
		LD	A,(obsTab,X)
		CP	A,#$FF
		JREQ	end_if_collision_ennemi_actif
			
			;yObs = i*5 + 2
			LD	A,X
			LD	Y,#5
			MUL	Y,A
			ADD	A,#2
			LD	yObsHB,A
			
			;yShip = shipY + 4
			LD	A,shipY
			ADD	A,#4
			LD	yShipHB, A
			
			;if(yShip > yObs)
			CP A,yObsHB
				;continue
				JRUGT	end_if_collision_ennemi_actif
			;end
			
			;yShip += 11
			LD	A,yShipHB
			ADD	A,#11
			LD	yShipHB,A
			
			;if(yShip < yObs)
			CP A,yObsHB
				;continue
				JRULT	end_if_collision_ennemi_actif
			;end
			
			;x1Ship = shipX + 3 -1 //-1 car obstacle de largeur de 2 px
			LD	A,#shipX
			ADD	A,#2
			LD	x1ShipHB,A
			
			;xObs = obsTab[i] & 01111111 //ellimination msb
			LD	A,(obsTab,X)
			AND	A,#%01111111
			LD	xObsHB,A
			
			;if(xObs < x1Ship)
			CP	A,x1ShipHB
				JRULT	end_if_collision_ennemi_actif
			;end
			
			;x2Ship = shipX + 7
			PUSH	A
			LD	A,#shipX
			ADD	A,#7
			LD	x2ShipHB,A
			POP	A
			
			;if(xObs > x2Ship)
			CP A,x2ShipHB
				;continue
				JRUGT	end_if_collision_ennemi_actif
			;end
			
			ld a,norrisMode
			cp a,#1
			jrne collisionObs_no_chuck
				ld a,#$ff
				ld (obsTab,x),a

				jp end_if_collision_ennemi_actif
collisionObs_no_chuck

				LD	A,#$00
				LD	colorMSB,A
				LD	A,#$00
				LD	colorLSB,A
				LD	A,#shipX
				LD	x0win,A
				LD	A,shipY
				SUB	A,shipMoveStep
				LD	y0win,A
				LD	A,#11
				LD	width,A
				LD	A,#18
				ADD	A,shipMoveStep
				ADD	A,shipMoveStep
				LD	height,A
				;CALL	fillRectTFT
				
				CALL	dsp_broken_ship
				
				LD	A,#140
				LD	shipY,A
				
				JP	end_for_collision
		;end
end_if_collision_ennemi_actif
	INC	X
	JP	for_collision
	;end
end_for_collision
	POP	A
	POP	Y
	POP	X
	RET


;-----------------------------------------;
;-       check if 2p mode is on          -;
;-----------------------------------------;
checkNorrisMode:
	PUSH	A
	
	LD	A,PADR
	AND	A,#%00000001
	LD	norrisMode,A
	
	POP	A
	RET


;-----------------------------------------;
;-       send info to second player      -;
;-----------------------------------------;
send2p:
	PUSH	A
	
	LD	A,PADR
	AND	A,#%11101111
	LD	PADR,A
	
	CALL	wait500ms
	
	LD	A,PADR
	OR	A,#%00010000
	LD	PADR,A
	
	POP	A
	RET
	

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
	
	;CALL	dspBsodScreen
wait_game_start
	ld a,shipState
	cp a,#0
	jreq wait_game_start

	call init_game
boucl

	call checkNorrisMode
	call checkEaster
	call dsp_ship
	call moove_ship
	call dspObs
	CALL	moveObs
	CALL	collisionObs
	CALL	updateTimer
	
	LD	A,p2Lose
	CP	A,#1
	JRNE skip_p2_lose
	CALL	gameOver
	JP	wait_game_start
	
skip_p2_lose
	LD	A,timer
	CP	A,#160
	JRNE	skip_game_over
	CALL	send2p
	CALL	gameOver
	JP	wait_game_start
	
skip_game_over
	
	JP	boucl



;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES D'INTERRUPTION
;
;************************************************************************


dummy_rt:	IRET	; Procédure vide : retour au programme principal.

i_ship_forward:
	BTJF	PBDR,#0,pb0_push
	clr shipState
	iret
pb0_push
	ld a,#1
	ld shipState,a
	call checkEasterBP
	iret

i_ship_backward:
	BTJF	PADR,#3,pa3_push
	clr shipState
	iret
pa3_push
	ld a,#2
	ld shipState,a
	call checkEasterBP
	iret

i_obs_dir:
	cpl obsDir
	ld a,LTCSR2
	iret

i_reception_data:
	LD	A,#1
	LD	p2Lose,A
	IRET

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
lt_RTC2_it	DC.W	i_obs_dir	; Adresse FFF0-FFF1h
ext3_it		DC.W	i_ship_forward	; Adresse FFF2-FFF3h
ext2_it		DC.W	dummy_rt	; Adresse FFF4-FFF5h
ext1_it		DC.W	i_reception_data	; Adresse FFF6-FFF7h
ext0_it		DC.W	i_ship_backward	; Adresse FFF8-FFF9h
AWU_it		DC.W	dummy_rt	; Adresse FFFA-FFFBh
softit		DC.W	dummy_rt	; Adresse FFFC-FFFDh
reset		DC.W	main		; Adresse FFFE-FFFFh


	END

;************************************************************************
