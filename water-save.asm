!CONST SKIP_INTRO, 0
!CONST ONE_LIFE, 0

!IF SKIP_INTRO
; Startup noise
!SEEK 0x0089A
    mov r0, r0
    mov r0, r0
; Warning and IPD
!SEEK 0x0095E
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
; Auto-pause
!SEEK 0x0096C
    mov r0, r0
    mov r0, r0
!ENDIF

!IF ONE_LIFE
!SEEK 0x18EC2
    mov 1, r10
!ENDIF

!ORG 0x07000892
!SEEK 0x00892
    jr CHECK_SRAM               ; movea 0x4268, r0, r7
CHECK_SRAM_RETURN:

; Don't show the auto-pause screen again every time you game over
!ORG 0x07000950
!SEEK 0x00950
    jr SKIP_AUTOPAUSE
!ORG 0x07000974
SKIP_AUTOPAUSE:

; Don't make that infuriating noise
!SEEK 0x00FF0
    mov r0, r11
!SEEK 0x03DAC
    mov r0, r11
!SEEK 0x016CC
    mov r0, r11
!SEEK 0x01F74
    mov r0, r11
!SEEK 0x0D9C2
    mov r0, r13

!CONST HI_OFF, 0x2080
!CONST HI_NUM, HI_OFF + 0x10    ; unlike other numbers, score expands *left*
!CONST RD_OFF, HI_NUM + 0x04
!CONST RD_NUM, RD_OFF + 0x0C
!CONST PL_OFF, RD_NUM + 0x06
!CONST PL_NUM, PL_OFF + 0x02
!CONST CSCORE, PL_NUM + 0x0E    ; unlike other numbers, score expands *left*

!CONST LV_OFF, 0x20BA
!CONST LV_NUM, LV_OFF + 0x0C
!CONST AT_NUM, LV_NUM + 0x06
!CONST AT_OFF, AT_NUM + 0x04

; Shift the HUD around to make more space
; ROUND
!SEEK 0x02518
    st.h r10, RD_OFF[r1]
!SEEK 0x02524
    st.h r10, RD_OFF+2[r1]
!SEEK 0x02530
    st.h r10, RD_OFF+4[r1]
!SEEK 0x0253C
    st.h r10, RD_OFF+6[r1]
!SEEK 0x02548
    st.h r10, RD_OFF+8[r1]

; ROUND
!SEEK 0x03EEE
    st.h r10, RD_OFF[r1]
!SEEK 0x03EfA
    st.h r10, RD_OFF+2[r1]
!SEEK 0x03F06
    st.h r10, RD_OFF+4[r1]
!SEEK 0x03F12
    st.h r10, RD_OFF+6[r1]
!SEEK 0x03F1E
    st.h r10, RD_OFF+8[r1]

; Move ROUND number over
!SEEK 0x0B58C
    movea RD_NUM, r1, r10

; PLAYER --> P on start
!ORG 0x07002554
!SEEK 0x02554
    st.h r10, PL_OFF[r1]
    movea 0x4011, r0, r10
    movhi 0x02, r0, r1
    st.h r10, HI_OFF[r1]
    movea 0x4012, r0, r10
    movhi 0x02, r0, r1
    st.h r10, 2+HI_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
        jr SKIP_LAYER_BOOT
!ORG 0x07002594
SKIP_LAYER_BOOT:

; LEADER --> L on unpause
!ORG 0x07003F46
!SEEK 0x03F46
    st.h r10, PL_OFF[r1]
    movea 0x4011, r0, r10
    movhi 0x02, r0, r1
    st.h r10, HI_OFF[r1]
    movea 0x4012, r0, r10
    movhi 0x02, r0, r1
    st.h r10, 2+HI_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
        jr PRINT_LIVES

; PLAYER --> P on unpause
!ORG 0x07003F8A
!SEEK 0x03F8A
    st.h r10, PL_OFF[r1]
    movea 0x4011, r0, r10
    movhi 0x02, r0, r1
    st.h r10, HI_OFF[r1]
    movea 0x4012, r0, r10
    movhi 0x02, r0, r1
    st.h r10, 2+HI_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
        jr PRINT_LIVES
!ORG 0x07003FCA
PRINT_LIVES:

; LEADER --> L when score changes
!ORG 0x0700B4BC
!SEEK 0x0B4BC
    st.h r10, PL_OFF[r1]
        jr SHORT_CHANGE
!ORG 0x0700B522
SHORT_CHANGE:

; WINNER --> W at game over
!ORG 0x07017FEA
!SEEK 0x17FEA
    st.h r11, PL_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
    jr SHORT_CREDITS

; LEADER --> L at game over
!ORG 0x07018034
!SEEK 0x18034
    st.h r11, PL_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
    jr SHORT_CREDITS

!ORG 0x07018074
SHORT_CREDITS:

; LEADER --> L
!ORG 0x070187F8
!SEEK 0x187F8
    st.h r10, PL_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
    jr SHORT_LEADER

; PLAYER --> P
!ORG 0x0701883C
!SEEK 0x1883C
    st.h r10, PL_OFF[r1]
    ?push lp
        jal PRINT_SCORE
    ?pop lp
    jr SHORT_LEADER

!ORG 0x0701887C
SHORT_LEADER:

; Move PLAYER number over
!SEEK 0x0B5EE
    movea PL_NUM, r1, r10

; Move current score over
!SEEK 0x0B660
    movea CSCORE, r1, r10

; LIVES
!SEEK 0x0259C
    st.h r10, LV_OFF[r1]
!SEEK 0x025A8
    st.h r10, LV_OFF+2[r1]
!SEEK 0x025B4
    st.h r10, LV_OFF+4[r1]
