!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
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

; Check and (if necessary) init SRAM
!ORG 0x07000044
!SEEK 0x00044
    jr CHECK_SRAM           ; mov r25, r6
    mov r0, r0              ; movea 0x4000, r0, r7
    CHECK_SRAM_RETURN:

; Write debug byte to save if booted while holding Select
!ORG 0x07000CF2
!SEEK 0x00CF2
    jal DEBUG_CHECK         ; jal STARTUP
    !ORG 0x0701AD30
    STARTUP:                    ; populates r1, r6, r7

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
!SEEK 0x01258
    be JAPAN_FIX
    jr SOUND_CHECK_FAILED
    SOUND_TEST:
    !ORG 0x070012CC
    SOUND_CHECK_FAILED:

; Difficulty toggle now saves to SRAM
!ORG 0x070014A8
!SEEK 0x014A8
    jr DIFFICULTY_TOGGLE        ; st.h r6, 0x00F4[r25]
    DIFFICULTY_TOGGLE_RETURN:
        jal SUPER_OR_NOT
        br .NULL_COUNTER
    !ORG 0x070014B8
    .NULL_COUNTER:

; Menu text printing
!ORG 0x07003474
MENU_PRINT:

; Dialogue text printing, needed a fix to handle sound test switch
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

; Secret language switch built into the game?! Hijack to switch in SRAM
!ORG 0x0700461E
!SEEK 0x0461E
    jr LANGUAGE_SWAP        ; st.h r6, 0x00F2[r25]
    LANGUAGE_SWAP_RETURN:

; Read debug byte from save (0x600) instead of ROM (0x700) everywhere
!SEEK 0x012E4
    movhi 0x600, r0, r1
!SEEK 0x013AE
    movhi 0x600, r0, r1
!SEEK 0x04C6A
    movhi 0x600, r0, r1
!SEEK 0x05380
    movhi 0x600, r0, r1
!SEEK 0x054C2
    movhi 0x600, r0, r1

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

; Print "DEBUG" on title screen when appropriate
!ORG 0x0700495A
!SEEK 0x0495A
    jr DEBUG_PRINT          ; movhi 0x700, r0, r1
    DEBUG_PRINT_RETURN:

; Difficulty setting loads in on startup
!ORG 0x07004A0C
!SEEK 0x04A0C
    jr LOAD_DIFFICULTY
    LOAD_DIFFICULTY_RETURN:

; Save progress made via gameplay
!ORG 0x7011E06
!SEEK 0x11E06
    jr SAVE_PROGRESS        ; st.h r6, 0x0168[r25]
    SAVE_PROGRESS_RETURN:

; Save progress when entering a password
!ORG 0x070119E2
!SEEK 0x119E2
    jr PASSWORD_PROGRESS    ; st.h r9, 0x0100[r25]
    PASSWORD_PROGRESS_RETURN:

; Print the current saved floor on character select
!ORG 0x07011316
!SEEK 0x11316
    jr PRINT_FLOOR          ; st.h r1, 0x0008[r25]
    PRINT_FLOOR_RETURN:

; Modify character select to support loading and deleting saves
!ORG 0x07011320
!SEEK 0x11320
    jr CUSTOM_CHARSELECT    ; ld.h 0x0014[r25], r7
    CUSTOM_CHARSELECT_RETURN:
        mov r7,  r8
        andi 0x0C, r8, r8

; Custom left/right wrapping on the character select
!ORG 0x0701134E
!SEEK 0x1134E
    blt RESET_LEFT
    br EXIT_WRAPAROUND
    RESET_LEFT:
        jr CHARSELECT_LEFT      ; mov 2, r6
    CHARSELECT_LEFT_RETURN:

!ORG 0x07011366
!SEEK 0x11366
    bgt RESET_RIGHT
    br EXIT_WRAPAROUND
    RESET_RIGHT:
        jr CHARSELECT_RIGHT     ; mov r0, r6
    EXIT_WRAPAROUND:
        jr PIXIE_PRINT          ; mov r6, r7; shl 15, r7
    PIXIE_PRINT_RETURN:

