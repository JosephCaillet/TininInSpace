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
	PUBLIC	initTFT
	
	PUBLIC	fillRectTFT
	PUBLIC	fillScreenTFT
	PUBLIC	drawPixel
	PUBLIC	setSprite
	PUBLIC	dspSprite
;drawpixel & fillrect
	PUBLIC	x0win
	PUBLIC	y0win
	PUBLIC	x1win
	PUBLIC	y1win

;drawrect
	PUBLIC	colorMSB
	PUBLIC	colorLSB
	PUBLIC	width
	PUBLIC	height

;setSprite
	PUBLIC	numSprite

;displaySrite
	PUBLIC	dspCoef
	PUBLIC	dsp0X
	PUBLIC	dsp0Y
	PUBLIC	temp
	
DELAY EQU $80


INITR_GREENTAB EQU $0
INITR_REDTAB   EQU $1
INITR_BLACKTAB   EQU $2

INITR_18GREENTAB    EQU INITR_GREENTAB
INITR_18REDTAB      EQU INITR_REDTAB
INITR_18BLACKTAB    EQU INITR_BLACKTAB
INITR_144GREENTAB   EQU $1

ST7735_TFTWIDTH  EQU 128		;// Width TFT display 
ST7735_TFTHEIGHT_18  EQU 160	;// Heigt TFT 1.8" display

ST7735_NOP     EQU  $00
ST7735_SWRESET EQU  $01
ST7735_RDDID   EQU  $04
ST7735_RDDST   EQU  $09

ST7735_SLPIN   EQU  $10
ST7735_SLPOUT  EQU  $11
ST7735_PTLON   EQU  $12
ST7735_NORON   EQU  $13

ST7735_INVOFF  EQU  $20
ST7735_INVON   EQU  $21
ST7735_DISPOFF EQU  $28
ST7735_DISPON  EQU  $29
ST7735_CASET   EQU  $2A
ST7735_RASET   EQU  $2B
ST7735_RAMWR   EQU  $2C
ST7735_RAMRD   EQU  $2E

ST7735_PTLAR   EQU  $30
ST7735_COLMOD  EQU  $3A
ST7735_MADCTL  EQU  $36

ST7735_FRMCTR1 EQU  $B1
ST7735_FRMCTR2 EQU  $B2
ST7735_FRMCTR3 EQU  $B3
ST7735_INVCTR  EQU  $B4
ST7735_DISSET5 EQU  $B6

ST7735_PWCTR1  EQU  $C0
ST7735_PWCTR2  EQU  $C1
ST7735_PWCTR3  EQU  $C2
ST7735_PWCTR4  EQU  $C3
ST7735_PWCTR5  EQU  $C4
ST7735_VMCTR1  EQU  $C5

ST7735_RDID1   EQU  $DA
ST7735_RDID2   EQU  $DB
ST7735_RDID3   EQU  $DC
ST7735_RDID4   EQU  $DD

ST7735_PWCTR6  EQU  $FC

ST7735_GMCTRP1 EQU  $E0
ST7735_GMCTRN1 EQU  $E1

	;EXTERN wait500ms
	;EXTERN wait

	EXTERN waitTime.B
	EXTERN tabSprite.W
	
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

;setAdrWindow & drawpixel
x0win	DS.B	1;p
y0win	DS.B	1;p
x1win	DS.B	1;p
y1win	DS.B	1;p

;drawrect
colorMSB	DS.B	1;p
colorLSB	DS.B	1;p
width	DS.B 1;p
height	DS.B 1;p

;setSprite
numSprite	DS.B	1
sprite	DS.W	1

;displaySrite
dspCoef DS.B 1
dsp0X DS.B 1
dsp0Y DS.B 1

;dspNum
scoreD	DS.B	1
scoreU	DS.B	1
numX DS.B 1
numY DS.B 1

;************************************************************************
;
;  ZONE DE DECLARATION DES CONSTANTES
;
;************************************************************************
	WORDS
	segment byte 'rom'
	

	
