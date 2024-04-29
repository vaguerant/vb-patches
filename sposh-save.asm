!CONST SKIP_INTRO, 0
!CONST INVINCIBLE, 0
!CONST CPU_CANT_SCORE, 0
!CONST ONE_POINT_WINS, 0
!CONST ONE_HIT_KILLS, 0
!CONST CUSTOM_MENU, 1

!IF SKIP_INTRO
; Skip startup noise
!SEEK 0x01A98
    ?db 0x00, 0x00, 0x00, 0x00
; Skip printing manual text
!SEEK 0x24CA8
    ?db 0x00, 0x00, 0x00, 0x00
; Skip manual delay and button check on manual
!SEEK 0x24CB0
    ?db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
; Skip IPD and auto-pause
!SEEK 0x24CCC
    add 3, r10
!ENDIF

; Skip manual delay, not behind SKIP_INTRO!
!SEEK 0x24CB0
    ?db 0x00, 0x00, 0x00, 0x00

; I never disabled hit damage from boss attacks, only beans
!IF INVINCIBLE
!SEEK 0x0B20A
    mov r0, r0
!ENDIF

!IF CPU_CANT_SCORE
!SEEK 0x0D5F0
    mov r0, r0
!ENDIF

!IF ONE_POINT_WINS
!SEEK 0x2864E
    mov 2, r6
    movhi 0x500, r0, r1
    st.h r0, 0x0046[r1]
    movhi 0x500, r0, r1
    st.h r6, 0x0044[r1]
!ENDIF

!IF ONE_HIT_KILLS
!SEEK 0x247BA               ; snaku
    mov 1, r9
!SEEK 0x248CE               ; batto
    mov r0, r0
!SEEK 0x249FA               ; monki
    mov r0, r0
!SEEK 0x24AAC               ; lyones
    movea 0x1, r0, r9
!SEEK 0x3EB40               ; normal enemies
    ?db 0x01, 0x00, 0x01, 0x00, 0x01, 0x00, 0x01, 0x00
!ENDIF

!CONST CURRENT_AREA, 0x000A ; 0500005A in RAM
!CONST STAGE_PATH,   0x000C ; 0500005C in RAM
!CONST AREAS_BEATEN, 0x000E ; 0500005E in RAM
!CONST MAP_POSITION, 0x000C ; 05000066 in RAM

!CONST SRAM_STATS,  0x0010
!CONST SRAM_HEALTH, 0x0028
!CONST SRAM_CHARGE, 0x002A

!CONST SRAM_SCORE, 0x0030
!CONST SRAM_SCORE_AREA, SRAM_SCORE + 0x50       ; 0x0080
!CONST SRAM_SCORE_LEVEL, SRAM_SCORE_AREA + 0x14 ; 0x0094
!CONST SRAM_INITIALS, SRAM_SCORE_LEVEL + 0x14   ; 0x00A8

!CONST MAX_RETRIES, SRAM_INITIALS + 0x5A        ; 0x0102
!CONST BRIGHTNESS, MAX_RETRIES + 2              ; 0x0104
!CONST DIFFICULTY, BRIGHTNESS + 0x20            ; 0x0124
!CONST BACKDROP, DIFFICULTY + 2                 ; 0x0126
!CONST BGM, BACKDROP + 2                        ; 0x0128
!CONST MATCH, BGM + 2                           ; 0x012A

; Check/initialize SRAM
!ORG 0x07001966
!SEEK 0x01966
    jal CHECK_SRAM
    !ORG 0x0701C03C
    STARTUP:

; Load settings
!ORG 0x07001970
!SEEK 0x01970
    movhi 0x600, r0, r6
    ld.b DIFFICULTY[r6], r10
    st.h r10, 0x0074[r1]
    ld.b BACKDROP[r6], r10
    st.h r10, 0x0076[r1]
    ld.b BGM[r6], r10
    st.h r10, 0x0078[r1]
    ld.b MAX_RETRIES[r6], r10
    st.h r10, 0x0052[r1]
    ld.b BRIGHTNESS[r6], r10
    st.h r10, 0x0054[r1]
    ld.b MATCH[r6], r10
    st.h r10, 0x007A[r1]
    mov r0, r0

; Read high scores from SRAM instead of ROM
!ORG 0x0701C044
!SEEK 0x1C044
    shl 3, r11
    shl 1, r10
    movhi 0x600, r11, r1
    jr LOAD_SCORES          ; ld.w -0x21E4[r1], r13
    LOAD_SCORES_RETURN:

