!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
; skip printing auto-pause menu
!SEEK 0x099B2
    ?db 0x00, 0x00, 0x00, 0x00
!SEEK 0x099CE
    ?db 0x00, 0x00, 0x00, 0x00
!SEEK 0x099E8
    ?db 0x00, 0x00, 0x00, 0x00
; instruction manual and IPD
!SEEK 0x09E88
    ?db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; skip auto-pause selection
!ORG 0xFFFA7726
!SEEK 0x27726
    jr BPS_LOGO         ; jal fff0a0e8, CHECK_INPUT
!ORG 0xFFFA7ABC
    BPS_LOGO:
!ENDIF

; Read and/or init SRAM
!ORG 0xFFF89050
!SEEK 0x09050
    jal CHECK_SRAM      ; movea 0x4000, r0, r7
    !ORG 0xFFF89146
    CLEAR_MEM:

!ORG 0xFFF8908C
    RESET_SCORES:

; Load initials from save
!ORG 0xFFF89C0A
!SEEK 0x09C0A
    br SKIP_INITIALS
    .NEXT_BYTE:
    ld.w 0x0014[sp], r10
    shl 2, r10
    mov r10, r30
    shl 1, r30
    add r30, r10
    ld.w 0x0018[sp], r11
    add r11, r10
    ld.w 0x0014[sp], r11
    shl 3, r11
    mov r11, r30
    shl 1, r30
    add r30, r11
    ld.w 0x0018[sp], r12
    shl 1, r12
    add r12, r11
    movhi 0x600, r11, r1
    ld.b 0x0010[r1], r11
    movhi 0x500, r10, r1
    st.b r11, 0x2898[r1]
    ld.w 0x0018[sp], r10
    add 1, r10
    st.w r10, 0x0018[sp]
    ld.w 0x0018[sp], r10
    cmp 3, r10
    blt .NEXT_BYTE
    !ORG 0xFFF89C4C
    SKIP_INITIALS:

; Load scores from save
!SEEK 0x09C78
    shl 3, r11
!ORG 0xFFF89C80
!SEEK 0x09C80
    jr LOAD_SCORES
        ?db 0x00, 0x00, 0x00, 0x00
    LOAD_SCORES_RETURN:

; Load levels from save
!SEEK 0x09CA0
    shl 3, r11          ; only actually changing this
!SEEK 0x09CA8
    movhi 0x600, r11, r1; this
    ld.b 0x0020[r1], r11; and this

; Move initials down
!ORG 0xFFF8E3E8
!SEEK 0x0E3E8
    jr MOVE_INITIALS    ; st.b r11, 0x0000[r10]
    MOVE_INITIALS_RETURN:

; Move score down
!ORG 0xFFF8E428
!SEEK 0xE428
    jr MOVE_SCORE       ; st.w r11, 0x0004[r10]
    MOVE_SCORE_RETURN:

; Move level down
!ORG 0xFFF8E456
!SEEK 0x0E456
    jr MOVE_LEVEL       ; st.b r11, 0x0008[r10]
    MOVE_LEVEL_RETURN:

; Write new initials
!ORG 0xFFF8EEC6
!SEEK 0x0EEC6
    jr NEW_INITIALS     ; st.b r11, 0x0000[r10]
    NEW_INITIALS_RETURN:

; Write new score
!ORG 0xFFF8EEFE
!SEEK 0x0EEFE
    jr NEW_SCORE        ; st.w r11, 0x0004[r10]
    NEW_SCORE_RETURN:

; Write new level
!ORG 0xFFF8EF56
!SEEK 0x0EF56
    jr NEW_LEVEL        ; st.b r11, 0x0008[r10]
    NEW_LEVEL_RETURN:

; Erase SRAM if user presses L + R + Left Down + Right Down on the title screen
!ORG 0xFFFACD20
!SEEK 0x2CD20
    jr ERASE_CHECK      ; ld.h 0x001C[sp], r10
    ERASE_CHECK_RETURN:

!ORG 0xFFF81624
!SEEK 0x01624
CHECKWORD:
    ?STRING "VTSV"

CHECK_SRAM:
    ?push r8, lp            ; r1, r6 and r7 are free
    ?mov CHECKWORD, r1
    movhi 0x600, r0, r6
        NEXT_CHECKBYTE:
            andi 8, r6, r0          ; if CHECKWORD is valid, skip SRAM init
            bne CHECKWORD_OK
                ld.b 0x0000[r1], r7
                ld.b 0x0000[r6], r8
                add 1, r1
                add 2, r6
                cmp r7, r8
                be NEXT_CHECKBYTE
    jal CLEAR_SRAM
    CHECKWORD_OK:
        movea 0x4000, r0, r7    ; restored from original
        ?pop r8, lp
        jmp [lp]

CLEAR_SRAM:
    ?push lp
    movhi 0x600, r0, r6
    movea 0x4000, r0, r7
    mov r0, r8
    jal CLEAR_MEM
    ?mov CHECKWORD, r1
    ld.w 0x0000[r1], r1
    movhi 0x600, r0, r6
        WRITE_CHECKWORD:
            st.b r1, 0x0000[r6]
            shr 8, r1
            add 2, r6
            andi 0x8, r6, r0
                be WRITE_CHECKWORD
    add -8, r6
    movhi 0xFFFD, r0, r1
    movea 0xF2D4, r1, r1
    movea 0x0168, r0, r8
        NEXT_SCORE_BYTE:
            ld.b 0x0000[r1], r7
            st.b r7, 0x0010[r6]
            add 1, r1
            add 2, r6
            add -1, r8
                bne NEXT_SCORE_BYTE
    ?pop lp
    jmp [lp]

LOAD_SCORES:       ; r12 is free
    movhi 0x600, r11, r1
    ld.b 0x001E[r1], r11
    shl 8, r11
    ld.b 0x001C[r1], r12
    andi 0xFF, r12, r12
    or r12, r11
    shl 8, r11
    ld.b 0x001A[r1], r12
    andi 0xFF, r12, r12
    or r12, r11
    shl 8, r11
    ld.b 0x0018[r1], r12
    andi 0xFF, r12, r12
    or r12, r11
    jr LOAD_SCORES_RETURN

MOVE_INITIALS:
    ?push lp
    jal STORE_BYTE
    ?pop lp
    st.b r11, 0x0010[r13]
    st.b r11, 0x0000[r10]
    jr MOVE_INITIALS_RETURN

MOVE_SCORE:
    ?push lp
    jal STORE_WORD
    ?pop lp
    jr MOVE_SCORE_RETURN

MOVE_LEVEL:
    ?push lp
    jal STORE_BYTE
    ?pop lp
    st.b r11, 0x0020[r13]
    st.b r11, 0x0008[r10]
    jr MOVE_LEVEL_RETURN

NEW_INITIALS:
    ?push lp
    jal STORE_BYTE
    ?pop lp
    st.b r11, 0x0010[r13]
    st.b r11, 0x0000[r10]
    jr NEW_INITIALS_RETURN

NEW_SCORE:
    ?push lp
    jal STORE_WORD
    ?pop lp
    jr NEW_SCORE_RETURN

NEW_LEVEL:
    ?push lp
    jal STORE_BYTE
    ?pop lp
    st.b r11, 0x0020[r13]
    st.b r11, 0x0008[r10]
    jr NEW_LEVEL_RETURN

STORE_BYTE:
    andi 0x01FF, r10, r13
    movea 0x98, r0, r14
    sub r14, r13
    shl 1, r13
    movhi 0x600, r13, r13
    jmp [lp]

STORE_WORD:
    andi 0x01FF, r10, r13
    movea 0x98, r0, r14
    sub r14, r13
    shl 1, r13
    movhi 0x600, r13, r13
    st.w r11, 0x0004[r10]
    st.b r11, 0x0018[r13]
    shr 8, r11
    st.b r11, 0x001A[r13]
    shr 8, r11
    st.b r11, 0x001C[r13]
    shr 8, r11
    st.b r11, 0x001E[r13]
    jmp [lp]

ERASE_CHECK:
    ?push r7
    ld.h 0x0028[sp], r10
    movea 0x8430, r0, r7
    cmp r7, r10
    bne NO_ERASE
        jal CLEAR_SRAM
        jal RESET_SCORES
    NO_ERASE:
    ?pop r7
    ld.h 0x001C[sp], r10
    jr ERASE_CHECK_RETURN