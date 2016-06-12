ST7/

;************************************************************************
; TITLE:            main.asm    
; AUTHOR:           Joseph CAILLET & Thomas COUSSOT    
; DESCRIPTION:      Contient les fonction du jeu    
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
	EXTERN	setPalet3
	EXTERN	setPalet4


;************************************************************************
;
;  FIN DE LA ZONE DE DECLARATION DES SYMBOLES
;
;************************************************************************

	
	BYTES
	
	segment byte 'ram0'

;************************************************************************
;
;  ZONE DE DECLARATION DES VARIABLES
;
;************************************************************************
shipX EQU 59	;position x de la fusée
;obstacles
OBS_MAX   EQU  27	;nb max d'obstacle

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

xObsHB	DS.B	1;HB = hitbox = zone de sensibilité du vaisseau
yObsHB	DS.B	1
x1ShipHB	DS.B	1
x2ShipHB	DS.B	1
yShipHB	DS.B	1

norrisMode	DS.B	1; is chuck norris mode on
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
	;On initialise les masques des différents ports/gestions des interruptions
	;qui nous serons utiles dans le programme.
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
	;On initialise le timer du st7 afin qu'il compte de 229 à 255 de manière continue.
	LD	A,LTCSR2
	or a,#%00000010
	LD	LTCSR2,A

	ld a,#$e5 ;compter de 229 à 255 (revient à peu près à compter de 0 à 26)
	ld LTCARR,a

	ret


;----------------------------------------------------;
;-                    init obsTab                   -;
;----------------------------------------------------;
initObsTab:
	;initialisation du tableau des obstacles

	clr y
	ld a,#$ff	;ff = pas d'obstacles

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
;initialisation des différentes variables servant dans le jeu.
;Cette fonction est appelée à chaque nouvelle partie.

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
;Affichage de l'écran d'accueil
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
;Ces deux fonctions sont présentes pour le BSOD
;Si le compteur easterCpt atteint 20, le BSOD est affiché
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
;Affiche l'écran de BSOD
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
;-              display chuck screen                -;
;----------------------------------------------------;
;affiche l'écran de fin spécial Chuck Norris
dspChuckScreen:
	PUSH A
	
	CALL	setPalet4
	
	LD	A,#54
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#0
	LD	dsp0X,A
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#56
	LD	numSprite,A
	CALL	setSprite
	LD	A,#40
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#58
	LD	numSprite,A
	CALL	setSprite
	LD	A,#80
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#60
	LD	numSprite,A
	CALL	setSprite
	LD	A,#120
	LD	dsp0Y,A
	CALL	dspSprite
	
	;affiche aléatoirement l'un des deux chuck norris facts
	CALL	setPalet1
	
	;:: if(obsDir = 0) then
	ld a,obsDir
	cp a,#0
	jrne dspChuckScreenElse1

		LD	A,#66
		LD	numSprite,A
		CALL	setSprite
		LD	A,#132
		LD	dsp0Y,A
		LD	A,#2
		LD	dsp0X,A
		CALL	dspSprite
		
		LD	A,#68
		LD	numSprite,A
		CALL	setSprite
		LD	A,#148
		LD	dsp0Y,A
		CALL	dspSprite

		jp dspChuckScreenEndIf1

dspChuckScreenElse1
	;:: else

		LD	A,#62
		LD	numSprite,A
		CALL	setSprite
		LD	A,#132
		LD	dsp0Y,A
		LD	A,#2
		LD	dsp0X,A
		CALL	dspSprite
		
		LD	A,#64
		LD	numSprite,A
		CALL	setSprite
		LD	A,#148
		LD	dsp0Y,A
		CALL	dspSprite

dspChuckScreenEndIf1
	;:: end if
	
	POP	A
	RET



;----------------------------------------------------;
;-                   display ship                   -;
;----------------------------------------------------;
;Affiche le vaisseau dans le jeu et efface le reste de l'ancien sprite
dsp_ship:
	
	ld a,shipY
	ld dsp0Y,a
	ld a,#shipX
	ld dsp0X,a
	ld a,#1
	ld dspCoef,a
	
	;si l'on est en mode Chuck Norris, on charge un sprite différent et on applique une palette de couleur différente également
	LD a,norrisMode
	CP a,#0
	JREQ	set_ship_sprite
		CALL	setPalet3
		LD	A,#52
		JP	end_set_sprite
	