; Read high score areas from SRAM instead of ROM
!ORG 0x0701C058
!SEEK 0x1C058
    movhi 0x600, r10, r1
    ld.b SRAM_SCORE_AREA[r1], r13   ;jr LOAD_AREAS           ; ld.h -0x21BC[r1], r13
    LOAD_AREAS_RETURN:

; Load high score *levels* from SRAM instead of ROM
!ORG 0x0701C068
!SEEK 0x1C068
    movhi 0x600, r10, r1            ; movhi 0x704, r10, r1
    ld.b SRAM_SCORE_LEVEL[r1], r13  ; ld.b -0x21A8[r1], r13

; Load high score initials from SRAM instead of ROM
!ORG 0x0701C078
!SEEK 0x1C078
    jr LOAD_INITIALS
    !ORG 0x0701C0AC
    LOAD_INITIALS_RETURN:

; Move old scores down when beaten
!ORG 0x0701C1A2
!SEEK 0x1C1A2
    jr MOVE_SCORES          ; st.w r16, 0x00A8[r1]
    MOVE_SCORES_RETURN:

; Move old areas down, also bugfix moving levels down
!ORG 0x0701C1BC
!SEEK 0x1C1BC
    jr MOVE_AREAS           ; ld.h 0x00D0[r1], r17
    !ORG 0x0701C1EA
    MOVE_AREAS_RETURN:

; Move old initials down
!ORG 0x0701C1DC
!SEEK 0x1C1DC
    jr MOVE_INITIALS        ; st.b r16, 0x00F8[r1]
    MOVE_INITIALS_RETURN:

; Save new high score
!ORG 0x0701C218
!SEEK 0x1C218
    jr SAVE_SCORE           ; st.w r12, 0x00A8[r1]
    SAVE_SCORE_RETURN:

; Save new area
!ORG 0x0701C22E
!SEEK 0x1C22E
    jr SAVE_SCORE_AREA      ; st.h r12, 0x00D0[r1]
    SAVE_SCORE_AREA_RETURN:

; Save new level
!ORG 0x0701C244
!SEEK 0x1C244
    jr SAVE_SCORE_LEVEL     ; st.h r12, 0x00E4[r1]
    SAVE_SCORE_LEVEL_RETURN:

; Blank initials until replaced
!ORG 0x0701C254
!SEEK 0x1C254
    jr BLANK_INITIALS
    !ORG 0x0701C280
    BLANK_INITIALS_RETURN:

; Write out new initials
!ORG 0x0701C520
!SEEK 0x1C520
    jr SAVE_INITIALS        ; st.b r11, 0x00F8[r1]
    SAVE_INITIALS_RETURN:

; Soft reset
!ORG 0x07024C32
    SOFT_RESET:

; Always go via start menu
!ORG 0x0702516E
!SEEK 0x2516E
    jr ERASE_CHECK           ; ld.h 0x0016[r1], r6
    ERASE_CHECK_RETURN:
    andi 0x1000, r6, r10
    bne START_MENU
    !ORG 0x07025194
    START_MENU:

; Custom main menu with "CONTINUE" option added
!IF CUSTOM_MENU
!ORG 0x07025226
!SEEK 0x25226
    ?mov CUSTOM_MENU_POINTER, r10

; Raise the title screen print by 2 tiles
!SEEK 0x25236
    movea 0x10, r0, r7 ; 0x12

; Send option 1 off to custom code
!ORG 0x07025244
!SEEK 0x25244
    jr CONTINUE_GAME
    mov r0, r0
    CONTINUE_GAME_RETURN:

; Have option 2 go to Training
!SEEK 0x2524A
    cmp 2, r10

; Have option 3 go to Config
!SEEK 0x2526C
    cmp 3, r10

; Stuff for Continue to jump to depending on what's in SRAM
!ORG 0x07025278
    GAME_START:
!ORG 0x07025314
    PROCEED_FROM_MENU:

; The game hides the menu text when pressing B from the main menu
; The main menu now has 4 entries instead of 3, so needs extra cleanup
!ORG 0x070252BE
!SEEK 0x252BE
    jr CLEAR_UP_TITLE
    CLEAR_UP_RETURN:

; Update the path in SRAM
!ORG 0x07025DD4
!SEEK 0x25DD4
    jr SAVE_PATH
    SAVE_PATH_RETURN:

; Copy all progress and player stats to SRAM
!ORG 0x07025D88
!SEEK 0x25D88
    jr SAVE_GAME
    SAVE_GAME_RETURN:
!ENDIF

; Save difficulty
!ORG 0x0702548A
!SEEK 0x2548A
    jr DIFFICULTY_UP
    DIFFICULTY_UP_RETURN:
!ORG 0x0702556E
!SEEK 0x2556E
    jr DIFFICULTY_DOWN
    DIFFICULTY_DOWN_RETURN:

; Save backdrop
!ORG 0x070254A8
!SEEK 0x254A8
    jr BACK_UP
    BACK_UP_RETURN:
!ORG 0x0702558C
!SEEK 0x2558C
    jr BACK_DOWN    ; hacker discovers one weird trick, tom petty hates him
    BACK_DOWN_RETURN:

; Save BGM setting
!ORG 0x070254C6
!SEEK 0x254C6
    jr BGM_ON
    BGM_ON_RETURN:
!ORG 0x070255AA
!SEEK 0x255AA
    jr BGM_OFF
    BGM_OFF_RETURN:

; Save match point
!ORG 0x070254E4
!SEEK 0x254E4
    jr MATCH_POINT_UP
    MATCH_POINT_UP_RETURN:
!ORG 0x70255C8
!SEEK 0x255C8
    jr MATCH_POINT_DOWN
    MATCH_POINT_DOWN_RETURN:

; Save max continues
!ORG 0x07025502
!SEEK 0x25502
    jr MAX_CONTINUES_UP
    MAX_CONTINUES_UP_RETURN:
!ORG 0x070255E6
!SEEK 0x255E6
    jr MAX_CONTINUES_DOWN
    MAX_CONTINUES_DOWN_RETURN:

; Save brightness
!ORG 0x07025520
!SEEK 0x25520
    jr BRIGHTNESS_UP
    BRIGHTNESS_UP_RETURN:
!ORG 0x07025604
!SEEK 0x25604
    jr BRIGHTNESS_DOWN
    BRIGHTNESS_DOWN_RETURN:

!ORG 0x07029B18
!SEEK 0x29B18
CHECKWORD:
    ?STRING "SSSV"

CHECK_SRAM:
    ?push lp
    ?mov CHECKWORD, r9
    movhi 0x600, r0, r6
        NEXT_CHECKBYTE:
            andi 8, r6, r0          ; if CHECKWORD is valid, skip SRAM init
            bne CHECKWORD_OK
                ld.b 0x0000[r9], r7
                ld.b 0x0000[r6], r8
                add 1, r9
                add 2, r6
                cmp r7, r8
                be NEXT_CHECKBYTE
    jal CLEAR_SRAM
    CHECKWORD_OK:
        jal STARTUP             ; restored from original
        ?pop lp
        jmp [lp]

CLEAR_SRAM:
    ?mov CHECKWORD, r9
    ld.w 0x0000[r9], r9
    movhi 0x600, r0, r6
    movea 0x4000, r0, r7
        NEXT_SRAM:
            st.w r0, 0x0000[r6]
            add 4, r6
            add -1, r7
                bne NEXT_SRAM
    ?mov CHECKWORD, r9
    ld.w 0x0000[r9], r9
    movhi 0x600, r0, r6
    WRITE_CHECKWORD:
        st.b r9, 0x0000[r6]
        shr 8, r9
        add 2, r6
        andi 0x8, r6, r0
            be WRITE_CHECKWORD
    add -8, r6              ; reset save offset
    ?mov ROM_SCORES, r9
    movea 0x0028, r0, r8
        .NEXT_SCORE_BYTE:
            ld.b 0x0000[r9], r7
            st.b r7, SRAM_SCORE[r6]
            add 1, r9
            add 2, r6
            add -1, r8
                bne .NEXT_SCORE_BYTE
    movea 0x0028, r0, r8
        .NEXT_AREA_WORD:        ; these are all "halfwords" with only one byte used
            ld.w 0x0000[r9], r7
            st.w r7, SRAM_SCORE[r6]
            add 4, r9
            add 4, r6
            add -4, r8
                bne .NEXT_AREA_WORD
    movea 0x0028, r0, r8
        .NEXT_INITIAL_BYTE:
            ld.b 0x0000[r9], r7
            st.b r7, SRAM_SCORE[r6]
            add 1, r9
            add 2, r6
            add -1, r8
                bne .NEXT_INITIAL_BYTE
    movhi 0x600, r0, r6
    mov 1, r10
    st.h r10, DIFFICULTY[r6]
    mov 0, r10
    st.h r10, BACKDROP[r6]
    mov 1, r10
    st.h r10, BGM[r6]
    mov 3, r10
    st.h r10, MAX_RETRIES[r6]
    mov 1, r10
    st.h r10, BRIGHTNESS[r6]
    mov 3, r10
    st.h r10, MATCH[r6]
    jmp [lp]