; Load progress when selecting a character
!ORG 0x070113DA
!SEEK 0x113DA
    jr LOAD_CHARACTER       ; st.h r6, 0x0118[r25]
    LOAD_CHARACTER_RETURN:

!ORG 0x07013FE8
STR_ERROR:

!ORG 0x0702014C
PLAY_SFX:

!ORG 0x0701D1D0
!SEEK 0x1D1D0
CHECKWORD:
    ?STRING "JBSV"

CHECK_SRAM:
    ?push r1, r8            ; r6 and r7 filled by CLEAR_MEM
    ?mov CHECKWORD, r1
    movhi 0x600, r0, r6
        NEXT_CHECKBYTE:
            andi 8, r6, r0  ; if CHECKWORD is valid, skip SRAM init
            bne CLEAR_MEM
                ld.b 0x0000[r1], r7
                ld.b 0x0008[r6], r8
                add 1, r1
                add 2, r6
                cmp r7, r8
                be NEXT_CHECKBYTE
    jal CLEAR_SRAM
    CLEAR_MEM:
        mov r25, r6
        movea 0x4000, r0, r7
        ?pop r1, r8
            ?br CHECK_SRAM_RETURN

CLEAR_SRAM:
    ?push r1, r7
    ?mov CHECKWORD, r1
    ld.w 0x0000[r1], r1
    movhi 0x600, r0, r6
    movea 0x4000, r0, r7
        NEXT_SRAM:
            st.w r0, 0x0000[r6]
            add 4, r6
            add -1, r7
                bne NEXT_SRAM
    ?mov CHECKWORD, r6
    ld.w 0x0000[r6], r6
    movhi 0x600, r0, r7
    WRITE_CHECKWORD:
        st.b r6, 0x0008[r7]
        shr 8, r6
        add 2, r7
        andi 0x8, r7, r0
            be WRITE_CHECKWORD
    add -8, r7               ; reset save offset
    mov -1, r6
    st.b r6, 0x0004[r7]      ; language
    ?pop r1, r7
        jmp [lp]

DEBUG_CHECK:
    movhi 0x600, r0, r6
    movhi 0x500, r0, r7
    ld.b 0x0010[r7], r7
    andi 0x80, r7, r0
        be NO_DEBUG_SWITCH
    ld.b 0x0000[r6], r7
    xori 0xFF, r7, r7
    st.b r7, 0x0000[r6]
        NO_DEBUG_SWITCH:
            jr STARTUP

DIFFICULTY_TOGGLE:      ; r1 and r7 are free
    movhi 0x600, r0, r1
    ld.b 0x0020[r1], r7
    xor r7, r6
    st.b r6, 0x0020[r1]
    st.h r6, 0x00F4[r25]
        ?br DIFFICULTY_TOGGLE_RETURN

SUPER_OR_NOT:
    ?push lp
    mov r6, r7
    movhi 0x2, r0, r1
    movea 0x293A, r1, r6
    cmp -1, r7
    be .HARD_MODE
    mov 9, r7
    .BLANK_SUPER:
        st.w r0, 0x0000[r6]
        add 4, r6
        add -1, r7
            bne .BLANK_SUPER
            br .SKIP_PRINT
    .HARD_MODE:
        movhi 0x700, r0, r1
        movea 0x4AD0, r1, r7
        mov 0, r9
        jal MENU_PRINT
    .SKIP_PRINT:
        ?pop lp
        jmp [lp]

LOAD_DIFFICULTY:        ; r6 and r7 are free
    movhi 0x600, r0, r7
    ld.b 0x0020[r7], r6
    st.h r6, 0x00F4[r25]
        ?br LOAD_DIFFICULTY_RETURN

LANGUAGE_SWAP:
    ?push r7
    movhi 0x600, r0, r1
    ld.b 0x0004[r1], r7
    xor r7, r6
    st.b r6, 0x0004[r1]
    ?pop r7
        ?br LANGUAGE_SWAP_RETURN

LOAD_CHARACTER:
    ?push r7, r8
    st.h r6, 0x0118[r25]
    shl 1, r6               ; need to offset each character by 2 bytes
    movhi 0x600, r6, r7
    ld.h 0x00F4[r25], r8
    cmp -1, r8
    bne .NORMAL_MODE
        addi 8, r7, r7      ; and another offset for hard mode saves
    .NORMAL_MODE:
    ld.b 0x0010[r7], r7
    cmp 1, r7
    blt NEW_GAME
        st.b r7, 0x0100[r25]
        mov -1, r7
        st.b r7, 0x0172[r25]    ; skip the intro cutscene
        st.h r7, 0x0240[r25]    ; not sure but the game does this so I will too
        br LOADED
    NEW_GAME:
        cmp 6, r6               ; check if we're Pixie
        bne LOADED
        mov -1, r7
        st.b r7, 0x0172[r25]    ; Pixie doesn't have an intro cutscene
        st.h r7, 0x0240[r25]
    LOADED:
        ?pop r7, r8
        ?br LOAD_CHARACTER_RETURN

DEBUG_PRINT:
    movhi 0x600, r0, r1
    ld.b 0x0000[r1], r1
    cmp -1, r1
    bne NO_DEBUG
        ?push r7, r9
        movhi 0x02, r0, r6
        movea 0x2DD6, r6, r6
        ?mov STR_DEBUG, r7
        mov r0, r9
        jal MENU_PRINT
        ?pop r7, r9
    NO_DEBUG:
        movhi 0x700, r0, r1
        ?br DEBUG_PRINT_RETURN

SAVE_PROGRESS:
    ?push r6, r7
    ld.b 0x0118[r25], r6
    shl 1, r6
    movhi 0x600, r6, r6
    ld.h 0x00F4[r25], r7
    cmp -1, r7
    bne .NORMAL_MODE
        addi 8, r6, r6
    .NORMAL_MODE:
    add 1, r8
    st.b r8, 0x0010[r6]
    add -1, r8
    ?pop r6, r7
    st.h r6, 0x0168[r25]
        ?br SAVE_PROGRESS_RETURN

PASSWORD_PROGRESS:
    ?push r7, r8
    ld.b 0x0118[r25], r6
    shl 1, r6
    movhi 0x600, r6, r7
    shr 1, r6
    ld.h 0x00F4[r25], r8
    cmp -1, r8
    bne .NORMAL_MODE
        addi 8, r7, r7
    .NORMAL_MODE:
    st.b r9, 0x0010[r7]
    st.b r9, 0x0100[r25]
    ?pop r7, r8
        ?br PASSWORD_PROGRESS_RETURN

!CONST BGMAP, 0x03
!CONST BGMAP_FLOOR, 0x8D88
!CONST BGMAP_PIXIE, 0x80D0
!CONST BGMAP_PFLOOR, 0x814E

PRINT_FLOOR:
    ?push r6, r7, r8, r9, lp
    mov r0, r8
    PRINT_NEXT_FLOOR:
        shl 1, r8
        movhi 0x600, r8, r6     ; r8 will cycle through the "three" characters
        ld.h 0x00F4[r25], r7
        cmp -1, r7
        bne .NORMAL_MODE
            addi 8, r6, r6
        .NORMAL_MODE:
        ld.b 0x0010[r6], r6
        shr 1, r8
        jal GET_SAVE_STRING
        shl 5, r8
        movhi BGMAP, r8, r6
        movea BGMAP_FLOOR, r6, r6
        shr 5, r8
        mov r0, r9
        ?push r8
        jal MENU_PRINT
        ?pop r8
        add 1, r8
        cmp 3, r8
        be STOP_PRINTING
        ?br PRINT_NEXT_FLOOR
    STOP_PRINTING:
        ?pop r6, r7, r8, r9, lp
        st.h r1, 0x0008[r25]
        ?br PRINT_FLOOR_RETURN