set_ship_sprite	
	ld a,#28

end_set_sprite
	ld numSprite,a
	call setSprite
	call dspSprite
	CALL	setPalet1

	;on regarde l'ancienne position du vaissau par rapport à l'actuelle. Cela permet de nettoyer l'écran au dessus ou en dessous de la fusée
	;selon les anciennes coordonnées.
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
	;add a,#2
	ld height,a
	ld a,#11
	ld width,a
	call fillRectTFT

	ret


;----------------------------------------------------;
;-                display broken ship               -;
;----------------------------------------------------;
;On affiche le sprite de la fusée cassée à l'emplacement actuel de la fusée
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
;On change les coordonnées du vaisseau en fonction de la variable d'état du vaisseau (0:arrêt/1:avance/2:recule)
;Si le vaisseau atteint le haut de l'écran, on efface le vaisseau et on le téléporte en bas de l'écran.
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
;On utilise le compteur modulo 100 réalisé en tp pour incrémenter le score (l'unité et la dizaine du score sont dans deux variables séparées)
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
	call dspBsodScreen 		;Si le compteur atteint 100, on affiche un BSOD
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
;-                 init timer                       -;
;----------------------------------------------------;
;Initialisation du timer du jeu
initTimer:
	PUSH	A
	
	;Le timer comptera de 0 à 160, et sera decrementer au bout de subTimer + 1 cycle.
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
;-                 update timer                     -;
;----------------------------------------------------;
;Le timer comptera de 0 à 160, et sera decrementer au bout de subTimer + 1 cycle.
;if subTimer == 255
;		decrementer barre timer
;		subTimer = 0
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
;-                 game over                        -;
;----------------------------------------------------;
;Affiche l'écran de fin du jeu
gameOver:
	PUSH	A
	
	;si mode chuck norris activé, ecran de fin special.
	LD	A,norrisMode
	CP	A,#0
	JREQ	normal_game_over
		CALL	dspChuckScreen
		JP	end_gameOver

normal_game_over	;sinon game over normal
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
	CALL	fillRectTFT;efface score en bas
	
	LD	A,#30
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#35
	LD	dsp0X,A
	LD	A,#18
	LD	dsp0Y,A
	CALL	dspSprite;affiche "game"
	
	LD	A,#32
	LD	numSprite,A
	CALL	setSprite
	LD	A,#36
	LD	dsp0X,A
	LD	A,#57
	LD	dsp0Y,A
	CALL	dspSprite;affiche "over"
	
	LD	a,#96
	LD	numY,a
	LD	a,#49
	LD	numX,a
	call	dspNum;affiche le score au millieu
	
	
	LD	A,#46
	LD	numSprite,A
	CALL	setSprite
	LD	A,#30
	LD	dsp0X,A
	LD	A,#130
	LD	dsp0Y,A
	LD	A,#1
	LD	dspCoef,A
	CALL	dspSprite;affiche "you"
	
	LD	A,p2Lose
	CP	A,#1	;si p2 perd
		JREQ	draw_p1Win	;p1 gagne
	
draw_p1Lose
	LD	A,#48
	LD	numSprite,A
	CALL	setSprite
	LD	A,#65
	LD	dsp0X,A
	CALL	dspSprite;affiche "lose"
	JP	end_gameOver
	
draw_p1Win
	LD	A,#50
	LD	numSprite,A
	CALL	setSprite
	LD	A,#73
	LD	dsp0X,A
	CALL	dspSprite;affiche "win"

end_gameOver
	POP	A
	RET
	
	
;----------------------------------------------------;
;-                    next level                    -;
;----------------------------------------------------;
;Dès que le joueur atteint le haut de l'écran, il passe au niveau suivant.
;A chaque niveau, on augmente le nombre d'obstalces (max 27) et on reset le timer du jeu
;Aux niveaux 5 et 15, le compteur décroit plus vite
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
	call	dspNum;affichage du score en bas
	
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

	CALL	initTimer; reset du timer

	call incObs
	
	POP	A
	ret


;----------------------------------------------------;
;-                   inc obstacle                   -;
;----------------------------------------------------;
;Incrémentation du nombre d'obstacle
;Les obstacles sont placés dans un tableau de 27 éléments (donc max 27 obstacles)
;Le sens des projectiles est défini par le premier bit de l'octet du projectile
;Une case du tableau qui ne contient pas de projectile est égale à 255
;L'ajout d'obstacles est réalisé grâce à deux variables : le compteur LTCNTR et obsDir
;obsDir est modifié à chaque fois que le compteur atteint la valeur max (grâce à un sous-programme d'interruption)
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
;On affiche les obstacles après avoir effacé celui-ci à sa position précédente.
;La position précédente est déterminée grâce au sens de l'obstacle et sa vitessse de déplacement (obsMoveStep)
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
;-                 move obstacle                    -;
;----------------------------------------------------;
;On déplace les obstalces en fonction de leur sens.
;S'ils arrivent à un côté de l'écran, on les efface et on les téléporte de l'autre côté.
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
	call fillRectTFT;efface un ennemi
	ret
	
	
	
;----------------------------------------------------;
;-            test collision obstacle               -;
;----------------------------------------------------;
;On teste si les obstacles sont dans la hitbox du vaisseau
;On teste la position des obstacles par rapport à celle du vaisseau.
;Si un projectile est sur la même ligne, on teste s'il se trouve dans la bonne tranche en coordonnée x
;En cas de collision, on affiche le sprite de fusée cassée et on téléporte celle-ci en bas
;En mode Chuck Norris et en cas de collision, on supprime le projectile au lieu de détruire le vaisseau
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
			
			;if(yShip > yObs) Si ennemi au dessus de la hitbox, pas de colision.
			CP A,yObsHB
				;continue
				JRUGT	end_if_collision_ennemi_actif
			;end
			
			;yShip += 11
			LD	A,yShipHB
			ADD	A,#11
			LD	yShipHB,A
			
			;if(yShip < yObs)	Si ennemi au dessous de la hitbox, pas de colision.
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
			
			;if(xObs < x1Ship)	Si ennemi a gauche de la hitbox, pas de colision.
			CP	A,x1ShipHB
				JRULT	end_if_collision_ennemi_actif
			;end
			
			;x2Ship = shipX + 7
			PUSH	A
			LD	A,#shipX
			ADD	A,#7
			LD	x2ShipHB,A
			POP	A
			
			;if(xObs > x2Ship) Si ennemi a doite de la hitbox, pas de colision.
			CP A,x2ShipHB
				;continue
				JRUGT	end_if_collision_ennemi_actif
			;end
			
			;si ennemi ni en haut, bas droite ou gauche de la hitbox,
			;il est dedans, donc colision.

			;en cas de mode Chuck Norris, on supprime le projectile. Il est automatiquement effacé par le sprite du vaisseau (ou de la tête de Chuck dans le cas présent)
			ld a,norrisMode
			cp a,#0
			jreq collisionObs_no_chuck
				ld a,#$ff
				ld (obsTab,x),a
				dec obsNb

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
;-  check if chuck norris mode is on     -;
;-----------------------------------------;
checkNorrisMode:
	PUSH	A
	
	LD	A,PADR;lecture du switch
	CPL	A
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
	LD	PADR,A	;bit de start / font descandant
	
	CALL	wait500ms
	
	LD	A,PADR
	OR	A,#%00010000
	LD	PADR,A	;bit de stop / font montant
	
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
	
wait_game_start
	ld a,shipState
	cp a,#0
	jreq wait_game_start

	call init_game ;A chaque nouvelle partie on initialise le jeu
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
	JRNE skip_p2_lose;si le second joueur perd, on gagne
	CALL	gameOver
	JP	wait_game_start
	
skip_p2_lose
	LD	A,timer
	CP	A,#160
	JRNE	skip_game_over;si time arrivé au bout, on perd et on avertit la seconde carte
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
