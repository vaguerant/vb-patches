!CONST SKIP_INTRO, 0
!CONST SKIP_MANUAL_ONLY, 0

!IF SKIP_INTRO
!SEEK 0x02282
    ?dw 0, 0, 0
!ENDIF

; this is an alternative to skipping the intro screens completely.
; the manual screen is what starts the music playing which continues
; through the IPD and auto-pause screens. if you disable the manual
; but keep the other two, they're all awkward and quiet. this alt
; version modifies the manual function so that all it does is start
; the music playing, then the other two screens play back normally.
!IF SKIP_MANUAL_ONLY
!ORG 0x070328FA
!SEEK 0x328FA
    ?push lp
    movea 0x12, r0, r6
    jal PLAY_MUSIC
    ?pop lp
    jmp [lp]
    !ORG 0x0703D87A
        PLAY_MUSIC:
!ENDIF

!CONST SRAM_PASSWORD,      0x0008
!CONST SRAM_ATTACK_STAGES, SRAM_PASSWORD+8
!CONST SRAM_ATTACK_BEATEN, SRAM_ATTACK_STAGES+8
!CONST SRAM_ATTACK_SCORES, SRAM_ATTACK_BEATEN+8
!CONST SRAM_ATTACK_UNLOCK, SRAM_ATTACK_SCORES+0x50
!CONST SRAM_POCKET_STAGES, SRAM_ATTACK_UNLOCK+8
!CONST SRAM_POCKET_BEATEN, SRAM_POCKET_STAGES+8
!CONST SRAM_POCKET_SCORES, SRAM_POCKET_BEATEN+8
!CONST SRAM_POCKET_UNLOCK, SRAM_POCKET_SCORES+0x50

; Erase SRAM with L + R + Left Down + Right Down on title screen
!ORG 0x07023262
!SEEK 0x23262
    jr ERASE_CHECK
    ERASE_CHECK_RETURN:

; Update Score Attack scores and progress
!ORG 0x07022B6A
!SEEK 0x22B6A
UPDATE_SCOREATTACK:
    bgt .RUN_UPDATE
    br SAVE_SCOREATTACK_STAGES_RETURN
    .RUN_UPDATE:
        movhi 0x500, r0, r1
        ld.b 0x089A[r1], r12        ; which stage to update, 0-indexed
        mov r12, r14                ; second copy for us to use later
    !ORG 0x07022B94
    !SEEK 0x22B94
        jr SAVE_SCOREATTACK         ; st.h r10, 0x0000[r11]
        SAVE_SCOREATTACK_RETURN:
    !ORG 0x07022C0A
    !SEEK 0x22C0A
        jr SAVE_SCOREATTACK_STAGES  ; st.w r10, 0x08D0[r1]
        SAVE_SCOREATTACK_STAGES_RETURN:
    !ORG 0x07022C44
    !SEEK 0x22C44
        jr SCOREATTACK_UNLOCK  ; st.b r10, 0x08FF[r1]
        !ORG 0x07022C50
        SCOREATTACK_UNLOCK_RETURN:

; Update Pocket and Cushion scores and progress
!ORG 0x07022D34
!SEEK 0x22D34
UPDATE_POCKET:
    bgt .RUN_UPDATE
    br SAVE_POCKET_STAGES_RETURN
    .RUN_UPDATE:
        movhi 0x500, r0, r1
        ld.b 0x089A[r1], r12    ; which stage to update, 0-indexed
        mov r12, r14            ; anybody else getting deja vu
    !ORG 0x07022D5E
    !SEEK 0x22D5E
        jr SAVE_POCKET          ; st.h r11, 0x0000[r6]
        SAVE_POCKET_RETURN:
    !ORG 0x07022DC4
    !SEEK 0x22DC4
        jr SAVE_POCKET_STAGES   ; st.w r10, 0x0904[r1]
        SAVE_POCKET_STAGES_RETURN:
    !ORG 0x07022DFE
    !SEEK 0x22DFE
        jr POCKET_UNLOCK        ; st.b r10, 0x0908[r1]
        !ORG 0x07022E0A
        POCKET_UNLOCK_RETURN:

; Skip password entry for Score Attack
!ORG 0
!SEEK 0x232C6
    ?dw 0
!SEEK 0x23CB6
    nop
    mov 0, r10

; Skip password entry for Pocket and Cushion
!ORG 0
!SEEK 0x232E0
    ?dw 0
!SEEK 0x23DE6
    nop
    mov 0, r10

; Save typed password (replaces "earned" password!)
!ORG 0x07023BBA
!SEEK 0x23BBA
PASSWORD_SAVE:
    movhi 0x600, r0, r6
    br .BYTE_CHECK
    .NEXT_BYTE:
        movhi 0x500, r20, r1
        ld.b 0x08BD[r1], r10
        st.b r10, 0x08C5[r1]
        st.b r10, SRAM_PASSWORD[r6]
        add 2, r6
        add 1, r20
        .BYTE_CHECK:
            cmp 3, r20
            blt .NEXT_BYTE
    br .SAVE_COMPLETE
    movhi 0x500, r0, r1
    ld.b 0x089C[r1], r10
    cmp 0, r10
    be .DONT_CARE           ; just optimizing code so my injection fits
    br .REALLY_DONT_CARE    ; in-place, i don't know/care what this does
    .DONT_CARE:
    !ORG 0x07023BEC
    .REALLY_DONT_CARE:
    !ORG 0x07023C52
    .SAVE_COMPLETE:

; Save Adventure of Chalvo password
!ORG 0x07029BBE
!SEEK 0x29BBE
    movhi 0x600, r0, r1
    jr SAVE_CHALVO
    !ORG 0x07029BDA
    SAVE_CHALVO_RETURN:

; Load in Adventure of Chalvo password
!ORG 0x07033060
!SEEK 0x33060
    st.b r10, 0x0898[r1]
    jr CHECK_SRAM
    CHECK_SRAM_RETURN:
        movhi 0x600, r0, r6
        mov 4, r10      ; sneaky, r10 needs to be 0 after this ...
        br .CHALVO_CHECK
        .NEXT_BYTE:
            mov -1, r11
            st.b r11, 0x08BD[r1]
            ld.b SRAM_PASSWORD[r6], r11
            st.b r11, 0x08C5[r1]
            add 2, r6
            add 1, r1
            .CHALVO_CHECK:
                add -1, r10      ; so we're using it as decrementing counter
                bne .NEXT_BYTE
    cmp -1, r11
    be .NO_CONTINUE
    movhi 0x500, r0, r1
    mov 1, r11
    st.b r11, 0x0899[r1]
    .NO_CONTINUE:

; Load in Score Attack and Pocket progress
!ORG 0x070330C6
!SEEK 0x330C6
    movhi 0x500, r0, r1
    st.b r0, 0x08D4[r1]
    mov -2, r10
    st.b r10, 0x08BB[r1]
    st.b r10, 0x08BC[r1]
    st.b r10, 0x0902[r1]
    st.b r0, 0x089A[r1]
    st.b r0, 0x089B[r1]
    movhi 0x600, r0, r6
    ld.w SRAM_ATTACK_STAGES[r6], r10
    xb r10
    shr 8, r10
    st.h r10, 0x08D0[r1]
    ld.w SRAM_ATTACK_STAGES+4[r6], r10
    xb r10
    shr 8, r10
    st.h r10, 0x08D2[r1]
    ld.w SRAM_POCKET_STAGES[r6], r10
    xb r10
    shr 8, r10
    st.h r10, 0x0904[r1]
    ld.w SRAM_POCKET_STAGES+4[r6], r10
    xb r10
    shr 8, r10
    st.h r10, 0x0906[r1]
    movea 0x14, r0, r7
    LOAD_NEXT_ATTACK:
        ld.w SRAM_ATTACK_SCORES[r6], r10
        xb r10
        shr 8, r10
        st.h r10, 0x8D6[r1]
        add 4, r6
        add 2, r1
        add -1, r7
        bne LOAD_NEXT_ATTACK
    movea 0x14, r0, r7
    movhi 0x600, r0, r6
    LOAD_NEXT_POCKET:
        ld.w SRAM_POCKET_SCORES[r6], r10
        xb r10
        shr 8, r10
        st.h r10, 0x916-0x28[r1]
        add 4, r6
        add 2, r1
        add -1, r7
        bne LOAD_NEXT_POCKET
    movea 0x10, r0, r10
    movhi 0x500, r0, r1
    movhi 0x600, r0, r6
    ld.b SRAM_ATTACK_UNLOCK[r6], r10
    st.b r10, 0x08FE[r1]
    ld.b SRAM_POCKET_UNLOCK[r6], r10
    st.b r10, 0x093E[r1]
    ld.b SRAM_ATTACK_BEATEN[r6], r10
    st.b r10, 0x08FF[r1]
    shl 1, r10
    st.b r10, 0x0900[r1]
    ld.b SRAM_POCKET_BEATEN[r6], r10
    st.b r10, 0x0908[r1]
    shl 1, r10
    st.b r10, 0x0909[r1]
    st.b r0, 0x0901[r1]
    st.b r0, 0x090A[r1]
    st.b r0, 0x093F[r1]
    st.b r0, 0x0940[r1]
    movhi 0x500, r0, r1     ; not needed
    st.b r0, 0x2FFA[r1]

