!IF 0
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
jr SAVE_CHECK				; add -0x10, sp; mov 1, r10, add 0x10, sp; jmp [lp]

!ORG 0xFFE1315C
FFE1315C:

!ORG 0xFFE131A0
FFE131A0:

!ORG 0xFFE131E8
FFE131E8:

; Save check ported from Japanese version
!ORG 0xFFE2A800
!SEEK 0x2A800
SAVE_CHECK:
	addi 0xFFE8, sp, sp
	st.w lp, 0x14[sp]
	movhi 0x600, r0, r1
	movea 0x0000, r1, r6
	movhi 0xFFF4, r0, r1
	movea 0xB3DC, r1, r7
	jr FFE2A840
FFE2A81C:
	mov r10, r9
	andi 0xFF, r9, r9
	ld.b 0x0000[r6], r8
	andi 0xFF, r8, r8
	cmp r9, r8
	bne FFE2A832
	jr FFE2A83C
FFE2A832:
	jal FFE1315C
	mov 1, r10
	jr FFE2A87A
FFE2A83C:
	add 2, r6
	add 1, r7
FFE2A840:
	ld.b 0x0000[r7], r10
	cmp 0, r10
	bne FFE2A81C
	movea 0x1FEC, r0, r7
	movhi 0x600, r0, r1
	movea 0x28, r1, r6
	jal FFE131E8
	mov r10, r7
	st.w r7, 0x10[sp]
	jal FFE131A0
	ld.w 0x10[sp], r7
	cmp r10, r7
	bne FFE2A86E
	jr FFE2A878
FFE2A86E:
	jal FFE1315C
	mov 1, r10
	jr FFE2A87A
FFE2A878:
	mov r0, r10
FFE2A87A:
	ld.w 0x14[sp], lp
	addi 0x18, sp, sp
	jmp [lp]