GET_SAVE_STRING:            ; pass in character's progress byte in r6
    cmp 0, r6
    bne PROGRESS_03
    ?mov STR_NEWGAME, r7
    br RETURN_PROGRESS
    PROGRESS_03:
        cmp 3, r6
        bne PROGRESS_08
        ?mov STR_FLOOR04, r7
        br RETURN_PROGRESS
    PROGRESS_08:
        cmp 8, r6
        bne PROGRESS_15
        ?mov STR_FLOOR09, r7
        br RETURN_PROGRESS
    PROGRESS_15:
        cmp 0xF, r6
        bne PROGRESS_25
        ?mov STR_FLOOR16, r7
        br RETURN_PROGRESS
    PROGRESS_25:
        movea 0x0019, r0, r7
        cmp r6, r7
        bne PROGRESS_40
        ?mov STR_FLOOR26, r7
        br RETURN_PROGRESS
    PROGRESS_40:
        movea 0x0028, r0, r7
        cmp r6, r7
        bne PROGRESS_ERROR
        ?mov STR_FLOOR41, r7
        br RETURN_PROGRESS
    PROGRESS_ERROR:
        ?mov STR_ERROR, r7
    RETURN_PROGRESS:
        jmp [lp]

; "DEBUG"
STR_DEBUG:
    ?db 0x1D, 0x1E, 0x1B, 0x2E, 0x20, 0x02
; 00 "NEW GAME"
STR_NEWGAME:
    ?db 0x27, 0x1E, 0x30, 0x00, 0x20, 0x1A, 0x26, 0x1E, 0x02
; 03 "FLOOR  4"
STR_FLOOR04:
    ?db 0x1F, 0x25, 0x28, 0x28, 0x2B, 0x00, 0x00, 0x14, 0x02
; 08 "FLOOR  9"
STR_FLOOR09:
    ?db 0x1F, 0x25, 0x28, 0x28, 0x2B, 0x00, 0x00, 0x19, 0x02
; 0F "FLOOR 16"
STR_FLOOR16:
    ?db 0x1F, 0x25, 0x28, 0x28, 0x2B, 0x00, 0x11, 0x16, 0x02
; 19 "FLOOR 26"
STR_FLOOR26:
    ?db 0x1F, 0x25, 0x28, 0x28, 0x2B, 0x00, 0x12, 0x16, 0x02
; 28 "FLOOR 41"
STR_FLOOR41:
    ?db 0x1F, 0x25, 0x28, 0x28, 0x2B, 0x00, 0x14, 0x11, 0x02
; "PIXIE>"
STR_PIXIE:
    ?db 0x29, 0x22, 0x31, 0x22, 0x1E, 0x4F, 0x02

CUSTOM_CHARSELECT:      ; r6 comes in holding character index, r7 holds input
    ld.h 0x0014[r25], r7
    ?push r6, r7, r8, r9, r10, lp
    CONTINUE_CHECK:
        andi 0xFBFF, r7, r0     ; if no other buttons pressed, check D-Pad Down
        be ADD_COUNTER
            mov r0, r8              ; else if user pressed *anything*, reset the counter
            br WRITE_COUNTER
    ADD_COUNTER:
        shl 1, r6               ; r6 enters this function carrying the current character index
        movhi 0x600, r6, r10
        ld.h 0x00F4[r25], r8
        cmp -1, r8
        bne .NORMAL_MODE
            addi 8, r10, r10
        .NORMAL_MODE:
        shr 1, r6
        ld.b 0x0010[r10], r8
        cmp 0, r8               ; is this save slot already empty?
            be NO_DELETE
        andi 0x0400, r7, r0     ; if user pressed D-Pad Down, add to the counter, else return
            be NO_DELETE
        ld.b 0x57FF[r25], r8
        add 1, r8               ; add to the deletion counter
        cmp 4, r8               ; if user pressed Down four times, delete save for current character
        be DELETE_SAVE
            movea 0x2D, r0, r6      ; "Taking Damage" SFX as a warning sound
            br PLAY_SOUND
    DELETE_SAVE:
        ?mov STR_NEWGAME, r7
        cmp 3, r6
        be PIXIE_DELETE
            shl 5, r6
            movhi BGMAP, r6, r6
            movea BGMAP_FLOOR, r6, r6
            br DELETION_TIME
    PIXIE_DELETE:
        movhi BGMAP, r0, r6
        movea BGMAP_PFLOOR, r6, r6
    DELETION_TIME:
        mov r0, r9
        jal MENU_PRINT          ; print "NEW GAME" over old saved floor
        st.b r0, 0x0010[r10]
        mov r0, r8
        movea 0x34, r0, r6      ; "Warp Sound (Same Floor)" SFX as confirmed deletion sound
    PLAY_SOUND:
        jal PLAY_SFX
    WRITE_COUNTER:
        st.b r8, 0x57FF[r25]
    NO_DELETE:
        ?pop r6, r7, r8, r9, r10, lp
        ?br CUSTOM_CHARSELECT_RETURN

CHARSELECT_LEFT:
    ?push r7, r8
    ld.h 0x0010[r25], r7
    andi 0x0030, r7, r7
    movea 0x0030, r0, r8
    cmp r7, r8              ; is user holding L+R?
    be KEEP_LEFT
        mov 2, r6               ; if not, wrap around to Skelton/Ripper
        br SETCHAR_LEFT
    KEEP_LEFT:
        mov 3, r6               ; else, wrap around to Pixie
    SETCHAR_LEFT:
        ?pop r7, r8
        ?br CHARSELECT_LEFT_RETURN

CHARSELECT_RIGHT:
    ?push r7, r8
    cmp 4, r6
    bge WRAP_RIGHT
    ld.h 0x0010[r25], r7
    andi 0x0030, r7, r7
    movea 0x0030, r0, r8
    cmp r7, r8
    be KEEP_RIGHT
    WRAP_RIGHT:
        mov r0, r6
    KEEP_RIGHT:
        ?pop r7, r8
        ?br EXIT_WRAPAROUND

PIXIE_PRINT:                ; lol pixie print
    cmp 3, r6
    ?push r6, r8, r9, lp
    bne NO_PIXIE_PRINT
    movhi BGMAP, r0, r6
    movea BGMAP_PIXIE, r6, r6
    ?mov STR_PIXIE, r7
    mov r0, r9
    jal MENU_PRINT
    movhi 0x600, r0, r6
    ld.h 0x00F4[r25], r7
    cmp -1, r7
    bne .NORMAL_MODE
        addi 8, r6, r6
    .NORMAL_MODE:
    ld.b 0x0016[r6], r6
    jal GET_SAVE_STRING
    movhi BGMAP, r0, r6
    movea BGMAP_PFLOOR, r6, r6
    mov r0, r9
    jal MENU_PRINT
    ?br PIXIE_PRINT_COMPLETE
    NO_PIXIE_PRINT:
        movhi BGMAP, r0, r7
        movea BGMAP_PIXIE-2, r7, r7
        mov r7, r8
    PIXIE_ERASE_LOOP:
        st.w r0, 0x0000[r7]
        st.w r0, 0x0080[r7]
        add 4, r7
        andi 0x0020, r7, r0     ; this is a goofy way to check
        be PIXIE_ERASE_LOOP
    PIXIE_PRINT_COMPLETE:
        ?pop r6, r8, r9, lp
        mov r6, r7
        shl 15, r7
        ?br PIXIE_PRINT_RETURN