Rcmd1	DC.B   15,
	DC.B   ST7735_SWRESET,   DELAY,
	DC.B     150,
	DC.B   ST7735_SLPOUT ,   DELAY,
	DC.B     255,
	DC.B   ST7735_FRMCTR1, 3  ,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_FRMCTR2, 3  ,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_FRMCTR3, 6  ,
	DC.B     $01, $2C, $2D,
	DC.B     $01, $2C, $2D,
	DC.B   ST7735_INVCTR , 1  ,
	DC.B     $07,
	DC.B   ST7735_PWCTR1 , 3  ,
	DC.B     $A2,
	DC.B     $02,
	DC.B     $84,
	DC.B   ST7735_PWCTR2 , 1  ,
	DC.B     $C5,
	DC.B   ST7735_PWCTR3 , 2  ,
	DC.B     $0A,
	DC.B     $00,
	DC.B   ST7735_PWCTR4 , 2  ,
	DC.B     $8A,
	DC.B     $2A,
	DC.B   ST7735_PWCTR5 , 2  ,
	DC.B     $8A, $EE,
	DC.B   ST7735_VMCTR1 , 1  ,
	DC.B     $0E,
	DC.B   ST7735_INVOFF , 0  ,
	DC.B   ST7735_MADCTL , 1  ,
	DC.B     $C8,
	DC.B   ST7735_COLMOD , 1  ,
	DC.B     $05
	
	
Rcmd2red DC.B 2,
	DC.B    ST7735_CASET  , 4
	DC.B      $00, $00,
	DC.B      $00, $7F,
	DC.B    ST7735_RASET  , 4
	DC.B      $00, $00,
	DC.B      $00, $9F


Rcmd3 DC.B 4,       
	DC.B    ST7735_GMCTRP1, 16      ,
	DC.B      $02, $1c, $07, $12,
	DC.B      $37, $32, $29, $2d,
	DC.B      $29, $25, $2B, $39,
	DC.B      $00, $01, $03, $10,
	DC.B    ST7735_GMCTRN1, 16      ,
	DC.B      $03, $1d, $07, $06,
	DC.B      $2E, $2C, $29, $2D,
	DC.B      $2E, $2E, $37, $3F,
	DC.B      $00, $00, $02, $10,
	DC.B    ST7735_NORON  ,    DELAY,
	DC.B      10,                    
	DC.B    ST7735_DISPON ,    DELAY,
	DC.B      100
;************************************************************************
;
;  ZONE DE DECLARATION DES SOUS-PROGRAMMES
;
;************************************************************************


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'et' bit à bit et complement a un ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MandComp MACRO dest mask
	;PUSH	X
	;PUSH	A
	LD	X,mask
	CPL	X
	LD	var,X
	LD	A,dest
	AND	A,var
	LD	dest,A
	;POP A
	;POP X
	MEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'or' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mor MACRO dest src
	;PUSH X
	;PUSH A
	LD	A,dest
	OR	A,src
	LD	dest,A
	;POP A
	;POP X
	MEND


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; macro pour 'and' bit à bit ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Mand MACRO dest src
	;PUSH X
	;PUSH A
	LD	A,dest
	AND	A,src
	LD	dest,A
	;POP A
	;POP X
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
	AND A,#128
	CP	A,#0
	JREQ boucle_wait_spi
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
	Mand PBDR, #$FB
	Mand PBDR, #$DF
	CALL writeSPI
	Mor PBDR, #$20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; envoi de data sur port spi ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;p: dataout
writeData:
	PUSH	A 
	Mor PBDR, #$04
	Mand PBDR, #$DF
	CALL writeSPI
	Mor PBDR, #$20
	POP A
	RET



;;;;;;;;;;;;;;;;;;;;;;;;
; execute liste de cmd ;
;;;;;;;;;;;;;;;;;;;;;;;;

