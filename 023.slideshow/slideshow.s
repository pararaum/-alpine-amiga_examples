	include "includes.i"

	xref	InstallColorPalette
	xref 	PokeBitplanePointers
	xref	Level3InterruptHandler
	xref	copperList
	xref 	copperListAlternate
	xref 	bitplanesp1
	xref 	bitplanesp2
	xref 	bitplanesp3

	
byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap

Entry:
	move.l	#userstack,a7
	lea 	CUSTOM,a6
	
	jsr	LoadNextImage
	jsr	Init	
	
.mainLoop:
	jsr 	WaitVerticalBlank

	if 0
	cmp.l	#50*5,counter
	bne	.updateCounter
	jsr	LoadNextImage
	move.l	#0,counter
	else
	jsr	LoadNextImage
	endif

.updateCounter:
	add.l	#1,counter
	bra	.mainLoop

counter:
	dc.l	0

Level3InterruptHandler:
	movem.l	d0-a6,-(sp)
	lea	CUSTOM,a6
.checkVerticalBlank:
	move.w	INTREQR(a6),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a6)	; clear interrupt bit	
	if INTERLACE==1
	btst	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copperListAlternate,a0
	move.l	a0,COP1LC(a6)
	bra	.done
.lof:
	lea	copperList,a0
	 move.l	a0,COP1LC(a6)
.done
	endif ; INTERLACE==1
.checkCopper:
	move.w	INTREQR(a6),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a6)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte	

	
PokeBitplanePointers:
	; d0 = frame offset in bytes
	; a0 = BPLP copper list address
	; a1 = bitplanes pointer
	movem.l	d0-a6,-(sp)
	add.l	d0,a1 ; Offset for odd/even frames
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	SCREEN_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	movem.l (sp)+,d0-a6
	rts

	if INTERLACE==1
copperListAlternate:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe
	endif; INTERLACE==1
	
copperList:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe		

	align	4

bitplanesp1:
	dc.l	endCode
bitplanesp2:
	dc.l	endCode+(512)+IMAGESIZE
bitplanesp3:
	dc.l	endCode+(512*2)+(2*IMAGESIZE)
	