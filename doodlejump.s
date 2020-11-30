#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Winnie Lam, 1004971792
#
# Bitmap Display Configuration:
# - Unit width in pixels: 16					     
# - Unit height in pixels: 16
# - Display width in pixels: 512
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). 
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data

# Screen 
screenWidth: 	.word 32
screenHeight: 	.word 32	# display width in pixels/unit width in pixels
pixel:		.word 1024

# Display locations
displayAddress:	.word	0x10008000	# same as $gp
doodleStart: 	.word	0x10008dc0

# Anmiation delay
jumpDelay:	.word	100

# Colours
backgroundColour:	.word	0xc2e6ec 	# blue
doodleColour:		.word	0x745185 	# purple
platformColour:		.word	0x74bea7	# green

# Controls (ASCII numbers)
direction:	.word 0
left:		.word 74	# j 6A
right:		.word 75	# k 6B
start:		.word 73

# Objects
platforms:	.space 	32	# 4 byte * 8 platforms
platformLength:	.word 	6


.text
### INITIALIZATION START ###
main:
### Fill background ###
	lw $a0, pixel		# 1024
	lw $a1, backgroundColour

	li $t0, 0 		# loop counter
	lw $t1, displayAddress	# base address for display

backgroundFill:
	sw $a1, 0($t1) 		# save background colour at location
	add $t1, $t1, 4 	# increment to next pixel
	addi $t0, $t0, 1
	bne $t0, $a0, backgroundFill	# 1024
	

### Draw platforms ###
# TODO: generate new platforms
initPlatforms:
	la $s7, platforms	# load space for platform array
	li $t8, 0		# counter for # of platforms
	li $t7, 0		# offset shifts for platform array
	li $t5, 0		# partition for platform locations

platformPrep:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 128		# 1024/4
	syscall
	
	add $a0, $a0, $t5 	# add section offset for platform
	addi $t5, $t5, 128
	
	add $t6, $s7, $t7
	addi $t7, $t7, 4	# update platform array offset
	
	lw $a3, platformLength
	lw $t4, platformColour

	li $t0, 0 		# loop counter
	lw $t1, displayAddress	# base address for display
	
loadPlatformLocation:
	li $s4, 4		# multiplier
	mult $s4, $a0		# RNG * 4 (so multiple of 4)
	mflo $a1
	
	sw $a1, 0($t6)		# store into memory (array)
	
	add $t1, $t1, $a1	# load rng location

drawPlatform:
	sw $t4, 0($t1) 			# save platform colour at location
	add $t1, $t1, 4 		# increment to next pixel horizontal
	addi $t0, $t0, 1
	bne $t0, $a3, drawPlatform	# platform length is 5
	
	addi $t8, $t8, 1		# increment to next platform
	bne $t8, 7, platformPrep	# loop to generate another platform (7 times)
	
	lw $s0, doodleStart		# base address for doodle starting location
	addi $s0, $s0, 120		# shift down and left 2 (128 - 4 - 4 = 120)
	li $t0, 0
	
drawStartingPlatform:		
	sw $t4, 0($s0)			# 8th platform initialized to below doodle
	addi $t0, $t0 1
	addi $s0, $s0, 4
	bne $t0, $a3, drawStartingPlatform

### Draw doodle ###
drawDoodle:
	lw $a1, doodleColour
	lw $t7, backgroundColour	# save colour at current location

	lw $s0, doodleStart		# base address for display (reset)
	sw $a1, 0($s0)			# draw initial doodle

startKeyCheck:
	lw $t0, 0xffff0000
	bne $t0, 1, startKeyCheck	# no click? loop
	
	lw $t2, 0xffff0004		# s is clicked, start game (s, 73)
	bne $t2, 0x73, startKeyCheck		

### INITIALIZATION END ###

### Move Doodle ###
keyCheckInit:	# start of the jumping process
	lw $t0, 0xffff0000
	beq $t0, 1, movementKeyPress
	
doodleJumpInit:
	li $t9, 0		# counter for distance up and down

doodleJumpUp:
	sub $s0, $s0, 128	# up
	sw $t7, 128($s0)	
	jal moveDoodle
	
	addi $t9, $t9, 1
	
	li $v0, 32		# sleep to delay animation
	lw $a0, jumpDelay
	syscall
	
	jal keyCheck
	
	jal checkPlatforms
	
	bne $t9, 10, doodleJumpUp	# continue up
	