;partie faisant la lecture depuis la bonne source indiquee par Y
read_src:
	CP	Y,#1
	JREQ	read_from_rcmd1
	CP	Y,#2
	JREQ	read_from_rcmd2
	CP	Y,#3
	JREQ	read_from_rcmd3
read_from_rcmd1:
	LD	A,(Rcmd1,X)
	INC	X
	RET
read_from_rcmd2:
	LD	A,(Rcmd2red,X)
	INC	X
	RET
read_from_rcmd3:
	LD	A,(Rcmd3,X)
	INC	X
	RET

;plusieur point d'entree pour le meme sous programme, afin de choisir la bonne source
cmdList1:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#1
	CLR	X
	LD	A,(Rcmd1,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

cmdList2:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#2
	CLR	X
	LD	A,(Rcmd2red,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

cmdList3:
	PUSH	Y
	PUSH	X
	PUSH	A
	
	LD Y,#3
	CLR	X
	LD	A,(Rcmd3,X)
	LD	numCmd,A
	INC	X
	JP while_num_cmd

while_num_cmd:
	;for each cmd
	LD	A,numCmd
	CP	A,#0
	JREQ end_while_num_cmd
	DEC	numCmd
	
	CALL read_src	;write cmd
	LD	dataout,A
	CALL writeCmd
	
	CALL read_src	;numARg=
	LD	numArg,A
	
	;LD A,numArg	;ms =
	AND	A,#DELAY
	LD	ms,A
	
	;MandComp numArg, #DELAY	;numArg&=
	Mand numArg, #$7F	;numArg&= DELAY EQU $80
	
while_num_arg:
	LD	A,numArg
	CP	A,#0
	JREQ	end_while_num_arg
	DEC	numArg
	
	CALL read_src	;write cmd
	LD	dataout,A
	CALL writeData
	JP while_num_arg
end_while_num_arg:
	
	LD	A,ms
	CP	A,#0
	JREQ while_num_cmd
	
	CALL read_src
	LD	ms,A
	
	;LD A,ms
	CP	A,#255
	JRNE skip_ms_eq_255
	CALL wait500ms
	JP while_num_cmd
	
skip_ms_eq_255:
	LD	A,ms
	LD	waitTime,A
	CALL	wait
	JP while_num_cmd
	
end_while_num_cmd:
	POP	A
	POP	X
	POP	Y
	RET

;;;;;;;;;;;;;;;;;;;;;;;;
; initialisation ecran ;
;;;;;;;;;;;;;;;;;;;;;;;;
initTFT:
	PUSH A
	
	Mor	PBDR, #$10
	;MandComp	PBDR, $20
	Mand	PBDR, #$DF
	CALL wait500ms
	
	;MandComp	PBDR, $10
	Mand	PBDR, #$EF
	CALL wait500ms
	
	Mor PBDR, #$10
	CALL wait500ms
	
	Mor	PBDR, #$20
	
	CALL cmdList1
	
	CALL cmdList2
	
	CALL cmdList3
	
	LD	A,#ST7735_MADCTL
	LD	dataout,A
	CALL	writeCmd
	
	LD	A,#$C0
	LD	dataout,A
	CALL	writeData
	
	;test
	LD	A,#$5A
	LD	colorMSB,A
	LD	A,#$A5
	LD	colorLSB,A
	;CALL	fillScreenTFT
	
	LD	A,#$AC
	LD	colorMSB,A
	LD	A,#$DB
	LD	colorLSB,A
	LD	A,#80
	LD	x0win,A
	LD	A,#70
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$AC
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#30
	LD	x0win,A
	LD	A,#30
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$CC
	LD	colorMSB,A
	LD	A,#$CC
	LD	colorLSB,A
	LD	A,#3
	LD	x0win,A
	LD	A,#3
	LD	y0win,A
	LD	A,#80
	LD	width,A
	LD	A,#10
	LD	height,A
	;CALL	fillRectTFT
	
	LD	A,#$FF
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#30
	LD	x0win,A
	LD	A,#30
	LD	y0win,A
	LD	A,#80
	LD	width,A
	LD	A,#30
	LD	height,A
	;CALL	fillRectTFT
	
	LD	A,#$AA
	LD	colorMSB,A
	LD	A,#$BB
	LD	colorLSB,A
	LD	A,#1
	LD	x0win,A
	LD	A,#1
	LD	y0win,A
	LD	A,#8
	LD	width,A
	LD	A,#150
	LD	height,A
	;CALL	fillRectTFT
	
	LD	A,#$AC
	LD	colorMSB,A
	LD	A,#$DB
	LD	colorLSB,A
	LD	A,#80
	LD	x0win,A
	LD	A,#70
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$FF
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#35
	LD	x0win,A
	LD	A,#35
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$FF
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#90
	LD	x0win,A
	LD	A,#140
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$FF
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#40
	LD	x0win,A
	LD	A,#110
	LD	y0win,A
	;CALL	drawPixel
	
	LD	A,#$FF
	LD	colorMSB,A
	LD	A,#$FF
	LD	colorLSB,A
	LD	A,#60
	LD	x0win,A
	LD	A,#80
	LD	y0win,A
	;CALL	drawPixel
	
	;end test
	
	;begin test img
	; p: sprite
	; p: dspCoef
	; p: dspOX
	; p: dspOY
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
	
	
	LD	A,#$AC
	LD	colorMSB,A
	LD	A,#$42
	LD	colorLSB,A
	CALL	fillScreenTFT
	
	
	LD	A,#28
	LD	numSprite,A
	CALL	setSprite
	LD	A,#1
	LD	dspCoef,A
	LD	A,#96
	LD	dsp0X,A
	LD	A,#134
	LD	dsp0Y,A
	CALL	dspSprite
	
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
	
	LD	A,#0
	LD	numSprite,A
	CALL	setSprite
	LD	A,#103
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#2
	LD	numSprite,A
	CALL	setSprite
	LD	A,#1
	LD	dspCoef,A
	LD	A,#22
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#4
	LD	numSprite,A
	CALL	setSprite
	LD	A,#31
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#6
	LD	numSprite,A
	CALL	setSprite
	LD	A,#40
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#8
	LD	numSprite,A
	CALL	setSprite
	LD	A,#49
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#10
	LD	numSprite,A
	CALL	setSprite
	LD	A,#58
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#12
	LD	numSprite,A
	CALL	setSprite
	LD	A,#67
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#14
	LD	numSprite,A
	CALL	setSprite
	LD	A,#76
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#16
	LD	numSprite,A
	CALL	setSprite
	LD	A,#85
	LD	dsp0X,A
	LD	A,#109
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#18
	LD	numSprite,A
	CALL	setSprite
	LD	A,#5
	LD	dsp0X,A
	LD	A,#5
	LD	dsp0Y,A
	CALL	dspSprite
	
	LD	A,#0
	LD	numSprite,A
	CALL	setSprite
	LD	A,#10
	LD	dsp0X,A
	LD	A,#10
	LD	dsp0Y,A
	CALL	dspSprite
	;end test img
	
	POP A
	RET
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; select a window to write pixel ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;x1win	DS.B	1;p
;y1win	DS.B	1;p
setAddrWindow:
	PUSH	A
	LD A,#ST7735_CASET
	LD dataout,A
	CALL writeCmd
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,x0win
	LD dataout,A
	CALL writeData
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,x1win
	LD dataout,A
	CALL writeData
	
	
	LD A,#ST7735_RASET
	LD dataout,A
	CALL writeCmd
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,y0win
	LD dataout,A
	CALL writeData
	
	LD A,#$00
	LD dataout,A
	CALL writeData
	
	LD A,y1win
	LD dataout,A
	CALL writeData
	
	
	LD A,#ST7735_RAMWR
	LD dataout,A
	CALL writeCmd
	
	POP	A
	RET
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill a rectangle with a color ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;x1win	DS.B	1;u
;y1win	DS.B	1;u
;colorMSB;p
;colorLSB;p
;width;p
;height;p
fillRectTFT:
	PUSH	A
	PUSH	X
	PUSH	Y
	
	LD	A,x0win
	ADD	A,width
	DEC A
	LD	x1win,A
	
	LD	A,y0win
	ADD	A,height
	DEC A
	LD	y1win,A
	
	CALL setAddrWindow
	
	Mor	PBDR, #$04
	Mand	PBDR, #$DF

	LD	Y,height
	
fill_rect_for_y:
	CP	Y,#0
	JRULE	end_fill_rect_for_y

	LD	X,width
	
fill_rect_for_x:
	CP	X,#0
	JRULE	end_fill_rect_for_x
	
	LD A,colorMSB
	LD dataout,A
	CALL writeSPI
	LD A,colorLSB
	LD dataout,A
	CALL writeSPI
	
	DEC X
	JP	fill_rect_for_x
	
end_fill_rect_for_x:
	DEC	Y
	JP	fill_rect_for_y
	
end_fill_rect_for_y:
	Mor PBDR, #$20
	
	POP	Y
	POP	X
	POP	A
	RET
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fill entire screen with a color ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;u
;y0win	DS.B	1;u
;width	DS.B	1;u
;height	DS.B	1;u
;colorMSB;p
;colorLSB;p
fillScreenTFT:
	PUSH	A
	
	LD	A,#0
	LD	x0win,A
	LD	A,#0
	LD	y0win,A
	LD	A,#ST7735_TFTWIDTH
	LD	width,A
	LD	A,#ST7735_TFTHEIGHT_18
	LD	height,A
	CALL	fillRectTFT
	
	POP	A
	RET


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw colored pixel on screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;x0win	DS.B	1;p
;y0win	DS.B	1;p
;colorMSB;p
;colorLSB;p
drawPixel:
	PUSH	A
	
	LD	A,x0win
	INC A
	LD	x1win,A
	
	LD	A,y0win
	INC A
	LD	y1win,A
	
	CALL setAddrWindow

	Mor	PBDR, #$04
	Mand	PBDR, #$DF
	
	LD A,colorMSB
	LD dataout,A
	CALL writeSPI
	LD A,colorLSB
	LD dataout,A
	CALL writeSPI
	
	Mor PBDR, #$20
	
	POP	A
	RET




;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;---                  Fonctions personnelles                         ---;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; choose sprite to be displayed ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;numSprite;p
;sprite;u
setSprite:
	PUSH	A
	PUSH	X
	PUSH	Y
	
	LD	X,numSprite
	LD	A,(tabSprite,X)
	
	LD	Y,#0
	LD	(sprite,Y),A
	
	INC	X
	LD	A,(tabSprite,X)
	
	INC	Y
	LD	(sprite,Y),A
	
	POP	Y
	POP	X
	POP	A
	RET

;----------------------------------------------------;
;-            decompress a picture                  -;
;----------------------------------------------------;
; p: sprite
; p: dspCoef
; p: dspOX
; p: dspOY

;add var sprite, dspX, dspY, dspOX, dspOY, dspCoef

dspSprite:
	push a
	push x
	push y

	ld a,dsp0X
	ld x0win,a
	ld a,dsp0Y
	ld y0win,a
	ld y,#2

boucl_dsp_title
	;:: while(y0win - dspOY < sprite[1] * dspCoef) do
	ld  x,#1
	ld x,([sprite.w],x)
	ld a,dspCoef
	mul x,a
	ld x,a
	ld a,y0win
	sub a,dsp0Y
	ld temp,x
	cp a,temp
	jruge end_boucl_dsp_title

	;--- gestion de la couleur du rectangle
		;:: switch(sprite[y] & %11000000)
		ld a,([sprite.w],y)
		and a,#%11000000
			;:: case 0:
				cp a,#0
				jrne dsp_sprite_col2
				ld a,#$0
				ld colorMSB,a 		;: colorMSB = 0x00
				ld colorLSB,a 		;: colorLSB = 0x00
				jp end_dsp_sprite_col	;: break
dsp_sprite_col2
			;:: case: 64
				cp a,#64
				jrne dsp_sprite_col3
				ld a,#$84
				ld colorMSB,a 		;: colorMSB = 0x84
				ld a,#$10
				ld colorLSB,a 		;: colorLSB = 0x10
				jp end_dsp_sprite_col 	;: break
dsp_sprite_col3
			;:: case: 128
				cp a,#128
				jrne dsp_sprite_col4
				ld a,#$ff
				ld colorMSB,a 		;: colorMSB = 0xff
				ld colorLSB,a 		;: colorLSB = 0xff
				jp end_dsp_sprite_col 	;: break
dsp_sprite_col4
			;:: default:
				ld a,#$f8
				ld colorMSB,a 		;: colorMSB = 0xf8
				ld a,#$00
				ld colorLSB,a 		;: colorLSB = 0x00
		;:: end switch
end_dsp_sprite_col

		
		;--- gestion de la largeur et de la hauteur du rectangle
		ld a,dspCoef
		ld height,a 				;: height = dspCoef
		ld a,([sprite.w],y)
		and a,#%00111111
		inc a
		ld x,a
		ld a,dspCoef
		mul x,a
		ld width,a 					;: width = ((sprite[y] & %00111111) + 1) * dspCoef


		;--- dessin du rectangle
		call fillRectTFT

		ld a,x0win
		add a,width
		ld x0win,a 					;: x0win += width

		inc y 						;: y++

		;:: if(x0win - dspOX >= sprite[0] * dspCoef) then
		ld x,[sprite.w]
		ld a,dspCoef
		mul x,a
		ld x,a
		ld a,x0win
		sub a,dsp0X
		ld temp,x
		cp a,temp
		jrult boucl_dsp_title
		;jrult dsp_end_test_line

			ld a,dsp0X
			ld x0win,a 			;: x0win = dspOX
			ld a,y0win
			add a,dspCoef
			ld y0win,a 			;: y0win += dspCoef
			;jp boucl_dsp_title	;: goto boucl_dsp_title

		;:: end if
;dsp_end_test_line


		;--- retour à la condition de la boucle
		jp boucl_dsp_title
	;:: end while
end_boucl_dsp_title

	pop y
	pop x
	pop a
	ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; display a number ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;numSprite;u
;scoreD;p
;scoreU;p
;dspCoef DS.B;p
;numX;p
;numY;p
;dsp0X;u
;dsp0Y;u

;;;;;
	LD	A,#20
	LD	numSprite,A
	CALL	setSprite
	LD	A,#2
	LD	dspCoef,A
	LD	A,#0
	LD	dsp0X,A
	LD	dsp0Y,A
	CALL	dspSprite
;;;;;

dspNum:
	PUSH	A
	PUSH	X
	
	;4 146 ; 13 146
	
	;dizaine
	LD	A,scoreD
	LD	X,#2
	MUL	X,A
	LD	A,numSprite
	CALL setSprite
	
	LD	A,numX
	LD	dsp0X,A
	LD	A,numY
	LD	dsp0Y,A
	CALL	dspSprite
	
	;unitee
	LD	A,scoreU
	LD	X,#2
	MUL	X,A
	LD	A,numSprite
	CALL setSprite
	
	LD	A,dspCoef
	LD	X,#4
	MUL	X,A
	PUSH	A
	
	LD	A,dspCoef
	LD	X,#5
	MUL	X,A
	PUSH	A
	
	LD	A,numX
	POP	X
	ADD	A,(X)
	POP	X
	ADD	A,(X)
	
	LD	dsp0X,A
	LD	X,numY
	LD	dsp0Y,X
	CALL	dspSprite
	
	
	POP	X
	POP	A
	RET
	
;************************************************************************

	END

;************************************************************************