LOAD_SCORES:
    ?push r6
    ld.b SRAM_SCORE+6[r1], r13
    shl 24, r13
    ld.b SRAM_SCORE+4[r1], r6
    andi 0xFF, r6, r6
    shl 16, r6
    or r6, r13
    ld.b SRAM_SCORE+2[r1], r6
    andi 0xFF, r6, r6
    shl 8, r6
    or r6, r13
    ld.b SRAM_SCORE[r1], r6
    andi 0xFF, r6, r6
    or r6, r13
    shr 1, r11              ; restore this back to normal
    ?pop r6
    jr LOAD_SCORES_RETURN

LOAD_INITIALS:
    mov r11, r13
    shl 1, r11
    mov 0, r10
    movhi 0x600, r0, r1
    movea SRAM_INITIALS, r1, r1
    add r1, r11
    br .INITIAL_INDEX_CHECK
        .NEXT_INITIAL:
            mov r13, r14
            add r10, r14
            mov r11, r15
            shl 1, r10
            add r10, r15
            shr 1, r10
            ld.b 0x0000[r15], r15   ; SRAM initials
            movhi 0x500, r14, r1
            st.b r15, 0x00F8[r1]    ; RAM initials
            addi 0x1, r10, r14
            mov r14, r10
            shl 16, r10
            sar 16, r10
    .INITIAL_INDEX_CHECK:
        cmp 4, r10              ; have we done 3 initials yet?
    blt .NEXT_INITIAL
    jr LOAD_INITIALS_RETURN

MOVE_SCORES:
    st.w r16, 0x00A8[r1]    ; restored from original
    shl 1, r13
    movhi 0x600, r13, r1
    shr 1, r13
    st.b r16, SRAM_SCORE[r1]
    shr 8, r16
    st.b r16, SRAM_SCORE+2[r1]
    shr 8, r16
    st.b r16, SRAM_SCORE+4[r1]
    shr 8, r16
    st.b r16, SRAM_SCORE+6[r1]
    jr MOVE_SCORES_RETURN

MOVE_AREAS:
    mov r17, r18            ; need this for level shifting later
    ld.h 0x00D0[r1], r17    ; previous area
    movhi 0x500, r16, r1
    st.h r17, 0x00D0[r1]    ; write to next slot
    movhi 0x600, r16, r1
    st.b r17, SRAM_SCORE_AREA[r1]
; this part is a bugfix for the original game. they forgot to shift
; levels down the list when updating the high score table. whoops.
    movhi 0x500, r18, r1
    ld.h 0x00E4[r1], r17    ; level
    movhi 0x500, r16, r1
    st.h r17, 0x00E4[r1]    ; ditto
    movhi 0x600, r16, r1
    st.b r17, SRAM_SCORE_LEVEL[r1]
    jr MOVE_AREAS_RETURN

MOVE_INITIALS:
    st.b r16, 0x00F8[r1]    ; restored from original
    shl 1, r14
    movhi 0x600, r14, r1
    shr 1, r14
    st.b r16, SRAM_INITIALS[r1]
    jr MOVE_INITIALS_RETURN

SAVE_SCORE:
    st.w r12, 0x00A8[r1]    ; restored from original
    shl 1, r11
    movhi 0x600, r11, r1
    shr 1, r11
    st.b r12, SRAM_SCORE[r1]
    shr 8, r12
    st.b r12, SRAM_SCORE+2[r1]
    shr 8, r12
    st.b r12, SRAM_SCORE+4[r1]
    shr 8, r12
    st.b r12, SRAM_SCORE+6[r1]
    jr SAVE_SCORE_RETURN

