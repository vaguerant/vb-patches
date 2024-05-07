; Shared function to run on boot in SRAM patches
; ==============================================
; Optionally wait 1500 us before 1st SRAM access
; Test whether save has already been initialized
; If not, clear SRAM and write out new checkword

VALIDATE_CHECKWORD:         ; r6 returns 0 for success, 1 for failure
    ?push r1, r7, r8, lp
    !IF SRAM_DELAY
        movhi 0x200, r0, r1
        mov 15, r7              ; 1500 ms delay
        st.b r0, 0x001C[r1]     ; counter and reload, high byte
        st.b r7, 0x0018[r1]     ; counter and reload, low byte
        mov 9, r7               ; set tim-z-int and t-enb
        st.b r7, 0x0020[r1]     ; timer control register
        sei                     ; disable interrupts
        .WAIT_LOOP:
            ld.w 0x0020[r1], r7
            andi 2, r7, r0
            be .WAIT_LOOP
        mov 4, r7               ; z-stat-clr
        st.b r7, 0x0020[r1]
        cli                     ; enable interrupts
    !ENDIF
    ?mov CHECKWORD, r1      ; now compare checkword in ROM to SRAM
    movhi 0x600, r0, r6
    .NEXT_CHECKBYTE:
        andi 8, r6, r0          ; if checkword is valid, skip SRAM init
        bne .CHECKWORD_OK
            ld.b 0x0000[r1], r7
            ld.b SRAM_CHECKWORD[r6], r8
            add 1, r1
            add 2, r6
            cmp r7, r8
            be .NEXT_CHECKBYTE
    .CHECKWORD_FAIL:
        movhi 0x600, r0, r6     ; erase all 64 KB (0x4000 words, 0x10000 bytes)
        movea 0x4000, r0, r7
        .NEXT_SRAM:
            st.w r0, 0x0000[r6]
            add 4, r6
            add -1, r7
            bne .NEXT_SRAM
        ?mov CHECKWORD, r1      ; write out the checkword
        ld.w 0x0000[r1], r1
        movhi 0x600, r0, r6
        .WRITE_CHECKWORD:
            st.b r1, SRAM_CHECKWORD[r6]
            shr 8, r1
            add 2, r6
            andi 8, r6, r0
            be .WRITE_CHECKWORD
        mov 1, r6
        br .RETURN
    .CHECKWORD_OK:
        mov 0, r6
    .RETURN:
        ?pop r1, r7, r8, lp
        jmp [lp]