!IF 0
; Disable Splash Screens
!SEEK 0x047D6
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
!ENDIF

; On boot, check and (if necessary) initialize SRAM
!ORG 0x07004678
!SEEK 0x04678
    ?push lp
    jal CHECK_SRAM
    ?pop lp
    mov r0, r0

!ORG 0x07020880
SOFT_RESET:

; Save controls (first instance)
!ORG 0x07020E48
!SEEK 0x20E48
    jr SAVE_BUTTON_A        ; st.b r1, -0x7D2A[gp]
SAVE_BUTTON_A_RETURN:

; Update the high score
!ORG 0x07032410
!SEEK 0x32410
    jr UPDATE_SCORE         ; returns with a jr [lp]

; On the title screen, press L+R+Left D-Pad Down+Right D-Pad Down to reset the SRAM
!ORG 0x0703CCCA
!SEEK 0x3CCCA
    jr ERASE_SAVE           ; ld.h -0x7CFE[gp], r30
ERASE_SAVE_RETURN:

!ORG 0x07041A1E
!SEEK 0x41A1E
    jr SAVE_BRIGHTNESS      ; st.h r6, -0x7D34[gp]
SAVE_BRIGHTNESS_RETURN:

; Save depth (first instance)
!ORG 0x07041AAC
!SEEK 0x41AAC
    jr SAVE_DEPTH_A         ; st.h r7, -0x7D3A[gp]
    mov r0, r0
SAVE_DEPTH_A_RETURN:

; Save depth (second instance)
!ORG 0x07041C2C
!SEEK 0x41C2C
    jr SAVE_DEPTH_B         ; st.h r6, -0x7D3C[gp]
    mov r0, r0
SAVE_DEPTH_B_RETURN:

; Save controls (second instance)
!ORG 0x07041D92
!SEEK 0x41D92
    jr SAVE_BUTTON_B        ; st.b r1, -0x7D2A[gp]
SAVE_BUTTON_B_RETURN:

; Save depth (third instance)
!ORG 0x07041E16
!SEEK 0x41E16
    jr SAVE_DEPTH_C         ; st.h r6, -0x7D3C[gp]
SAVE_DEPTH_C_RETURN:

!ORG 0x0704518C
!SEEK 0x4518C
    jr SAVE_DIFFICULTY      ; st.h r30, -0x7D1C[gp]
SAVE_DIFFICULTY_RETURN:

; High score saving if you already hit the score cap
!ORG 0x070454EE
!SEEK 0x454EE
    jr MAX_SCORE
MAX_SCORE_RETURN:

; Checkword used to confirm SRAM has been initialized
!ORG 0x070F1610
!SEEK 0xF1610
    ?STRING "RASV"

!ORG 0x070F1614
!SEEK 0xF1614
CHECK_SRAM:
    movhi 0x600, r0, r30
    movhi 0x70F, r0, r6
    movea 0x1610, r6, r6    ; address of RASV in ROM
    ld.w 0000[r6], r6       ; address of RASV in SRAM
    ld.w 0000[r30], r1
    cmp r1, r6              ; is RASV in the SRAM?
    be CLEAR_MEM
CLEAR_SRAM:
    movea 0x4000, r0, r1
        NEXT_SRAM:
        st.w r0, 0x0000[r30]
        add 4, r30
        add -1, r1
        bne NEXT_SRAM
INIT_SRAM:
    movhi 0x600, r0, r30
    st.w r6, 0x0000[r30]
    mov -12, r1
    st.h r1, 0x02C4[r30]    ; init left eye
    mov -6, r1
    st.h r1, 0x02C6[r30]    ; init right eye
    mov 6, r1
    st.h r1, 0x02CC[r30]    ; init brightness
    mov 1, r1
    st.h r1, 0x02E4[r30]    ; init difficulty
CLEAR_MEM:
    movhi 0x500, r0, r30    ; now initialize RAM
    movea 0x4000, r0, r1
NEXT_MEM:
    st.w r0, 0000[r30]
    add 4, r30
    add -1, r1
    bne NEXT_MEM
LOAD_MEM:
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    ld.h -0x7D3C[r6], r7    ; load in left eye
    ld.h -0x7D3A[r6], r8    ; load in right eye
    ld.h -0x7D34[r6], r9    ; load in brightness
    ld.h -0x7D1C[r6], r10   ; load in difficulty
    ld.h -0x7D2A[r6], r11   ; load in controls
    ld.h 0x0894[r6], r6     ; load in high score
    st.h r6, 0x0894[gp]
RETURN_SRAM:
    jmp [lp]

SAVE_BUTTON_A:
    ?push r6
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r1, -0x7D2A[r6]
    st.h r1, -0x7D2A[gp]
    ?pop r6
    jr SAVE_BUTTON_A_RETURN
SAVE_BUTTON_B:
    ?push r6
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r1, -0x7D2A[r6]
    st.h r1, -0x7D2A[gp]
    ?pop r6
    jr SAVE_BUTTON_B_RETURN

UPDATE_SCORE:
    ?push r6, r7
    ld.b 0x3E3E[gp], r6     ; Check if debug is enabled
    movea 0x003C, r0, r7
    cmp r7, r6
    bge SCORE_RETURN
    ld.h -0x7D32[gp], r6    ; Check if we're in the attract mode
    cmp 3, r6
    be SCORE_RETURN
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r30, 0x0894[r6]    ; save high score to sram
    st.h r30, 0x0894[gp]    ; ... and regular ram
SCORE_RETURN:
    ?pop r6, r7
    jmp [lp]

ERASE_SAVE:
    ?push r6
    movea 0x8432, r0, r6
    ld.h -0x7D00[gp], r30
    cmp r6, r30
    bne DONT_ERASE
    movhi 0x600, r0, r6;
    st.w r0, 0000[r6]       ; blank the checkword
    jr SOFT_RESET           ; soft reset will take us via CHECK_SRAM to re-init the save
DONT_ERASE:
    ld.h -0x7CFE[gp], r30
    ?pop r6
    jr ERASE_SAVE_RETURN

SAVE_BRIGHTNESS:
    ?push r7
    movhi 0x601, r0, r7
    movea 0x8000, r7, r7
    st.h r6, -0x7D34[r7]
    st.h r6, -0x7D34[gp]
    ?pop r7
    jr SAVE_BRIGHTNESS_RETURN

SAVE_DEPTH_A:
    ?push r6
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r7, -0x7D3A[r6]
    st.h r7, -0x7D3A[gp]
    shl 1, r7
    st.h r7, -0x7D3C[r6]
    ?pop r6
    jr SAVE_DEPTH_A_RETURN
SAVE_DEPTH_B:
    ?push r8
    movhi 0x601, r0, r8
    movea 0x8000, r8, r8
    st.h r6, -0x7D3C[r8]
    st.h r6, -0x7D3C[gp]
    mov -8, r7
    st.h r7, -0x7D3A[r8]
    ?pop r8
    jr SAVE_DEPTH_B_RETURN
SAVE_DEPTH_C:
    ?push r8
    movhi 0x601, r0, r8
    movea 0x8000, r8, r8
    st.h r6, -0x7D3C[r8]
    st.h r6, -0x7D3C[gp]
    st.h r7, -0x7D3A[r8]
    ?pop r8
    jr SAVE_DEPTH_C_RETURN

SAVE_DIFFICULTY:
    ?push r6
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r30, -0x7D1C[r6]
    st.h r30, -0x7D1C[gp]
    ?pop r6
    jr SAVE_DIFFICULTY_RETURN

MAX_SCORE:
    ?push r6
    movhi 0x601, r0, r6
    movea 0x8000, r6, r6
    st.h r1, 0x894[r6]
    st.h r1, 0x894[gp]
    ?pop r6
    jr MAX_SCORE_RETURN