;-----------------------------------------------------------
;                    _1541_fastload_code
;
; The following section will be copied out to the 1541
; drive, and contains the fastload code that will be
; executed on the 1541.
;-----------------------------------------------------------

        .setcpu "6502"


read_256_bytes:= $0146 + $000C
read_target_vector:= $0146 + $000C + $002E

KERNEL_TURN_ON_LED:= $C118
KERNEL_GIVE_ERROR := $C1C8
KERNEL_READ_BAM := $D042
LD945           := $D945                ; middle of KERNEL code to overwrite a file
KERNEL_CALC_DATA_PARITY:= $F5E9

LF8E0           := $F8E0
LF934           := $F934



__start_1541_fastload_code:

.code

        inc     read_target_vector + 1  ; Load the next 256 bytes of code from the C64
        jsr     read_256_bytes

        cli                             ; Enable interrupts

        jsr     KERNEL_TURN_ON_LED
        jsr     KERNEL_READ_BAM

        sei                             ; Disable interrupts

        lda     #$15                    ; Set timer latch?
        sta     $1C07

        lda     #$03
        sta     $3C
        lda     #$12
        ldx     #$01
L051B:  jsr     L05E7

        ldx     #$07
L0520:  lda     L0561,x
        sta     $3B
        ldy     #$00
        lda     ($3B),y
        cmp     #$82
        bne     L0545
        ldy     #$03
L052F:  lda     L06B9,y
        cmp     #$2A
        beq     L0569
        cmp     #$3F
        beq     L053E
        cmp     ($3B),y
        bne     L0545
L053E:  iny
        cpy     #$12
        bne     L052F
        beq     L0569
L0545:  dex
        bpl     L0520
        ldx     $0301
        lda     $0300
        bne     L051B
        lda     #$FF
        sta     $0300
        jsr     L058D
        lda     #$3A
        sta     $1C07
        cli
        jmp     LD945
L0561:  .byte   $E2
        .byte   $C2
        ldx     #$82
        .byte   $62
        .byte   $42
        .byte   $22
        .byte   $02
L0569:  ldy     #$02
        lda     ($3B),y
        tax
        dey
        lda     ($3B),y
L0571:  jsr     L05E7
        jsr     L058D
        ldx     $0301
        lda     $0300
        bne     L0571
        lda     #$F7
        and     $1C00
        sta     $1C00
        lda     #$3A
        sta     $1C07
        rts




L058D:  ldy     #$00
L058F:  lda     $0300,y
        lsr     a
        lsr     a
        lsr     a
        lsr     a
        tax
        lda     L05D7,x
        tax
        lda     #$01
L059D:  bit     $1800
        beq     L059D
        lda     #$08
        sta     $1800
        lda     #$01
L05A9:  bit     $1800
        bne     L05A9
        stx     $1800
        txa
        asl     a
        and     #$0F
        sta     $1800
        lda     $0300,y
        and     #$0F
        tax
        lda     L05D7,x
        sta     $1800
        asl     a
        and     #$0F
        nop
        sta     $1800
        nop
        nop
        nop
        lda     #$00
        sta     $1800
        iny
        bne     L058F
        rts
L05D7:  brk
        .byte   $04
        ora     ($05,x)
        php
        .byte   $0C
        ora     #$0D
        .byte   $02
        asl     $03
        .byte   $07
        asl     a
        asl     $0F0B




;-----------------------------------------------------------
;
; a => track?
; x => sector?
;-----------------------------------------------------------

L05E7:  stx     $07                     ; Store track/sector in buffer 0 track/status register
        sta     $0300
        cmp     $06
        php
        sta     $06
        plp
        beq     @L0604                   ; Branch if the track has not changed since last time

        lda     #$B0                    ; Set buffer 0 command/status to read in sector header
        sta     $00

        cli                             ; Enable interrupts to allow command to execute

@loop_wait_read_sector_header:
        bit     $00
        bmi     @loop_wait_read_sector_header

        sei                             ; Disable interrupts

        lda     $00                     ; Make sure we read the data okay
        cmp     #$01
        bne     @handle_error

@L0604:  lda     #$EE                    ; Attach byte ready line to CPU overflow flag
        sta     $1C0C

        lda     #$06                    ; Set buffer 0 to track 6, sector 0
        sta     $32
        lda     #$00
        sta     $33

        sta     $30                     ; Set read buffer to $0300 (empty memory)
        lda     #$03
        sta     $31

        jsr     L0669

@loop_read_bytes:
        bvc     @loop_read_bytes        ; Wait for overflow flag to indicate data is ready
        clv

        lda     $1C01                   ; Read byte into buffer
        sta     $0300,y
        iny
        bne     @loop_read_bytes

        ldy     #$BA

@loop_read_bytes2:
        bvc     @loop_read_bytes2       ; Read bytes into GCR-decoding buffer at $01BA-$01FF
        clv

        lda     $1C01
        sta     $0100,y
        iny
        bne     @loop_read_bytes2

        jsr     LF8E0
        lda     $38
        cmp     $47
        beq     @L0641
        lda     #$22
        bne     @L0655
@L0641:  jsr     KERNEL_CALC_DATA_PARITY
        cmp     $3A
        beq     @L064C
        lda     #$23
        bne     @L0655
@L064C:  lda     #$EC
        sta     $1C0C
        rts

@handle_error:
        clc
        adc     #$18
@L0655:  sta     $44
        lda     #$FF
        sta     $0300
        jsr     L058D
        lda     #$3A
        sta     $1C07
        lda     $44
        jmp     KERNEL_GIVE_ERROR




;-----------------------------------------------------------
;-----------------------------------------------------------

.data

L0669:  .byte   $A5,$12,$85,$16,$A5,$13,$85,$17
        .byte   $A5,$06,$85,$18,$A5,$07,$85,$19
        .byte   $A9,$00,$45,$16,$45,$17,$45,$18
        .byte   $45,$19,$85,$1A,$20,$34,$F9,$A2
        .byte   $5A,$20,$A4,$06,$50,$FE,$B8,$AD
        .byte   $01,$1C,$D9,$24,$00,$F0,$07,$CA
        .byte   $D0,$EF,$A9,$20,$D0,$B6,$C8,$C0
        .byte   $08,$D0,$E9,$A9,$D0,$8D,$05,$18
        .byte   $A9,$21,$2C,$05,$18,$10,$A5,$2C
        .byte   $00,$1C,$30,$F6,$AD,$01,$1C,$B8
L06B9:  .byte   $A0,$00,$60