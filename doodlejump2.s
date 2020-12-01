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

# Display locations
doodleStart: 	.word	0x10008dc0

# Anmiation delay
jumpDelay:	.word	100

# Colours
backgroundColour:	.word	0xc2e6ec 	# blue
doodleColour:		.word	0x745185 	# purple
platformColour:		.word	0x74bea7	# green

# Controls (ASCII numbers)
left:		.word 0x6A	# j 
right:		.word 0x6B	# k
start:		.word 0x73
keyboardAddress1:	.word	0xffff0000
keyboardAddress2:	.word	0xffff0004

# Objects
platforms:	.space 	32	# 4 byte * 8 platforms
platformLength:	.word 	6

### REGISTERS ###
# $a2
# $a3
# $s0 - background colour
# $s1 - doodle colour
# $s2 - platform colour
# $s3 - platform array
# $s4 - platform length
# $s5 - doodle start
# $s6 - doodle position
# $s7 - 
# $k0, $k1 - keyboard inputs
# $gp - display address

### INITIALIZATION START ###
.text
main:
	lw $s0, backgroundColour
	lw $s1, doodleColour
	lw $s2, platformColour
	la $s3, platforms
	lw $s4, platformLength
	lw $s5, doodleStart

### Fill background ###
backgroundFillInit:
	li $t0, 0 		# loop counter
	add $t1, $gp, $zero
	
backgroundFill:
	sw $s0, 0($t1) 		# save background colour at location
	add $t1, $t1, 4 	# increment to next pixel
	addi $t0, $t0, 1
	bne $t0, 1024, backgroundFill	# 1024 pixels
	
### Draw platforms ###
initPlatforms:
	li $t0, 0		# counter for # of platforms
	li $t1, 0		# offset shifts for platform array
	li $t2, 0		# partition for platform locations

generateLocation:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 128		# 1024/4
	syscall
	
	add $a0, $a0, $t2 	# add section offset for platform
	addi $t2, $t2, 128
	
	add $t6, $s3, $t1
	addi $t1, $t1, 4	# update platform array offset

	li $t5, 0 		# loop counter
	
loadPlatformAddress:
	li $t4, 4		# multiplier
	mult $t4, $a0		# RNG * 4 (so multiple of 4)
	mflo $a1
	
	sw $a1, 0($t6)		# store into memory (array)
	
	add $t8, $gp, $a1	# load rng location

drawPlatform:
	sw $s2, 0($t8) 			# save platform colour at location
	add $t8, $t8, 4 		# increment to next pixel horizontal
	addi $t5, $t5, 1
	bne $t5, $s4, drawPlatform	# platform length is 5
	
	addi $t0, $t0, 1		# increment to next platform
	bne $t0, 7, generateLocation	# loop to generate another platform (7 times)

startingPlatformInit:
	#li $a1, 4148	
	#add $t6, $s3, $t1
	
	#sw $a1, 0($t6)			# save to last spot in array		
	addi $t7, $s5, 120		# shift down and left 2 from doodle location (128 - 4 - 4 = 120)
	li $t5, 0
	
drawStartingPlatform:		
	sw $s2, 0($t7)			# 8th platform initialized to below doodle
	addi $t5, $t5, 1
	addi $t7, $t7, 4
	bne $t5, $s4, drawStartingPlatform

### Draw doodle ###
drawDoodle:
	sw $s1, 0($s5)			# draw initial doodle
	
#startKeyCheck:
	#li $v0, 32		# sleep
	#li $a0, 100
	#syscall
	
	#lw $k0, 0xffff0000
	#beq $k0, 1, startKeyCheck
	
	#lw $k1, 0xffff0004		# s is clicked, start game
	#bne $k1, 0x73, startKeyCheck		

### INITIALIZATION END ###

### Move Doodle ###
doodleJumpInit:
	li $t1, 0		# counter for distance up and down
	add $t0, $s0, $zero

doodleJumpUp:
	sub $s5, $s5, 128	# up
	sw $t0, 128($s5)	
	jal moveDoodle
	
	addi $t1, $t1, 1
	
	li $v0, 32		# sleep to delay animation
	lw $a0, jumpDelay
	syscall
	
	jal keyCheck
	jal checkPlatforms
	
	bne $t1, 10, doodleJumpUp	# continue up
	
doodleJumpDown:
	addi $s5, $s5, 128	# down
	sw $t0, -128($s5)	
	jal moveDoodle
	
	sub $t1, $t1, 1
	
	li $v0, 32		# sleep to delay animation
	lw $a0, jumpDelay
	syscall
	
	jal keyCheck		# check for input while movement to continue
	jal checkPlatforms
	
	bge $s5, 0x10009000, Exit
	
	bne $t1, 10, doodleJumpDown	# continue down	
		
	j doodleJumpInit

keyCheck:
	lw $k0, 0xffff0000
	beq $k0, 1, movementKeyPress
	
	jr $ra

movementKeyPress:	
	lw $k0, 0xffff0004
	beq $k0, 0x73, main	# s for restart
	
	beq $k0, 0x6A, moveDoodleLeft	# j
	beq $k0, 0x6B, moveDoodleRight	# k
	
	j doodleJumpInit		# not a movement key, continue looping

moveDoodleLeft:
	sub $s5, $s5, 8		# move left
	sw $t0, 8($s5)		# load previous colour at current location
	
	j moveDoodle		# skip over moveDoodleRight
	
moveDoodleRight:
	add $s5, $s5, 8	
	sw $t0, -8($s5)	

moveDoodle:	# colour saving and loading		
	lw $t0, 0($s5)		# save new colour at location
	sw $s1, 0($s5)		# load new colour
	
	jr $ra

### Movement to platforms ###
checkPlatforms:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		# add pointer to jump up to stack

	add $t4, $s3, $zero	# load platform location
	li $t2, 0		# initialize platform counter

	jal checkOnPlatformInit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

checkOnPlatformInit:
	lw $t3, 0($t4)		# load platform location
	add $t3, $t3, $gp	# $gp is same as displayAddress
	li $t6, 0		# counter for platform length

checkOnPlatform:
	beq $t3, $s5, onPlatform	# check entire length of platform (length of 6)
	addi $t3, $t3, 4
	
	addi $t6, $t6, 1		# platform length counter
	bne $t6, 6, checkOnPlatform	
	
	addi $t4, $t4, 4	# increment offset
	addi $t2, $t2, 1	# incrememnt platform counter
	bne $t2, 8, checkOnPlatformInit 
	
	j noPlatform
	
onPlatform: # TODO: on new platform? if row same as last time its a nope
	addi $sp, $sp, -4 	# save pointer back to checkPlatform
	sw $ra, 0($sp)
	
	#jal backdropShiftInit

	sub $s5, $s5, 128	# jump onto platform
	add $t0, $s0, $zero	# save background colour
	
	li $t1, 0		# reset jump counter
	j doodleJumpUp
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# load pointer back to checkPlatform
	
	jr $ra
	
noPlatform:	
	jr $ra
	
Exit:
	li $v0, 10 # terminate the program gracefully
	syscall