; Save debug Score Attack!! unlocks
!ORG 0x0703386E
!SEEK 0x3386E
    movhi 0x500, r0, r1
    movhi 0x600, r0, r6
    mov -1, r10
    st.h r10, 0x08D0[r1]
    shl 8, r10
    xb r10
    st.w r10, SRAM_ATTACK_STAGES[r6]
    movea 0x14, r0, r10
    st.b r10, 0x08FE[r1]
    st.b r10, SRAM_ATTACK_UNLOCK[r6]
    mov 1, r10
    st.b r10, 0x08FF[r1]
    st.b r10, 0x0900[r1]
    st.b r10, SRAM_ATTACK_BEATEN[r6]
    jr DEBUG_ATTACK_COMPLETE
    !ORG 0x070331E8
    DEBUG_ATTACK_COMPLETE:

; Save debug Pocket and Cushion unlocks
!ORG 0x0703BDC8
!SEEK 0x3BDC8
    movhi 0x500, r0, r1
    movhi 0x600, r0, r6
    mov -1, r10
    st.h r10, 0x0904[r1]
    shl 8, r10
    xb r10
    st.w r10, SRAM_POCKET_STAGES[r6]
    movea 0x14, r0, r10
    st.b r10, 0x093E[r1]
    st.b r10, SRAM_POCKET_UNLOCK[r6]
    mov 1, r10
    st.b r10, 0x0908[r1]
    st.b r10, 0x0909[r1]
    st.b r10, SRAM_POCKET_BEATEN[r6]
    jr DEBUG_POCKET_COMPLETE
    !ORG 0x0703B71E
    DEBUG_POCKET_COMPLETE:

; Remove password display from Score Attack
!SEEK 0x33EAA
    nop
!ORG 0
!SEEK 0x61F48
    ?dw 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF
!SEEK 0x61F94
    ?dw 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7
    ?dw 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7
!SEEK 0x61FF4
    ?dw 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7
    ?dw 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7
!SEEK 0x62068
    ?dw 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF

; Remove password display from Pocket and Cushion
!SEEK 0x3C404
    nop
!ORG 0
!SEEK 0xB97E4
    ?dw 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF
!SEEK 0xB9830
    ?dw 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7
    ?dw 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7, 0x06D706D7
!SEEK 0xB9890
    ?dw 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7
    ?dw 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7, 0x16D716D7
!SEEK 0xB9904
    ?dw 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF, 0x07FF07FF

!ORG 0x07000732
    FADE_OUT:

!ORG 0x07FFFFF0
    SOFT_RESET:

!ORG 0x0703D938
!SEEK 0x3D938
CHECKWORD:
    ?STRING "BHSV"