doodleJumpDown:
	addi $s0, $s0, 128	# down
	sw $t7, -128($s0)	
	jal moveDoodle
	
	sub $t9, $t9, 1
	
	li $v0, 32		# sleep to delay animation
	lw $a0, jumpDelay
	syscall
	
	jal keyCheck		# check for input while movement to continue
	
	jal checkPlatforms
	
	bne $t9, 0, doodleJumpDown	# continue down	
		
	j keyCheckInit

keyCheck:
	lw $t0, 0xffff0000
	beq $t0, 1, movementKeyPress
	
	jr $ra

movementKeyPress:	
	lw $t2, 0xffff0004
	beq $t2, 0x73, main	# s for restart
	
	beq $t2, 0x6A, moveDoodleLeft	# j
	beq $t2, 0x6B, moveDoodleRight	# k
	
	j keyCheckInit		# not a movement key, continue looping

moveDoodleLeft:
	#beq $t1, 0x10008000, movementKeyPress	# hit left border
		
	sub $s0, $s0, 4		# move left
	sw $t7, 4($s0)		# load previous colour at current location
	
	j moveDoodle		# skip over moveDoodleRight
	
moveDoodleRight:
	#beq $t1, 0x1000807c, movementKeyPress	# hit right border
	
	add $s0, $s0, 4	
	sw $t7, -4($s0)	

moveDoodle:	# colour saving and loading		
	lw $t7, 0($s0)		# save new colour at location
	sw $a1, 0($s0)		# load new colour
	
	jr $ra


### Movement to platforms ###
checkPlatforms:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		# add pointer to jump up to stack

	la $t4, platforms
	li $t8, 0		# initialize platform counter

	jal checkOnPlatformInit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

checkOnPlatformInit:
	lw $t3, 0($t4)		# load platform location
	add $t3, $t3, $gp	# $gp is same as displayAddress
	li $t6, 0		# counter for platform length

checkOnPlatform:
	beq $t3, $s0, onPlatform	# check entire length of platform (length of 6)
	addi $t3, $t3, 4
	
	addi $t6, $t6, 1		# platform length counter
	bne $t6, 6, checkOnPlatform	
	
	addi $t4, $t4, 4	# increment offset
	addi $t8, $t8, 1	# incrememnt platform counter
	bne $t8, 8, checkOnPlatformInit 
	
	j noPlatform
	
onPlatform:
	addi $sp, $sp, -4 	# save pointer back to checkPlatform
	sw $ra, 0($sp)
	
	jal backdropShiftInit

	sub $s0, $s0, 128	# jump onto platform
	lw $t7, backgroundColour
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# load pointer back to checkPlatform
	
	jr $ra
	
noPlatform:
	addi $sp, $sp, -4 	# save pointer back to checkPlatform
	sw $ra, 0($sp)	
	
	li $t6, 0		# counter for the drop
	
continuousDrop:
	
	addi $t6, $t6, 128
	
	beq $t1, 0, Exit	# end game if hit bottom of screen
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# load pointer back to checkPlatform
	
	jr $ra

backdropShiftInit: # recolour the background
	lw $a0, pixel		# 1024
	lw $a2, backgroundColour

	li $t0, 0 		# loop counter
	lw $t1, displayAddress	# base address for display
	
backdropShift:
	sw $a2, 0($t1) 		# save background colour at location
	add $t1, $t1, 4 	# increment to next pixel
	addi $t0, $t0, 1
	bne $t0, $a0, backdropShift	# 1024
	
platformShiftInit: 	#s1 2 3
	la $s1, platforms
	lw $s2, platformColour
	li $t8, 0		# initialize platform counter
	
platformShiftDown:	# shift platforms down and store
	li $t6, 0		# initialize platform length counter

	lw $t3, 0($s1)		# load platform location
	addi $t3, $t3, 128	# shift down
	sw $t3, 0($s1)		# save new value to array
	
	addi $s1, $s1, 4	# increment offset to next value in array
	
	li $s3, 0		# reset display location
	add $s3, $gp, $t3
	
platformShiftRight:	# draw the entire platform
	sw $s2, 0($s3)		# colour into display
	addi $s3, $s3, 4	# offset for rest of platform
	
	addi $t6, $t6, 1	# increment platform length counter
	bne $t6, 6, platformShiftRight
	
	addi $t8, $t8, 1		# increment platform counter
	bne $t8, 8, platformShiftDown	# 8 platforms at a time
	
	addi $s0, $s0, 128
	
	jr $ra


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall


