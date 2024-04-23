!CONST SKIP_INTRO, 0
!CONST INVINCIBLE, 0

!IF SKIP_INTRO
!ORG 0x0700B33E
!SEEK 0x0B33E
    movea 0x14, r0, r14
!ENDIF

!IF INVINCIBLE
; No damage for player
!SEEK 0x0F11C
    mov r0, r0
; No damage for drone
!SEEK 0x0F14A
    mov r0, r0
; No weapon downgrades
!SEEK 0x16D7C
    mov r0, r0
; No collision damage
!SEEK 0x1878E
    mov r0, r0
!ENDIF

!CONST RAM_SCORE, -0x610C
!CONST RAM_COUNTER, -0x6108
!CONST RAM_TIME, -0x60D8
!CONST RAM_DIFFICULTY, -0x60C2
!CONST RAM_CONTROLS, 0xC020
!CONST DEF_BRIGHT, 0xDC0C

; Check and (if necessary) init SRAM; load in brightness and scores
!ORG 0x070016D2
!SEEK 0x016D2
    jal CHECK_SRAM              ; jal 0701BF0C, brightness nuller
    ?db 0x00, 0x00, 0x00, 0x00  ; jal 0701BF1E, high score nuller

; Load the difficulty and control settings
!ORG 0x07007966
!SEEK 0x07966
    jr LOAD_SETTINGS            ; st.b r0, RAM_DIFFICULTY[gp]
    jal SET_RIGHTY              ; these both ...
    movea RAM_CONTROLS, gp, r11 ; ... get skipped
        LOAD_SETTINGS_RETURN:
            st.b r7, 0x0018[r11]
    !ORG 0x07007842
        SET_RIGHTY:
    !ORG 0x070078D0
        SET_LEFTY:

; Save controls selected on the Config screen
!ORG 0x0700863A
!SEEK 0x0863A
    jr SAVE_HAND                ; st.b r12, 0x0018[r11]
        SAVE_HAND_RETURN:

; Save difficulty selected on the Config screen
!ORG 0x07008A50
!SEEK 0x08A50
    cmp 3, r10
        bge INVALID_DIFFICULTY
        br SAVE_DIFFICULTY
    INVALID_DIFFICULTY:
        mov 2, r10
    SAVE_DIFFICULTY:
        movhi 0x600, r0, r6
        st.b r10, 0x0042[r6]
        st.b r10, RAM_DIFFICULTY[gp]
            br DIFFICULTY_SAVED
    !ORG 0x07008A72
        DIFFICULTY_SAVED:

; Write debug flag to protect saved high scores when in use
!ORG 0x0700B5B0
!SEEK 0x0B5B0
    jr WRITE_DEBUG_FLAG         ; jr SET_DEBUG_SCENE
    !ORG 0x0700B776
        SET_DEBUG_SCENE:

; Update high score/best time
!ORG 0x0700BC6E
!SEEK 0x0BC6E
; Setting up our read/write offsets based on current difficulty
    ld.b -0x5001[gp], r10       ; debug mode
    cmp 0, r10
        bne END_SCORE_UPDATES
    ld.b RAM_DIFFICULTY[gp], r10
    cmp 3, r10                  ; if beyond valid range, branch out
        bge END_SCORE_UPDATES
    shl 3, r10
    movhi 0x600, r10, r16       ; save RAM, offset by difficulty
    mov gp, r17
    add r10, r17

; Check and write new score
    ld.w RAM_SCORE[gp], r14     ; current score
    ld.w -0x7FFC[r17], r15      ; best score, offset by difficulty
    cmp r15, r14
        ble END_SCORE_UPDATES
    st.w r14, -0x7FFC[r17]
    st.b r14, 0x0010[r16]
    shr 8, r14
    st.b r14, 0x0012[r16]
    shr 8, r14
    st.b r14, 0x0014[r16]
    shr 8, r14
    st.b r14, 0x0016[r16]

; Check and write new time
    ld.w RAM_TIME[gp], r14      ; current time
    cmp 0, r14
        be END_SCORE_UPDATES
    ld.w -0x7FF0[r17], r15      ; best time, offset by difficulty
    cmp r15, r14
        bge END_SCORE_UPDATES
    st.w r14, -0x7FF0[r17]
    st.b r14, 0x0028[r16]
    shr 8, r14
    st.b r14, 0x002A[r16]
    shr 8, r14
    st.b r14, 0x002C[r16]
    shr 8, r14
    st.b r14, 0x002E[r16]
        br END_SCORE_UPDATES
    !ORG 0x0700BD24
        END_SCORE_UPDATES:

; Erase SRAM when L + R + Left Down + Right Down pressed on title screen
!ORG 0x0701C842
!SEEK 0x1C842
    jr ERASE_SRAM               ; ld.w RAM_COUNTER[gp], r12
        ERASE_SRAM_RETURN:
    !ORG 0x07FFFFF0
        SOFT_RESET:

; Save brightness when increasing
!ORG 0x0701CF7A
!SEEK 0x1CF7A
    jr BRIGHTNESS_UP            ; ld.b 0x0000[r13], r17
    !ORG 0x0701CF8A
        BRIGHTNESS_UP_RETURN:

; Save brightness when decreasing
!ORG 0x0701CFF8
!SEEK 0x1CFF8
    jr BRIGHTNESS_DOWN          ; ld.b 0x0000[r17], r11
    !ORG 0x0701D008
        BRIGHTNESS_DOWN_RETURN:

!ORG 0x07021294             ; 0x07021294 looks good for Japan
!SEEK 0x21294
CHECKWORD:
    ?STRING "VFSV"

CHECK_SRAM:
    movhi 0x600, r0, r6
    ?mov CHECKWORD, r7
        NEXT_CHECKBYTE:
            andi 0x8, r6, r0
                bne LOAD_BRIGHT_SCORES
            ld.b 0x0000[r6], r8
            ld.b 0x0000[r7], r9
            add 2, r6
            add 1, r7
            cmp r8, r9
                be NEXT_CHECKBYTE
    CLEAR_SRAM:
        movhi 0x600, r0, r6
        movea 0x4000, r0, r7
            NEXT_SRAM:
                st.w r0, 0x0000[r6]         ; this counts as initing high scores
                add 4, r6
                add -1, r7
                    bne NEXT_SRAM
            movhi 0x600, r0, r6
            ?mov CHECKWORD, r7
            ld.w 0x0000[r7], r7
                WRITE_CHECKWORD:
                    st.b r7, 0x0000[r6]
                    shr 8, r7
                    add 2, r6
                    andi 0x8, r6, r0
                        be WRITE_CHECKWORD
            movhi 0x704, r0, r7         ; initializing brightness
            movea DEF_BRIGHT, r7, r7
            ld.w 0x0000[r7], r7
            st.b r7, 0x0000[r6]         ; don't forget r6 is +8
            shr 8, r7
            st.b r7, 0x0002[r6]
            shr 8, r7
            st.b r7, 0x0004[r6]
            shr 8, r7
            st.b r7, 0x0006[r6]
            movhi 0x113, r0, r7         ; initializing best times
            movea 0xA87F, r7, r7        ; once for each difficulty
            st.b r7, 0x0020[r6]
            st.b r7, 0x0028[r6]
            st.b r7, 0x0030[r6]
            shr 8, r7
            st.b r7, 0x0022[r6]
            st.b r7, 0x002A[r6]
            st.b r7, 0x0032[r6]
            shr 8, r7
            st.b r7, 0x0024[r6]
            st.b r7, 0x002C[r6]
            st.b r7, 0x0034[r6]
            shr 8, r7
            st.b r7, 0x0026[r6]
            st.b r7, 0x002E[r6]
            st.b r7, 0x0036[r6]
            mov 1, r7                   ; usa difficulty defaults to 0 (easy)
            st.b r7, 0x003A[r6]         ; japan defaults to 1 (normal)
    LOAD_BRIGHT_SCORES:
        movhi 0x600, r0, r6         ; brightness
        ld.b 0x0008[r6], r7
        st.b r7, -0x8000[gp]
        ld.b 0x000A[r6], r7
        st.b r7, -0x7FFF[gp]
        ld.b 0x000C[r6], r7
        st.b r7, -0x7FFE[gp]
        ld.b 0x000E[r6], r7
        st.b r7, -0x7FFD[gp]
        movhi 0x600, r0, r6         ; high scores
        movea 0x0018, r0, r8
            NEXT_SCORE_BYTE:
                ld.b 0x0010[r6], r7
                st.b r7, -0x7FFC[gp]
                add 1, gp
                add 2, r6
                add -1, r8
                    bne NEXT_SCORE_BYTE
                    jmp [lp]

LOAD_SETTINGS:
    movhi 0x600, r0, r6
    ld.b 0x0042[r6], r7             ; difficulty
    st.b r7, RAM_DIFFICULTY[gp]
    movea RAM_CONTROLS, gp, r11
    ld.b 0x0040[r6], r7
    cmp 1, r7
    be START_LEFTY
        jal SET_RIGHTY
            jr LOAD_SETTINGS_RETURN
    START_LEFTY:
        jal SET_LEFTY
            jr LOAD_SETTINGS_RETURN

SAVE_HAND:
    st.b r12, 0x0018[r11]
    movhi 0x600, r0, r10
    st.b r12, 0x0040[r10]
        jr SAVE_HAND_RETURN

WRITE_DEBUG_FLAG:
    mov 1, r6
    st.b r6, -0x5001[gp]
        jr SET_DEBUG_SCENE

ERASE_SRAM:
    st.b r0, -0x5001[gp]                ; clear debug flag
    ld.h 0x0000[r14], r9
    movea 0x8432, r0, r12
    cmp r9, r12
        bne NO_ERASE
    movhi 0x600, r0, r9
    st.w r0, 0x0000[r9]
        jal SOFT_RESET
    NO_ERASE:
        ld.w RAM_COUNTER[gp], r12       ; restored from original
            jr ERASE_SRAM_RETURN

BRIGHTNESS_UP:
    movhi 0x600, r0, r6
        BRIGHTNESS_UP_NEXT:
            ld.b 0x0000[r13], r17
            add 1, r13
            st.b r17, 0x0008[r6]
            add 2, r6
            st.b r17, 0x0000[r15]
            add 1, r15
            add -1, r16
                bne BRIGHTNESS_UP_NEXT
        jr BRIGHTNESS_UP_RETURN

BRIGHTNESS_DOWN:            ; about to use r6 anyway
    movhi 0x600, r0, r6
        BRIGHTNESS_DOWN_NEXT:
            ld.b 0x0000[r17], r11
            add 1, r17
            st.b r11, 0x0008[r6]
            add 2, r6
            st.b r11, 0x0000[r19]
            add 1, r19
            add -1, r10
                bne BRIGHTNESS_DOWN_NEXT
        jr BRIGHTNESS_DOWN_RETURN