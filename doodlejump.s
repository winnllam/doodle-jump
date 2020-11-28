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

# Objects
platforms:	.space 	26	# 4 * 6
platformLength:	.word 	5


.text
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
# TODO: RNG to sepecific sections of display (only the top one would get a new generated one)
initPlatforms:
	la $s7, platforms	# load space for platform array
	li $t8, 0		# counter for # of platforms
	li $t7, 0		# offset shifts for platform array

platformPrep:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 1024		# 1024/4
	syscall
	
	add $t6, $s7, $t7
	#sw $a0, 0($t6)		# store into memory (array)
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
	bne $t8, 6, platformPrep	# loop to generate another platform (6 times)


### Draw and move Doodle ###
drawDoodle:
	lw $a1, doodleColour
	lw $t7, backgroundColour	# save colour at current location

	lw $t1, doodleStart		# base address for display
	
	sw $a1, 0($t1)			# draw initial doodle

keyCheckInit:	# start of the jumping process
	lw $t0, 0xffff0000
	beq $t0, 1, movementKeyPress
	
doodleJumpInit:
	li $t9, 0		# counter for distance up and down

doodleJumpUp:
	sub $t1, $t1, 128	# up
	sw $t7, 128($t1)	
	jal moveDoodle
	
	addi $t9, $t9, 1
	
	li $v0, 32		# sleep to delay animation
	lw $a0, jumpDelay
	syscall
	
	jal keyCheck
	
	jal checkPlatforms
	
	bne $t9, 6, doodleJumpUp	# continue up
	
doodleJumpDown:
	addi $t1, $t1, 128	# down
	sw $t7, -128($t1)	
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
	beq $t2, 0x6A, moveDoodleLeft	# j
	beq $t2, 0x6B, moveDoodleRight	# k
	
	j keyCheckInit		# not a movement key, continue looping

moveDoodleLeft:
	#beq $t1, 0x10008000, movementKeyPress	# hit left border
		
	sub $t1, $t1, 4		# move left
	sw $t7, 4($t1)		# load previous colour at current location
	
	j moveDoodle		# skip over moveDoodleRight
	
moveDoodleRight:
	#beq $t1, 0x1000807c, movementKeyPress	# hit right border
	
	add $t1, $t1, 4	
	sw $t7, -4($t1)	

moveDoodle:	# colour saving and loading		
	lw $t7, 0($t1)		# save new colour at location
	sw $a1, 0($t1)		# load new colour
	
	jr $ra


### Movement to platforms ###
checkPlatforms:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		# add pointer to jump up to stack

	la $t4, platforms
	li $t8, 0		# initialize platform counter

	jal checkOnPlatform
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

checkOnPlatform:
	lw $t3, 0($t4)		# load platform location
	add $t3, $t3, $gp	# $gp is same as displayAddress
	
	beq $t3, $t1, onPlatform	# check entire length of platform
	addi $t3, $t3, 4
	 
	beq $t3, $t1, onPlatform	# check entire length of platform
	addi $t3, $t3, 4
	beq $t3, $t1, onPlatform	# check entire length of platform
	addi $t3, $t3, 4
	beq $t3, $t1, onPlatform	# check entire length of platform
	addi $t3, $t3, 4
	beq $t3, $t1, onPlatform	# check entire length of platform
	addi $t3, $t3, 4
	
	addi $t4, $t4, 4	# increment offset
	addi $t8, $t8, 1	# incrememnt platform counter
	bne $t8, 6, checkOnPlatform 
	
	j noPlatform
	
onPlatform:
	li $s6, 1
	sub $t1, $t1, 128
	jr $ra
	
noPlatform:
	li $s6, 2
	jr $ra
	
# cross check with the array and the location doodle is at
# drop down if no base

Exit:
	li $v0, 10 # terminate the program gracefully
	syscall


