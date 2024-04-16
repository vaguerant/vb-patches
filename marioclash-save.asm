!IF 0
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
!SEEK 0xDD35A
    movhi 0x601, r11, r1        ; movhi 0xFFF2, r11, r1
    ld.w -0x6568[r1], r11       ; ld.w -0x15B4[r1], r11

; Level when score was achieved
!SEEK 0xDD372
    movhi 0x601, r11, r1        ; movhi 0xFFF2, r11, r1
    ld.b -0x6554[r1], r11       ; ld.b 0xffffea60[r1], r11

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

; Erase SRAM if user presses L+R+Left D-Pad Down+Right D-Pad Down on the title screen
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
    jr MAX_LEVEL_UP;
MAX_LEVEL_UP_RETURN:

!ORG 0xFFFE7B00
!SEEK 0xE7B00
    jr MAX_LEVEL_DOWN;
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
SAVE_SCORES_A_RETURN:
    movhi 0x601, r24, r1
    st.b r11, -0x6554[r1]       ; this and SCORES_B both finish up *after* returning

!ORG 0xFFFFC782
!SEEK 0xFC782
    jr SAVE_SCORES_B            ; st.w r12, -0x6564[r1]
    mov r0, r0
SAVE_SCORES_B_RETURN:
    movhi 0x601, r25, r1
    st.b r11, -0x6553[r1]

!ORG 0xFFFFD7AA
!SEEK 0xFD7AA
    jr CHECK_SRAM               ; movhi 0x500, r0, r10
CHECK_SRAM_RETURN:

!ORG 0xFFF0C3E8
!SEEK 0x0C3E8
CHECKWORD:
    ?STRING "MCSV"
CHECK_SRAM:
    ?push r6, r7
    movhi 0x600, r0, r10
    ld.w 0x0000[r10], r11
    ?mov CHECKWORD, r6
    ld.w 0x0000[r6], r6
    cmp r6, r11
    be CLEAR_MEM
    jal CLEAR_SRAM
CLEAR_MEM:
    ?pop r6, r7
    movhi 0x500, r0, r10
    jr CHECK_SRAM_RETURN

CLEAR_SRAM:
    ?push r6, r10, r11, r12
    ?mov CHECKWORD, r6
    ld.w 0x0000[r6], r6
    movhi 0x600, r0, r10
    movhi 0x01, r0, r11
    mov 4, r12
        NEXT_SRAM:
            st.w r0, 0000[r10]
            add r12, r10
            sub r12, r11
            bne NEXT_SRAM
    movhi 0x600, r0, r10
    st.w r6, 0x0000[r10]    ; MCSV
    mov 2, r11
    st.b r11, 0x5A63[r10]   ; brightness
    movhi 0x601, r0, r10
    mov 1, r11
    st.b r11, -0x658C[r10]  ; level
        INIT_HIGH_SCORES:
            mov 0, r6
            movea 0x18, r0, r7
                NEXT_SCORE:
                    movhi 0xFFF2, r6, r10
                    ld.w -0x15B4[r10], r10
                    movhi 0x0601, r6, r11
                    st.w r10, -0x6568[r11]
                    add 4, r6
                    cmp r6, r7
                    bne NEXT_SCORE
                    mov 2, r10              ; last byte is in the next word, rude
                    st.b r10, -0x6564[r11]
    ?pop r6, r10, r11, r12
    jmp [lp]

LOAD_BRIGHTNESS:
    movhi 0x600, r0, r10
    ld.b 0x5A63[r10], r10
    st.b r10, 0x1a63[gp]
    jr LOAD_BRIGHTNESS_RETURN

SAVE_LEVEL:
    movhi 0x601, r0, r1
    st.b r10, -0x658C[r1]
    movhi 0x501, r0, r1
    jr SAVE_LEVEL_RETURN

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
    jr ERASE_SAVE_RETURN

LOAD_LEVEL:
    movhi 0x601, r0, r10
    ld.b -0x658C[r10], r10
    movhi 0x501, r0, r1
    jr LOAD_LEVEL_RETURN

MAX_LEVEL_UP:
    movhi 0x601, r0, r1
    ld.b -0x658C[r1], r1
    jr MAX_LEVEL_UP_RETURN

MAX_LEVEL_DOWN:
    movhi 0x601, r0, r10
    ld.b -0x658C[r10], r10
    jr MAX_LEVEL_DOWN_RETURN

SAVE_BRIGHTNESS_UP:
    st.b r10, 0x5A63[r1]
    movhi 0x600, r0, r1
    st.b r10, 0x5A63[r1]
    jr SAVE_BRIGHTNESS_UP_RETURN

SAVE_BRIGHTNESS_DOWN:
    st.b r10, 0x5A63[r1]
    movhi 0x600, r0, r1
    st.b r10, 0x5A63[r1]
    jr SAVE_BRIGHTNESS_DOWN_RETURN

SAVE_SCORES_A:
    st.w r12, -0x6568[r1]
    movhi 0x601, r11, r1
    st.w r12, -0x6568[r1]
    movhi 0x501, r0, r1
    ld.b -0x658C[r1], r11
    jr SAVE_SCORES_A_RETURN

SAVE_SCORES_B:                              ; lol scoresby
    st.w r12, -0x6564[r1]
    movhi 0x601, r11, r1
    st.w r12, -0x6564[r1]
    movea 0x28, sp, r11
    add r25, r11
    ld.b 0x0000[r11], r11
    jr SAVE_SCORES_B_RETURN