!SEEK 0x025C0
    st.h r10, LV_OFF+6[r1]
!SEEK 0x025CC
    st.h r10, LV_OFF+8[r1]

!SEEK 0x03FD2
    st.h r10, LV_OFF[r1]
!SEEK 0x03FDE
    st.h r10, LV_OFF+2[r1]
!SEEK 0x03FEA
    st.h r10, LV_OFF+4[r1]
!SEEK 0x03FF6
    st.h r10, LV_OFF+6[r1]
!SEEK 0x04002
    st.h r10, LV_OFF+8[r1]

; Move LIVES number over
!SEEK 0x0B69E
    movea LV_NUM, r1, r10

; Move ATOLLERS number over
!SEEK 0x0B6F6
    movea AT_NUM, r1, r10

; ATOLLERS
!SEEK 0x025D8
    st.h r10, AT_OFF[r1]
!SEEK 0x025E4
    st.h r10, AT_OFF+2[r1]
!SEEK 0x025F0
    st.h r10, AT_OFF+4[r1]
!SEEK 0x025FC
    st.h r10, AT_OFF+6[r1]
!SEEK 0x02608
    st.h r10, AT_OFF+8[r1]
!SEEK 0x02614
    st.h r10, AT_OFF+10[r1]
!SEEK 0x02620
    st.h r10, AT_OFF+12[r1]
!SEEK 0x0262C
    st.h r10, AT_OFF+14[r1]

!SEEK 0x0400E
    st.h r10, AT_OFF[r1]
!SEEK 0x0401A
    st.h r10, AT_OFF+2[r1]
!SEEK 0x04026
    st.h r10, AT_OFF+4[r1]
!SEEK 0x04032
    st.h r10, AT_OFF+6[r1]
!SEEK 0x0403E
    st.h r10, AT_OFF+8[r1]
!SEEK 0x0404A
    st.h r10, AT_OFF+10[r1]
!SEEK 0x04056
    st.h r10, AT_OFF+12[r1]
!SEEK 0x04062
    st.h r10, AT_OFF+14[r1]

!ORG 0x0700988C
!SEEK 0x0988C
    jr SAVE_SCORE                   ; st.w r11, -0x1570[r1]
SAVE_SCORE_RETURN:

!ORG 0x07FFFFF0
SOFT_RESET:

; Wipe SRAM if users presses L + R + Left Down + Right Down
!ORG 0x07018D8A
!SEEK 0x18D8A
    jr WIPE_SRAM
WIPE_SRAM_RETURN:
    andi 0x20, r10, r10

!ORG 0x0701C2A0
!SEEK 0x1C2A0
CHECKWORD:
    ?STRING "WWSV"

CHECK_SRAM:
    ?push r6, lp
    jal VALIDATE_CHECKWORD
    ?pop r6, lp
    movea 0x4268, r0, r7
    jr CHECK_SRAM_RETURN

; Boilerplate SRAM functions
!CONST SRAM_CHECKWORD, 0
!INCLUDE "include/boot.asm"

PRINT_SCORE:
    ?push r7, r10, r12, r13, r30, lp
        jal PARSE_SAVED_SCORE       ; saved high score is now in r7
    movhi 0x2, r0, r1
    movea HI_NUM, r1, r10
    NEXT_SCORE_TILE:                ; i know what this is *doing* but don't understand it.
        mov r7, r12                 ; it's taking the hex score and doing all kinds of math
        mov 10, r13                 ; which ends up dropping a remainder 0-9 into r30.
        div r13, r12                ; that remainder is used as a tile to print into the
        mov r30, r12                ; score display, then it cycles on to the next digit.
        st.h r12, 0x0000[r10]       ; i stole this logic from the normal score counter
        mov 2, r12
        sub r12, r10
        mov 10, r12
        div r12, r7
            bgt NEXT_SCORE_TILE
    ?pop r7, r10, r12, r13, r30, lp
    jmp [lp]

SAVE_SCORE:
    ?push r6, r7                    ; r1 and r11 are free
    st.w r11, -0x1570[r1]
    ?push lp
        jal PARSE_SAVED_SCORE
    ?pop lp
    cmp r7, r11
        blt NO_NEW_BEST
    NEW_BEST:
    mov r11, r7
        st.b r7, 0x0008[r6]
        shr 8, r7
        st.b r7, 0x000A[r6]
        shr 8, r7
        st.b r7, 0x000C[r6]
        shr 8, r7
        st.b r7, 0x000E[r6]
    NO_NEW_BEST:
        ?pop r6, r7
    jr SAVE_SCORE_RETURN

PARSE_SAVED_SCORE:                  ; leaves 06000000 in r6 and saved score in r7
    ?push r1
    movhi 0x600, r0, r6
    ld.b 0x000E[r6], r7
    shl 8, r7
    ld.b 0x000C[r6], r1
    andi 0xFF, r1, r1
    or r1, r7
    shl 8, r7
    ld.b 0x000A[r6], r1
    andi 0xFF, r1, r1
    or r1, r7
    shl 8, r7
    ld.b 0x0008[r6], r1
    andi 0xFF, r1, r1
    or r1, r7
    ?pop r1
        jmp [lp]

WIPE_SRAM:
    ?push r6
    movhi 0x200, r0, r6
    ld.h 0x0014[r6], r10
    ld.h 0x0010[r6], r6
    shl 8, r6
    or r6, r10
    movea 0x3284, r0, r6
    cmp r6, r10
        bne DONT_ERASE
    movhi 0x600, r0, r6
    st.w r0, 0x0000[r6]
        jr SOFT_RESET
    DONT_ERASE:
        ?pop r6
        ld.h 0x1BB8[gp], r10            ; restored button check
            jr WIPE_SRAM_RETURN