!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
!SEEK 0x0086A
    ?dw 0x00000000, 0x00000000
!SEEK 0x00876
    ?dw 0x00000000
!SEEK 0x00886
    ?dw 0x00000000, 0x00000000
!ENDIF

!CONST SRAM_NAME1, 0x10
!CONST SRAM_NAME2, SRAM_NAME1 + 0x10
!ORG 0x05000318
RAM_SCORES:
!ORG 0x06000014
SRAM_NAMES:
!ORG 0x06000030
SRAM_SCORES:
!ORG 0xFFE116FC
ROM_SCORES:

; Erase SRAM if user presses L + R + Left Down + Right Down
!ORG 0xFFE03710
!SEEK 0x03710
    jal ERASE_CHECK

; Save default name if player skips name entry
!ORG 0xFFE0B22E
!SEEK 0x0B22E
    jr DEFAULT_NAME
    DEFAULT_NAME_RETURN:

; Save entered initials
!ORG 0xFFE0B410
!SEEK 0x0B410
    jr ENTER_NAME
    ?dw 0x00000000
    ENTER_NAME_RETURN:

; Save character choice
!ORG 0xFFE0B8BA
!SEEK 0x0B8BA
    jr SELECT_HESTER
    SELECT_HESTER_RETURN:
!ORG 0xFFE0B918
!SEEK 0x0B918
    jr SELECT_NESTER
    SELECT_NESTER_RETURN:

; Save ball weight
!ORG 0xFFE0BA5E
!SEEK 0x0BA5E
    jr SELECT_BALL      ; out.h r10, 0x0004[r25]
    SELECT_BALL_RETURN:

; Load high scores from save instead of ROM
!ORG 0xFFE0D180
!SEEK 0x0D180
    jal CHECK_SRAM      ; jal COPY_ROM2RAM

; When a new score is achieved, update SRAM
!ORG 0xFFE0D33E
!SEEK 0x0D33E
    jr UPDATE_SCORES    ; out.w r7, 0x0000[r11]
    UPDATE_SCORES_RETURN:

!ORG 0xFFE0D8F8
!SEEK 0x0D8F8
CHECKWORD:
    ?STRING "FBSV"

CHECK_SRAM:
    ?push lp
    jal VALIDATE_CHECKWORD
    cmp 0, r6
    be .CHECKWORD_OK
        movhi 0x600, r0, r6
        mov 12, r7                  ; default ball weight
        st.b r7, SRAM_NAME1+8[r6]
        st.b r7, SRAM_NAME2+8[r6]
        ?mov ROM_SCORES, r6
        ?mov SRAM_SCORES, r7
        jal COPY_TO_SRAM
    .CHECKWORD_OK:
        movhi 0x600, r0, r6
        ; player 1
        ld.w SRAM_NAME1[r6], r7     ; name
        xb r7
        shr 8, r7
        st.h r7, -0x7FEC[gp]
        ld.w SRAM_NAME1+4[r6], r7
        xb r7
        shr 8, r7
        st.h r7, -0x7FEA[gp]
        ld.b SRAM_NAME1+8[r6], r7   ; ball weight
        st.b r7, -0x7FE8[gp]
        ld.b SRAM_NAME1+10[r6], r7  ; character
        st.b r7, -0x7FDC[gp]
        ; player 2
        ld.w SRAM_NAME2[r6], r7     ; name
        xb r7
        shr 8, r7
        st.h r7, -0x7FD8[gp]
        ld.w SRAM_NAME2+4[r6], r7
        xb r7
        shr 8, r7
        st.h r7, -0x7FD6[gp]
        ld.b SRAM_NAME2+8[r6], r7   ; ball weight
        st.b r7, -0x7FD4[gp]
        ld.b SRAM_NAME2+10[r6], r7  ; character
        st.b r7, -0x7FC8[gp]
        ?mov SRAM_SCORES, r6
        ?mov RAM_SCORES, r7
        movea 0x40, r0, r8
        jal COPY_FROM_SRAM
    ?pop lp
    jmp [lp]

; Boilerplate SRAM functions
!CONST SRAM_CHECKWORD, 0
!INCLUDE "include/boot.asm"

COPY_TO_SRAM:  ; r6 source, r7 dest, r8 length
    ?push r8, r9
    .NEXT_BYTE:
        ld.b 0x0000[r6], r9
        st.b r9, 0x0000[r7]
        add 1, r6
        add 2, r7
        add -1, r8
        bne .NEXT_BYTE
    ?pop r8, r9
    jmp [lp]

COPY_FROM_SRAM: ; r6 source, r7 dest, r8 length
    ?push r8, r9
    .NEXT_BYTE:
        ld.b 0x0000[r6], r9
        st.b r9, 0x0000[r7]
        add 2, r6
        add 1, r7
        add -1, r8
        bne .NEXT_BYTE
    ?pop r8, r9
    jmp [lp]

ERASE_CHECK:
    ?push r7, r8, lp
    movea 0x8430, r0, r1
    andi 0xFFFF, r1, r1
    .CHECK_AGAIN:
        movhi 0x500, r0, r8
        movea 0x535E, r8, r8
        in.h 0x0000[r8], r7
        and r6, r7
        be .CHECK_AGAIN
    mov r7, r6
    .WAIT_FOR_RELEASE:
        in.h 0x0000[r8], r7
        cmp r1, r7
        bne .NO_ERASE
            movhi 0x600, r0, r1
            st.w r0, 0x0000[r1]
            jr SOFT_RESET
        .NO_ERASE:
        and r7, r7
        bne .WAIT_FOR_RELEASE
    ?pop r7, r8, lp
    jmp [lp]

DEFAULT_NAME:
    st.w r6, 0x0000[r25]
    andi 0x30, r25, r7
    movhi 0x600, r7, r7
    st.b r6, 0x0000[r7]
    shr 8, r6
    st.b r6, 0x0002[r7]
    shr 8, r6
    st.b r6, 0x0004[r7]
    shr 8, r6
    st.b r6, 0x0006[r7]
    jr DEFAULT_NAME_RETURN

ENTER_NAME:
    st.w r6, -0x7FEC[gp]    ; player 1
    st.w r7, -0x7FD8[gp]    ; player 2
    ?push r1
    movhi 0x600, r0, r1
    st.b r6, SRAM_NAME1[r1]
    shr 8, r6
    st.b r6, SRAM_NAME1+2[r1]
    shr 8, r6
    st.b r6, SRAM_NAME1+4[r1]
    shr 8, r6
    st.b r6, SRAM_NAME1+6[r1]
    st.b r7, SRAM_NAME2[r1]
    shr 8, r7
    st.b r7, SRAM_NAME2+2[r1]
    shr 8, r7
    st.b r7, SRAM_NAME2+4[r1]
    shr 8, r7
    st.b r7, SRAM_NAME2+6[r1]
    ?pop r1
    jr ENTER_NAME_RETURN

SELECT_HESTER:
    ?push r7
    andi 0x30, r25, r7
    movhi 0x600, r7, r7
    st.b r6, 0x0010[r25]
    st.b r6, 0x000A[r7]
    ?pop r7
    jr SELECT_NESTER_RETURN

SELECT_NESTER:
    ?push r6
    andi 0x30, r25, r6
    movhi 0x600, r6, r6
    st.b r0, 0x0010[r25]
    st.b r0, 0x000A[r6]
    ?pop r6
    jr SELECT_NESTER_RETURN

SELECT_BALL:
    ?push r6
    andi 0x30, r25, r6
    movhi 0x600, r6, r6
    st.b r10, 0x0004[r25]
    st.b r10, 0x0008[r6]
    ?pop r6
    jr SELECT_BALL_RETURN

UPDATE_SCORES:
    out.w r7, 0x0000[r11]   ; restored
    ?push r8, lp
    ?mov RAM_SCORES, r6
    ?mov SRAM_SCORES, r7
    movea 0x40, r0, r8
    jal COPY_TO_SRAM
    ?pop r8, lp
    jr UPDATE_SCORES_RETURN

!ORG 0xFFFFFFF0
    SOFT_RESET: