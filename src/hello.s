.include "c64.inc"

.segment "LOADADDR"

	.addr	$2000

.code

main:

	sei

	lda 	#$36			; RAM only
	sta		$01

	lda 	#$7f			; enable all interrupts on CIA
	sta		CIA1_ICR
	sta		CIA2_ICR
	lda		CIA1_ICR
	lda		CIA2_ICR

	lda		#$18
	sta		$1ffe
	lda		#$60
	sta		$1fff
	lda		#$fe
	sta		$0326
	lda		#$1f
	sta		$0327

	lda		$0319				; set NMI routine to $ce00
	cmp		#$ce				; first, check to see if it's already set...
	beq		@branch

	lda		#$00
	sta		$0318
	lda		#$ce
	sta		$0319
	lda		#$40
	sta		$ce00

@branch:

	lda		#$00				; Set border and background color to black
	sta		VIC_BORDERCOLOR
	sta		VIC_BG_COLOR0

	jsr		$8395				; ???

	ldx		#$00				; Initialize color RAM @ $d800-$dbff

@init_color_loop:

	lda		#$01
	sta		$d800,x
	sta		$d900,x
	sta		$da00,x
	sta		$db00,x
	inx
	bne		@init_color_loop

	lda		#$1e				; ???
	sta		$8361
	lda		#$81
	sta		$8362
	lda		#$18
	sta		$fe
	lda		#$05
	sta		$ff
	jsr		$835e

	lda		#$17				; Set screen memory at $4000 and character/bitmap memory at $2000
	sta		VIC_VIDEO_ADR

	lda		#$08				; Enable multi-color mode				
	sta		VIC_CTRL2

	lda		#$17				; Turn screen on - 25 rows
	sta		VIC_CTRL1

	lda		#$00
	tay
	sta		$fe
	sta		$fc
	lda		#$84
	sta		$ff
	lda		#$c0
	sta		$fd
	ldx		#$07

@loop:

	lda		($fe),y
	sta		($fc),y
	iny
	bne		@loop
	inc		$ff
	inc		$fd
	dex
	bpl		@loop

	ldx		#$10
	jsr		$c480
	lda		#$83
	sta		$0302
	lda		#$a4
	sta		$0303
	lda		#$48

	sta		$028f
	lda		#$eb
	sta		$0290
	lda		#$a5
	sta		$0330
	lda		#$f4

	sta		$0331
	jsr		$ff9f
	jsr		$ffe4
	cmp		#$20
	beq		@branch1
	lda		$b000

	bne		@branch2

@branch1:

	jsr		$8188

@branch2:

	lda		$b000
	cmp		#$02
	beq		@branch3
	sei
	lda		#$42
	sta		$0330

	lda		#$c0
	sta		$0331
	cli

@branch3:

	ldx		#$5c
	ldy		#$83
	lda		#$02
	jsr		$ffbd

	lda		#$0f
	tay
	ldx		#$08
	jsr		$ffba
	jsr		$ffc0
	lda		#$0c
	sta		$08
	ldx		#$00
	
	; $8100