SAVE_SCORE_AREA:
    st.h r12, 0x00D0[r1]    ; restored from original
    movhi 0x600, r11, r1
    st.b r12, SRAM_SCORE_AREA[r1]
    jr SAVE_SCORE_AREA_RETURN

SAVE_SCORE_LEVEL:
    st.h r12, 0x00E4[r1]    ; restored from original
    movhi 0x600, r11, r1
    st.b r12, SRAM_SCORE_LEVEL[r1]
    jr SAVE_SCORE_LEVEL_RETURN

BLANK_INITIALS:
    ld.h 0x0000[r10], r13   ; index into score table
    shl 3, r13              ; for SRAM purposes
    movhi 0x600, r0, r14
    movea SRAM_INITIALS, r14, r14
    add r13, r14
    shr 1, r13
    add r11, r13
    st.b r12, 0x0000[r14]
    st.b r12, 0x0000[r13]
    add 2, r14
    add 1, r13
    st.b r12, 0x0000[r14]
    st.b r12, 0x0000[r13]
    add 2, r14
    add 1, r13
    st.b r12, 0x0000[r14]
    st.b r12, 0x0000[r13]
    jr BLANK_INITIALS_RETURN

SAVE_INITIALS:
    st.b r11, 0x00F8[r1]    ; restored from original
    shl 1, r10
    movhi 0x600, r10, r1
    shr 1, r10
    st.b r11, SRAM_INITIALS[r1]
    jr SAVE_INITIALS_RETURN

ERASE_CHECK:             ; r10 is free
    ?push r7
    ld.h 0x0014[r1], r6
    movea 0x8432, r0, r7
    cmp r6, r7
    bne .NO_ERASE
    movhi 0x600, r0, r10
    st.w r0, 0x0000[r10]
    jr SOFT_RESET
    .NO_ERASE:
    ?pop r7
    ld.h 0x0016[r1], r6     ; restored from original
    jr ERASE_CHECK_RETURN

DIFFICULTY_UP:
    ?push r6
    st.h r10, 0x0074[r1]
    movhi 0x600, r0, r6
    st.b r10, DIFFICULTY[r6]
    ?pop r6
    jr DIFFICULTY_UP_RETURN

DIFFICULTY_DOWN:
    ?push r6
    st.h r10, 0x0074[r1]
    movhi 0x600, r0, r6
    st.b r10, DIFFICULTY[r6]
    ?pop r6
    jr DIFFICULTY_DOWN_RETURN

BACK_UP:
    ?push r6
    st.h r10, 0x0076[r1]
    movhi 0x600, r0, r6
    st.b r10, BACKDROP[r6]
    ?pop r6
    jr BACK_UP_RETURN

BACK_DOWN:
    ?push r6
    st.h r10, 0x0076[r1]
    movhi 0x600, r0, r6
    st.b r10, BACKDROP[r6]
    ?pop r6
    jr BACK_DOWN_RETURN

BGM_ON:
    ?push r6
    st.h r10, 0x0078[r1]
    movhi 0x600, r0, r6
    st.b r10, BGM[r6]
    ?pop r6
    jr BGM_ON_RETURN

BGM_OFF:
    ?push r6
    st.h r10, 0x0078[r1]
    movhi 0x600, r0, r6
    st.b r10, BGM[r6]
    ?pop r6
    jr BGM_OFF_RETURN

MATCH_POINT_UP:
    ?push r6
    st.h r10, 0x007A[r1]
    movhi 0x600, r0, r6
    st.b r10, MATCH[r6]
    ?pop r6
    jr MATCH_POINT_UP_RETURN

MATCH_POINT_DOWN:
    ?push r6
    st.h r10, 0x007A[r1]
    movhi 0x600, r0, r6
    st.b r10, MATCH[r6]
    ?pop r6
    jr MATCH_POINT_DOWN_RETURN

MAX_CONTINUES_UP:
    ?push r6
    st.h r10, 0x0052[r1]
    movhi 0x600, r0, r6
    st.b r10, MAX_RETRIES[r6]
    ?pop r6
    jr MAX_CONTINUES_UP_RETURN

MAX_CONTINUES_DOWN:
    ?push r6
    st.h r10, 0x0052[r1]
    movhi 0x600, r0, r6
    st.b r10, MAX_RETRIES[r6]
    ?pop r6
    jr MAX_CONTINUES_DOWN_RETURN