CHECK_SRAM:
    ?push lp
    jal VALIDATE_CHECKWORD
    st.w r0, -0x10[sp]      ; game expects a clean stack at this address
    cmp 0, r6
    be .CHECKWORD_OK
        ; write in any necessary defaults
        movhi 0x600, r0, r6
        mov -1, r10             ; no chalvo progress
        st.b r10, SRAM_PASSWORD[r6]
        st.b r10, SRAM_PASSWORD+2[r6]
        st.b r10, SRAM_PASSWORD+4[r6]
        movea 0x10, r0, r10     ; 16 levels unlocked
        st.b r10, SRAM_ATTACK_UNLOCK[r6]
        st.b r10, SRAM_POCKET_UNLOCK[r6]
    .CHECKWORD_OK:
        ?pop lp
        jr CHECK_SRAM_RETURN

; Boilerplate SRAM functions
!CONST SRAM_CHECKWORD, 0
!INCLUDE "include/boot.asm"

ERASE_CHECK:
    movea 0x8432, r0, r1
    andi 0xFFFF, r1, r1
    cmp r1, r11
    bne .NO_ERASE
        movhi 0x600, r0, r6
        st.w r0, 0x0000[r6]
        jal FADE_OUT
        jr SOFT_RESET
    .NO_ERASE:
        movhi 0x1000, r0, r1
        jr ERASE_CHECK_RETURN

SAVE_SCOREATTACK:
    st.h r10, 0x0000[r11]
    shl 2, r14
    movhi 0x600, r14, r14
    shl 8, r10
    xb r10
    st.w r10, SRAM_ATTACK_SCORES[r14]
    jr SAVE_SCOREATTACK_RETURN

SAVE_SCOREATTACK_STAGES:
    st.w r10, 0x08D0[r1]
    movhi 0x600, r0, r1
    st.b r10, SRAM_ATTACK_STAGES[r1]
    shr 8, r10
    st.b r10, SRAM_ATTACK_STAGES+2[r1]
    shr 8, r10
    st.b r10, SRAM_ATTACK_STAGES+4[r1]
    shr 8, r10
    st.b r10, SRAM_ATTACK_STAGES+6[r1]
    jr SAVE_SCOREATTACK_STAGES_RETURN

SCOREATTACK_UNLOCK:
    ?push r6
    movhi 0x600, r0, r6
    st.b r10, 0x08FF[r1]
    st.b r10, SRAM_ATTACK_BEATEN[r6]
    movea 0x14, r0, r10
    st.b r10, SRAM_ATTACK_UNLOCK[r6]
    ?pop r6
    jr SCOREATTACK_UNLOCK_RETURN

SAVE_POCKET:
    st.h r11, 0x0000[r6]
    shl 2, r14
    movhi 0x600, r14, r14
    shl 8, r11
    xb r11
    st.w r11, SRAM_POCKET_SCORES[r14]
    jr SAVE_POCKET_RETURN

SAVE_POCKET_STAGES:     ; r1 is free
    st.w r10, 0x0904[r1]
    movhi 0x600, r0, r1
    st.b r10, SRAM_POCKET_STAGES[r1]
    shr 8, r10
    st.b r10, SRAM_POCKET_STAGES+2[r1]
    shr 8, r10
    st.b r10, SRAM_POCKET_STAGES+4[r1]
    shr 8, r10
    st.b r10, SRAM_POCKET_STAGES+6[r1]
    jr SAVE_POCKET_STAGES_RETURN

POCKET_UNLOCK:
    ?push r6
    movhi 0x600, r0, r6
    st.b r10, 0x0908[r1]
    st.b r10, SRAM_POCKET_BEATEN[r6]
    movea 0x14, r0, r10
    st.b r10, SRAM_POCKET_UNLOCK[r6]
    ?pop r6
    jr POCKET_UNLOCK_RETURN

SAVE_CHALVO:            ; SRAM is in r1
    br .CHALVO_CHECK
    .NEXT_BYTE:
        mov r6, r11
        add r10, r11
        movea 0x0, sp, r12
        add r10, r12
        ld.b 0x0000[r12], r12
        st.b r12, 0x0000[r11]
        st.b r12, SRAM_PASSWORD[r1]
        add 2, r1
        add 1, r10
    .CHALVO_CHECK:
        cmp 3, r10
        blt .NEXT_BYTE
    jr SAVE_CHALVO_RETURN