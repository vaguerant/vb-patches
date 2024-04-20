!CONST SKIP_INTRO, 0

!IF SKIP_INTRO
; Disable Splash Screens
!SEEK 0x04328
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
    mov r0, r0
!ENDIF

; Jump to restored save check
!ORG 0xFFE13218
!SEEK 0x13218
jr SAVE_CHECK               ; add -0x10, sp; mov 1, r10, add 0x10, sp; jmp [lp]

!ORG 0xFFE1315C
FFE1315C:

!ORG 0xFFE131A0
FFE131A0:

!ORG 0xFFE131E8
VALIDATE_CHECKSUM:

; Save check ported from Japanese version
!ORG 0xFFE2A800
!SEEK 0x2A800
SAVE_CHECK:
    addi 0xFFE8, sp, sp
    st.w lp, 0x14[sp]
    movhi 0x600, r0, r1
    movea 0x0000, r1, r6
    movhi 0xFFF4, r0, r1
    movea 0xB3DC, r1, r7    ; "T&E VR Golf p12" checkword in ROM
        jr READ_CHECKWORD_ROM
COMPARE_CHECKWORD_BYTE:
    mov r10, r9
    andi 0xFF, r9, r9
    ld.b 0x0000[r6], r8
    andi 0xFF, r8, r8
    cmp r9, r8              ; does save have the correct byte?
        bne CHECKWORD_FAILED
        jr CHECKWORD_PASSED
CHECKWORD_FAILED:
        jal FFE1315C
    mov 1, r10
        jr RETURN_SAVE_CHECK
CHECKWORD_PASSED:
    add 2, r6
    add 1, r7
READ_CHECKWORD_ROM:
    ld.b 0x0000[r7], r10
    cmp 0, r10
        bne COMPARE_CHECKWORD_BYTE
    movea 0x1FEC, r0, r7
    movhi 0x600, r0, r1
    movea 0x28, r1, r6
        jal VALIDATE_CHECKSUM
    mov r10, r7
    st.w r7, 0x10[sp]       ; store calculated checksum
        jal FFE131A0
    ld.w 0x10[sp], r7
    cmp r10, r7             ; does checksum in save match?
        bne BAD_CHECKSUM
        jr CHECKSUM_OK
BAD_CHECKSUM:
        jal FFE1315C
    mov 1, r10
        jr RETURN_SAVE_CHECK
CHECKSUM_OK:
    mov r0, r10
RETURN_SAVE_CHECK:
    ld.w 0x14[sp], lp
    addi 0x18, sp, sp
        jmp [lp]