BRIGHTNESS_UP:              ; r6 is free for these
    st.h r10, 0x0054[r1]
    movhi 0x600, r0, r6
    st.b r10, BRIGHTNESS[r6]
    jr BRIGHTNESS_UP_RETURN

BRIGHTNESS_DOWN:
    st.h r10, 0x0054[r1]
    movhi 0x600, r0, r6
    st.b r10, BRIGHTNESS[r6]
    jr BRIGHTNESS_DOWN_RETURN

!IF CUSTOM_MENU
CONTINUE_GAME:
    jal TITLE_SCREEN_THING  ; never checked what this actually does
    mov r20, r10
    cmp 1, r10
    bne NOT_CONTINUE
    movhi 0x600, r0, r6
    ld.b AREAS_BEATEN[r6], r11
    cmp 1, r11
    bge .CONTINUE
    jr GAME_START
    .CONTINUE:
    mov 7, r10              ; stage select
    st.h r10, 0x0038[r1]
    jal RESET_STATS
    movhi 0x600, r0, r6
    ld.b CURRENT_AREA[r6],r10
    st.h r10, 0x005A[r1]
    ld.b STAGE_PATH[r6], r10
    st.h r10, 0x005C[r1]
    ld.b AREAS_BEATEN[r6], r10
    st.h r10, 0x005E[r1]
    mov 5, r10
    st.h r10, 0x0066[r1]    ; position within area
    ld.b SRAM_HEALTH[r6], r10
    st.b r10, 0x0132[r1]
    ld.b SRAM_CHARGE[r6], r10
    st.b r10, 0x0148[r1]
    ?push r9
    mov 0x0C, r9
    .NEXT_BYTE:
        ld.b SRAM_STATS[r6], r10
        st.b r10, 0x0160[r1]
        add 1, r1
        add 2, r6
        add -1, r9
        bne .NEXT_BYTE
    ?pop r9
    jal HIGHLIGHT_GRABBER
    jr PROCEED_FROM_MENU
    NOT_CONTINUE:
        jr CONTINUE_GAME_RETURN

CLEAR_UP_TITLE:
    st.h r10, 0x118A[r1]    ; restore from original
    movhi 0x703, r0, r1
    movea 0xFA2D, r1, r8
    movea 0x12, r0, r7
    movea 0x13, r0, r6
    jal PRINT_CLEAN
    jr CLEAR_UP_RETURN

SAVE_PATH:
    movhi 0x600, r0, r1
    st.b r10, STAGE_PATH[r1]
    movhi 0x500, r0, r1
    jr SAVE_PATH_RETURN

SAVE_GAME:              ; r6, r7, r8 and r9 are free
    st.h r10, 0x003A[r1]   ; restore from original, sets area select mode
    movhi 0x600, r0, r6
    ld.b 0x005A[r1], r7
    st.b r7, CURRENT_AREA[r6]
    ld.b 0x005C[r1], r7
    st.b r7, STAGE_PATH[r6]
    ld.b 0x005E[r1], r7
    st.b r7, AREAS_BEATEN[r6]
    ld.b 0x0132[r1], r7
    st.b r7, SRAM_HEALTH[r6]
    ld.b 0x0148[r1], r7
    st.b r7, SRAM_CHARGE[r6]
    mov r1, r8
    mov 0x0C, r9
    .NEXT_BYTE:
        ld.b 0x0160[r8], r7
        st.b r7, SRAM_STATS[r6]     ; speed and power
        add 2, r6
        add 1, r8
        add -1, r9
        bne .NEXT_BYTE
    jr SAVE_GAME_RETURN

; The address we pull into the main menu instead of the original
CUSTOM_MENU_POINTER:
    ?dw STR_GAMESTART
    ?dw STR_CONTINUE
    ?dw STR_TRAINING
    ?dw STR_CONFIG

!ORG 0x0701A962
    TITLE_SCREEN_THING:

!ORG 0x0701AD32
    PRINT_CLEAN:

!ORG 0x07027D76
    RESET_STATS:

!ORG 0x070298E2
    HIGHLIGHT_GRABBER:

!ORG 0x0702FA68
    STR_CONTINUE:
!ORG 0x0703E0F8
    STR_GAMESTART:
!ORG 0x0703E104
    STR_CONFIG:
!ORG 0x0703E110
    STR_TRAINING:
!ENDIF  ; CUSTOM_MENU

!ORG 0x0703DE1C
    ROM_SCORES: