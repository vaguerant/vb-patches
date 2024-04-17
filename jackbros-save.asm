!IF 0
; Disable start noise
!SEEK 0x00054
    mov r0, r0
    mov r0, r0
; Skip warning
!SEEK 0x1AD36
    mov r0, r0
    mov r0, r0
; Skip IPD
!SEEK 0x1AD6E
    mov r0, r0
    mov r0, r0
; Skip auto-pause
!SEEK 0x1AD72
    mov r0, r0
    mov r0, r0
!ENDIF

; Enable debug cheats
!SEEK 0x00000
?db 0xFF, 0x00

; Check and (if necessary) init SRAM
!ORG 0x07000044
!SEEK 0x00044
    jr CHECK_SRAM           ; mov r25, r6
    mov r0, r0              ; movea 0x4000, r0, r7
CHECK_SRAM_RETURN:

; The sound test needs the text routine to use the Japanese font,
; so the US game disables it entirely. Instead, we're going to
; check if we're in the sound test currently and switch language.
!ORG 0x0700121E
!SEEK 0x0121E
    movhi 0x600, r0, r1
    ld.b 0x0004[r1], r7
    st.b r7, 0x00F2[r25]
    br SOUND_TEST_CHECK
JAPAN_FIX:
    mov r0, r7
    st.b r7, 0x00F2[r25]
    br SOUND_TEST
SOUND_TEST_CHECK:

; Successfully entered sound test cheat
!ORG 0x07001258
!SEEK 0x001258
    be JAPAN_FIX
    jr SOUND_CHECK_FAILED
SOUND_TEST:
!ORG 0x070012CC
SOUND_CHECK_FAILED:

; Dialogue text printing, needs a fix to handle sound test switch.
!ORG 0x070036D0
!SEEK 0x036D0
    br FONT_CHECK
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
FONT_CHECK:
    ld.h 0x00f2[r25], r11
    cmp r0, r11

; Secret language switch built into the game?! Hijack this to switch in SRAM
!ORG 0x0700461E
!SEEK 0x0461E
    jr LANGUAGE_SWAP        ; st.h r6, 0x00F2[r25]
LANGUAGE_SWAP_RETURN:

; Read language byte from save (0x600) instead of ROM (0x700) everywhere
!SEEK 0x0481A
    movhi 0x600, r0, r1
!SEEK 0x048AC
    movhi 0x600, r0, r1
!SEEK 0x0495A
    movhi 0x600, r0, r1
!SEEK 0x111F2
    movhi 0x600, r0, r1
!SEEK 0x12962
    movhi 0x600, r0, r1
!SEEK 0x12BE2
    movhi 0x600, r0, r1
!SEEK 0x13998
    movhi 0x600, r0, r1
!SEEK 0x14F26
    movhi 0x600, r0, r1
!SEEK 0x174FC
    movhi 0x600, r0, r1
!SEEK 0x1915E
    movhi 0x600, r0, r1
!SEEK 0x19946
    movhi 0x600, r0, r1
!SEEK 0x19ACE
    movhi 0x600, r0, r1
!SEEK 0x19CF6
    movhi 0x600, r0, r1
!SEEK 0x1AD7A
    movhi 0x600, r0, r1
!SEEK 0x1ADBA
    movhi 0x600, r0, r1
!SEEK 0x1B07A
    movhi 0x600, r0, r1

; "CONTINUE" string for the title screen
!SEEK 0x4A73
    ?db 0x1C, 0x28, 0x27, 0x2D, 0x22, 0x27, 0x2E, 0x1E

; Display PRESS START text on password screen if a password has been saved
!ORG 0x070114EC
!SEEK 0x114EC
    jr PRESS_START          ; jal PASSWORD_SCREEN
PRESS_START_RETURN:

; Stock function to print text on the password screen
!ORG 0x070035E0
PASSWORD_PRINT:

; We need to return here after injecting the "PRESS START" text
!ORG 0x07003ABA
PASSWORD_SCREEN:

; Save last entered password
!ORG 0x070119BA
!SEEK 0x119BA
    jr WROTE_PASSWORD       ; movea 0x21, r0, r6
WROTE_PASSWORD_RETURN:

; Save last received password
!ORG 0x070120FC
!SEEK 0x120FC
    jr GOT_PASSWORD         ; st.b r8, 0x0030[r25]
GOT_PASSWORD_RETURN:

; Continue from saved password by pressing Start
!ORG 0x0701162A
!SEEK 0x1162A
    jr CONTINUE             ; ld.b 0x0033[r25], r8
CONTINUE_RETURN:

; Pixie passwords need the button code, Pixie *saves* bypass the code
!ORG 0x070119A6
!SEEK 0x119A6
    jr PIXIE_LOAD           ; ld.h 0x0010[r25], r10
PIXIE_PASS_RETURN:
!ORG 0x070119BA
PIXIE_LOAD_RETURN:

!ORG 0x0707DDC0
!SEEK 0x7DDC0
CHECKWORD:
    ?STRING "JBSV"

CHECK_SRAM:
    ?mov CHECKWORD, r1
    ld.w 0x0000[r1], r1
    movhi 0x600, r0, r6
    ld.w 0x0000[r6], r7
    cmp r1, r7
    be CLEAR_MEM
    jal CLEAR_SRAM
CLEAR_MEM:
    mov r25, r6
    movea 0x4000, r0, r7
    jr CHECK_SRAM_RETURN

CLEAR_SRAM:
    ?push r1, r6, r7
    ?mov CHECKWORD, r1
    ld.w 0x0000[r1], r1
    movhi 0x600, r0, r6
    movea 0x4000, r0, r7
        NEXT_SRAM:
            st.w r0, 0x0000[r6]
            add 4, r6
            add -1, r7
            bne NEXT_SRAM
    movhi 0x600, r0, r6
    st.w r1, 0x0000[r6]     ; checkword
    mov -1, r7
    st.b r7, 0x0004[r6]     ; language
    st.w r7, 0x0030[r6]     ; password
    ?pop r1, r6, r7
    jmp [lp]

LANGUAGE_SWAP:
    ?push r7
    movhi 0x600, r0, r1
    ld.b 0x0004[r1], r7
    xor r7, r6
    st.h r6, 0x0004[r1]
    ?pop r7
    jr LANGUAGE_SWAP_RETURN

CONTINUE:
    ?push r6
    ld.h 0x0010[r25], r6
    andi 0x0040, r6, r6     ; has user pressed Start?
    be NO_START
    movhi 0x600, r0, r6
    ld.w 0x0030[r6], r6
    cmp -1, r6              ; is password initialized?
    be NO_START
    st.w r6, 0x0030[r25]    ; copy saved password into memory
NO_START:
    ?pop r6
    ld.b 0x0033[r25], r8
    jr CONTINUE_RETURN

WROTE_PASSWORD:
    ?push r7
    movhi 0x600, r0, r7
    st.w r6, 0x0030[r7]
    ?pop r7
    movea 0x21, r0, r6
jr WROTE_PASSWORD_RETURN

GOT_PASSWORD:
    ?push r6, r7
    movhi 0x600, r0, r1
    ld.b 0x0034[r1], r6
    movhi 0x600, r6, r7
    add 1, r6
    cmp 4, r6
    bne WRITE_PASSWORD_BYTE
    mov 0, r6
WRITE_PASSWORD_BYTE:
    st.b r6, 0x0034[r1]
    st.b r8, 0x0030[r7]
    ?pop r6, r7
    st.b r8, 0x0030[r25]
    jr GOT_PASSWORD_RETURN

PRESS_START:
    ?push r1, r6, r7, r9, lp
    movhi 0x600, r0, r6
    ld.w 0x0030[r6], r6
    cmp -1, r6
    be NO_SAVED_PASSWORD
    movhi 0x2, r0, r1
    movea 0x394, r1, r6     ; where to print: left byte vert, right byte hori
    ?mov START_TEXT, r7
    movea 0x100, r0, r9
    mov 5, r1
    st.b r1, 0x008E[r25]    ; offset into the character map
    jal PASSWORD_PRINT
    st.b r0, 0x008E[r25]
NO_SAVED_PASSWORD:
    ?pop r1, r6, r7, r9, lp
    jal PASSWORD_SCREEN
    jr PRESS_START_RETURN
        START_TEXT:         ; "OR PRESS START"
            ?db 0x28, 0x2B, 0x00, 0x29, 0x2B, 0x1E, 0x2C, 0x2C, 0x00, 0x2C, 0x2D, 0x1A, 0x2B, 0x2D, 0x02

PIXIE_LOAD:
    ld.h 0x0010[r25], r10
    andi 0x0040, r10, r0
    be PIXIE_PASSWORD
    ld.w 0x0030[r25], r1
    movhi 0x600, r0, r10
    ld.w 0x0030[r10], r10
    cmp r1, r10
    bne PIXIE_PASSWORD
    jr PIXIE_LOAD_RETURN
PIXIE_PASSWORD:
    jr PIXIE_PASS_RETURN