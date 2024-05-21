!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
!SEEK 0x02282
    ?dw 0, 0, 0
!ENDIF

; Restore pause menu debug cheats
!ORG 0x07002532
!SEEK 0x02532
    jr DEBUG_CHECK      ; jal f_0703D8BA
    DEBUG_CHECK_RETURN:

; Restore frame advance mode
!ORG 0x070025A6
!SEEK 0x025A6
    jr FRAME_ADVANCE    ; jal CHECK_INPUT
    FRAME_ADVANCE_RETURN:
    !ORG 0x070025B0
    ADVANCE_COMPLETE:

; Restore title screen/score attack/pocket debug cheats
!ORG 0x070226FC
!SEEK 0x226FC
    br SKIP_PROTECTION_1
    !ORG 0x0702270A
    SKIP_PROTECTION_1:
!ORG 0x07022720
!SEEK 0x22720
    br SKIP_PROTECTION_2
    !ORG 0x0702272C
    SKIP_PROTECTION_2:

; All the functions called by the debug code
!ORG 0x070004DE
f_070004DE:
!ORG 0x07000518
f_07000518:
!ORG 0x0700060E
f_0700060E:
!ORG 0x070007F4
CHECK_INPUT:
!ORG 0x07000FF6
ROUND_SELECT:
!ORG 0x070012AA
SOUND_TEST:
!ORG 0x07001D48
BUTTON_CODES:
!ORG 0x07001FD2
f_07001FD2:
!ORG 0x07002E2C
PRINT_TEXT:
!ORG 0x07006746
f_07006746:
!ORG 0x0700859C
f_0700859C:
!ORG 0x0700873C
f_0700873C:
!ORG 0x07017A60
f_07017A60:
!ORG 0x0701CA8C
f_0701CA8C:
!ORG 0x0703D7F8
PLAY_SFX:
!ORG 0x0703D8BA
f_0703D8BA:
!ORG 0x0703D8C6
f_0703D8C6:


!ORG 0x07040828
!SEEK 0x40828
DEBUG_SWITCH:
?dw DEBUG_CHECK.ROUND_SELECT
?dw DEBUG_CHECK.SOUND_TEST
?dw DEBUG_CHECK.AUTO_MOVE
?dw DEBUG_CHECK.NISHUME
?dw DEBUG_CHECK.RANK_CHANGE

DEBUG_CHECK:
    jal f_0703D8BA
    andi 0x10, r20, r10
    bne .HOLDING_R
    jr .NOT_HOLDING_R
    .HOLDING_R:
        mov r20, r6
        jal BUTTON_CODES
        addi 0xFFFF, r10, r30
        cmp 4, r30
        bnh .VALID_SWITCH
        jr DEBUG_CHECK_RETURN
        .VALID_SWITCH:
            shl 2, r30
            movhi 0x704, r30, r1
            ld.w 0x828[r1], r30
            jmp [r30]
            jr DEBUG_CHECK_RETURN

            .ROUND_SELECT:
                st.h r0, -0x7FE2[gp]
                mov r0, r8
                mov r0, r7
                movea 0x11, r0, r6
                jal PLAY_SFX
                mov r0, r8
                mov r0, r7
                movea 0x35, r0, r6
                jal PLAY_SFX
                mov r0, r6
                jal f_0700060E
                jal f_07000518
                st.h r0, -0x7FD4[gp]
                ld.h -0x7FFC[gp], r10
                movhi 0x500, r0, r1
                st.h r10, 0x20CC[r1]
                jal ROUND_SELECT
                st.h r10, -0x7FFC[gp]
                jal f_07001FD2
                jal f_070004DE
                jal f_0703D8C6
                jr DEBUG_CHECK_RETURN

            .SOUND_TEST:
                jal f_0703D8C6
                st.h r0, -0x7FE2[gp]
                mov r0, r8
                mov r0, r7
                movea 0x11, r0, r6
                jal PLAY_SFX
                mov r0, r8
                mov r0, r7
                movea 0x35, r0, r6
                jal PLAY_SFX
                mov r0, r6
                jal f_0700060E
                jal f_070004DE
                st.h r0, -0x7FD4[gp]
                ld.h -0x7FFC[gp], r10
                movhi 0x500, r0, r1
                st.h r10, 0x20CC[r1]
                jal SOUND_TEST
                jal f_07001FD2
                mov -1, r8
                mov r0, r7
                movhi 0x704, r0, r1
                movea 0x15D, r1, r6
                jal PRINT_TEXT
                jal f_070004DE
                jr DEBUG_CHECK_RETURN

            .AUTO_MOVE:
                mov 15, r8
                mov 15, r7
                movea 0x12, r0, r6
                jal PLAY_SFX
                mov 1, r10
                ld.h -0x7FCE[gp], r11
                sub r11, r10
                st.h r10, -0x7FCE[gp]
                jr DEBUG_CHECK_RETURN

            .NISHUME:
                mov 15, r8
                mov 15, r7
                movea 0x23, r0, r6
                jal PLAY_SFX
                mov 1, r10
                ld.h -0x7FF8[gp], r11
                sub r11, r10
                st.h r10, -0x7FF8[gp]
                jr DEBUG_CHECK_RETURN

            .RANK_CHANGE:
                mov 15, r8
                mov 15, r7
                mov r0, r6
                jal PLAY_SFX
                ld.h -0x7FFA[gp], r10
                addi 0x01, r10, r11
                mov r11, r10
                shl 1, r10
                sar 1, r10
                st.h r10, -0x7FFA[gp]
                mov r10, r11
                mov 3, r12
                div r12, r11
                mov r30, r11
                st.h r11, -0x7FFA[gp]
                jr DEBUG_CHECK_RETURN

            .NOT_HOLDING_R:
                st.h r22, -0x76AC[gp]
                st.h r22, -0x76AE[gp]
                st.h r22, -0x76B0[gp]
                st.h r22, -0x76B2[gp]
                st.h r22, -0x76B4[gp]
                jr DEBUG_CHECK_RETURN

FRAME_ADVANCE:
    movhi 0x08, r0, r10
    and r20, r10
    bne .PRESSED_B
    jr .GETINPUT
    .PRESSED_B:
        andi 0x10, r20, r10
        bne .PRESSED_R
        jr .GETINPUT
    .PRESSED_R:
        andi 0x20, r20, r10
        bne .PRESSED_L
        jr .GETINPUT
    .PRESSED_L:
        jal f_0700859C
        jal CHECK_INPUT
        mov r10, r20
        mov r20, r6
        jal f_07006746
        jal f_0700873C
        jal f_07017A60
        ld.h -0x7FD4[gp], r10
        movhi 0x500, r0, r1
        st.h r10, 0x20CC[r1]
        jal f_0701CA8C
        ld.w -0x8000[gp], r10
        add 1, r10
        st.w r10, -0x8000[gp]
        jr ADVANCE_COMPLETE
    .GETINPUT:
        jal CHECK_INPUT
        jr FRAME_ADVANCE_RETURN