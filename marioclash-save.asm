!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
; Disable Startup Noise
!SEEK 0xDD3A4
    mov r0, r0
    mov r0, r0

; Disable Splash Screens
!SEEK 0xDD42E
    mov r0, r0
    mov r0, r0
!ENDIF

; Load the high scores from save instead of ROM
!ORG 0xFFFDD358
!SEEK 0xDD358
    shl 3, r11
    jr LOAD_HIGH_SCORES
    ?db 0x00, 0x00, 0x00, 0x00
LOAD_HIGH_SCORES_RETURN:

; Level when score was achieved
!ORG 0xFFFDD372
!SEEK 0xDD372
    jr LOAD_SCORE_LEVELS
LOAD_SCORE_LEVELS_RETURN:
    ld.b -0x6540[r1], r11

; Load brightness from save instead of ROM
!ORG 0xFFFDD3BA
!SEEK 0xDD3BA
    jr LOAD_BRIGHTNESS
    mov r0, r0
LOAD_BRIGHTNESS_RETURN:

; Save max level to SRAM when reaching new level
!ORG 0xFFFDF6B0
!SEEK 0xDF6B0
    jr SAVE_LEVEL               ; movhi 0x501, r0, r1
SAVE_LEVEL_RETURN:

; Erase SRAM if user presses L+R+Left Down+Right Down on the title screen
!ORG 0xFFFE6AEA
!SEEK 0xE6AEA
    jr ERASE_SAVE               ; st.w r10, 0x0014[sp]
ERASE_SAVE_RETURN:

; Load max level from save instead of hardcoded 1
!ORG 0xFFFE76C2
!SEEK 0xE76C2
    jr LOAD_LEVEL
    mov r0, r0
LOAD_LEVEL_RETURN:

; Level Select max check
!ORG 0xFFFE7A24
!SEEK 0xE7A24
    jr MAX_LEVEL_UP
MAX_LEVEL_UP_RETURN:

!ORG 0xFFFE7B00
!SEEK 0xE7B00
    jr MAX_LEVEL_DOWN
MAX_LEVEL_DOWN_RETURN:

!ORG 0xFFFE7A96
!SEEK 0xE7A96
    jr SAVE_BRIGHTNESS_UP       ; st.b r10, 0x5A63[r1]
SAVE_BRIGHTNESS_UP_RETURN:

!ORG 0xFFFE7B4A
!SEEK 0xE7B4A
    jr SAVE_BRIGHTNESS_DOWN     ; st.b r10, 0x5A63[r1]
SAVE_BRIGHTNESS_DOWN_RETURN:

!ORG 0xFFFFC752
!SEEK 0xFC752
    jr SAVE_SCORES_A            ; st.w r12, -0x6554[r1]
    ?db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
SAVE_SCORES_A_RETURN:

!ORG 0xFFFFC782
!SEEK 0xFC782
    jr SAVE_SCORES_B            ; st.w r12, -0x6564[r1]
    ?db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
SAVE_SCORES_B_RETURN:

!ORG 0xFFFFD7AA
!SEEK 0xFD7AA
    jr CHECK_SRAM               ; movhi 0x500, r0, r10
CHECK_SRAM_RETURN:

!ORG 0xFFF0C3E8
!SEEK 0x0C3E8
CHECKWORD:
    ?STRING "MCSV"

CHECK_SRAM:
    ?push r6                    ; r10, r11, r12 will be cleared by CLEAR_MEM
    ?mov CHECKWORD, r6
    movhi 0x600, r0, r10
        NEXT_CHECKBYTE:
            andi 4, r10, r0
                bne CLEAR_MEM
            ld.b 0x0000[r6], r11
            ld.b 0x0000[r10], r12
            add 1, r6
            add 2, r10
            cmp r11, r12
                be NEXT_CHECKBYTE
    jal CLEAR_SRAM
    br CLEAR_MEM
CLEAR_MEM:
    ?pop r6
    movhi 0x500, r0, r10
    ?br CHECK_SRAM_RETURN

CLEAR_SRAM:
    ?push r6, r10, r11, r12
    movhi 0x600, r0, r10
    movea 0x4000, r0, r11
        NEXT_SRAM:
            st.w r0, 0x0000[r10]
            add 4, r10
            add -1, r11
                bne NEXT_SRAM
    ?mov CHECKWORD, r6
    ld.w 0x0000[r6], r6
    movhi 0x600, r0, r10
    WRITE_CHECKWORD:
        st.b r6, 0x0000[r10]
        shr 8, r6
        add 2, r10
        andi 0x8, r10, r0
            be WRITE_CHECKWORD
    add -8, r10                 ; set save back to 0 offset
    mov 2, r11
    st.b r11, 0x5A62[r10]       ; brightness, off by one from RAM
    movhi 0x601, r0, r10
    mov 1, r11
    st.b r11, -0x658C[r10]      ; level
        INIT_HIGH_SCORES:
            movhi 0xFFF2, r0, r6        ; high scores in ROM
            movhi 0x0601, r0, r10       ; high scores in SRAM
            movea 0x19, r0, r12
                NEXT_SCORE:
                    ld.b -0x15B4[r6], r11
                    st.b r11, -0x6568[r10]
                    add 1, r6
                    add 2, r10
                    add -1, r12
                        bne NEXT_SCORE
    ?pop r6, r10, r11, r12
    jmp [lp]

LOAD_HIGH_SCORES:
    ?push r6
    movhi 0x601, r11, r1
    ld.b -0x6562[r1], r11
    shl 24, r11
    ld.b -0x6564[r1], r6
    andi 0xFF, r6, r6
    shl 16, r6
    or r6, r11
    ld.b -0x6566[r1], r6
    andi 0xFF, r6, r6
    shl 8, r6
    or r6, r11
    ld.b -0x6568[r1], r6
    andi 0xFF, r6, r6
    or r6, r11
    ?pop r6
    ?br LOAD_HIGH_SCORES_RETURN

LOAD_SCORE_LEVELS:
    shl 1, r11
    movhi 0x601, r11, r1
    ?br LOAD_SCORE_LEVELS_RETURN

LOAD_BRIGHTNESS:
    movhi 0x600, r0, r10
    ld.b 0x5A62[r10], r10
    st.b r10, 0x1A63[gp]
    ?br LOAD_BRIGHTNESS_RETURN

SAVE_LEVEL:
    movhi 0x601, r0, r1
    st.b r10, -0x658C[r1]
    movhi 0x501, r0, r1
    ?br SAVE_LEVEL_RETURN

ERASE_SAVE:
    ?push r6
    movea 0x8432, r0, r6
    andi 0xFFFF, r6, r6
    cmp r6, r10
    bne DONT_ERASE
    movea 0x303C, r0, r10
    jal CLEAR_SRAM
    DONT_ERASE:
    ?pop r6
    st.w r10, 0x0014[sp]
    ?br ERASE_SAVE_RETURN

LOAD_LEVEL:
    movhi 0x601, r0, r10
    ld.b -0x658C[r10], r10
    movhi 0x501, r0, r1
    ?br LOAD_LEVEL_RETURN

MAX_LEVEL_UP:
    movhi 0x601, r0, r1
    ld.b -0x658C[r1], r1
    ?br MAX_LEVEL_UP_RETURN

MAX_LEVEL_DOWN:
    movhi 0x601, r0, r10
    ld.b -0x658C[r10], r10
    ?br MAX_LEVEL_DOWN_RETURN

SAVE_BRIGHTNESS_UP:
    st.b r10, 0x5A63[r1]
    movhi 0x600, r0, r1
    st.b r10, 0x5A62[r1]
    ?br SAVE_BRIGHTNESS_UP_RETURN

SAVE_BRIGHTNESS_DOWN:
    st.b r10, 0x5A63[r1]
    movhi 0x600, r0, r1
    st.b r10, 0x5A62[r1]
    ?br SAVE_BRIGHTNESS_DOWN_RETURN

SAVE_SCORES_A:
    st.w r12, -0x6568[r1]       ; write to RAM
    shl 1, r11
    movhi 0x601, r11, r1
    st.b r12, -0x6568[r1]       ; write to SRAM ...
    shr 8, r12
    st.b r12, -0x6566[r1]       ; one ...
    shr 8, r12
    st.b r12, -0x6564[r1]       ; byte ...
    shr 8, r12
    st.b r12, -0x6562[r1]       ; at a time
    movhi 0x501, r0, r1
    ld.b -0x658C[r1], r11
    shl 1, r24
    movhi 0x601, r24, r1
    st.b r11, -0x6540[r1]       ; level
    shr 1, r24
    ?br SAVE_SCORES_A_RETURN

SAVE_SCORES_B:              ; lol scoresby
    st.w r12, -0x6564[r1]       ; write to ram
    shl 1, r11
    movhi 0x601, r11, r1
    st.b r12, -0x6564[r1]       ; here we go again
    shr 8, r12
    st.b r12, -0x6562[r1]
    shr 8, r12
    st.b r12, -0x6560[r1]
    shr 8, r12
    st.b r12, -0x655E[r1]
    movea 0x28, sp, r11
    add r25, r11
    ld.b 0x0000[r11], r11
    shl 1, r25
    movhi 0x601, r25, r1
    st.b r11, -0x653E[r1]
    shr 1, r25
    ?br SAVE_SCORES_B_RETURN