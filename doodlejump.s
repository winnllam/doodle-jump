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
doodleStart: 		.word	0x10008dc0
basePlatformRow:	.word	3584#0x10008e00	#+128 for next row (3584)

# Anmiation delay
jumpDelay:	.word	100

# Colours
backgroundColour:	.word	0xc2e6ec 	# blue
doodleColour:		.word	0x745185 	# purple
platformColour:		.word	0x74bea7	# green
white:			.word	0xffffff

# Controls (ASCII numbers)
left:		.word 0x6A	# j 
right:		.word 0x6B	# k
start:		.word 0x73
keyboardAddress1:	.word	0xffff0000
keyboardAddress2:	.word	0xffff0004

# Objects
platforms:	.space 	32	# 4 byte * 8 platforms
platformLength:	.word 	6

# Letters and numbers
zero: 		.word	1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1
one:		.word	0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
two:		.word	1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 1, 1, 1 
three:		.word	1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1
four:		.word	1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1
five:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1
six:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1
seven:		.word	1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1
eight:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1
nine:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1
A:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1
B: 		.word	1, 1, 1, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1
E:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1
R:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1
S:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1
T:		.word	1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
Y:		.word	1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0
exclaim:	.word	0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0

### REGISTERS ###
# $a2
# $a3 - score
# $s0 - background colour
# $s1 - doodle colour
# $s2 - platform colour
# $s3 - platform array
# $s4 - platform length
# $s5 - doodle start
# $s6 - 
# $s7 - base platform
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
	lw $s7, basePlatformRow

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
	li $a1, 3640		# platform pixel location
	addi $t6, $s3, 28
	sw $a1, 0($t6)			# save to last spot in array	
		
	addi $t7, $s5, 120		# shift down and left 2 from doodle location (128 - 4 - 4 = 120)
	li $t5, 0
	
drawStartingPlatform:		
	sw $s2, 0($t7)			# 8th platform initialized to below doodle
	addi $t5, $t5, 1
	addi $t7, $t7, 4
	bne $t5, $s4, drawStartingPlatform

### Draw doodle ###
drawDoodle:
	sw $s1, 0($s5)	# draw initial doodle		
	
	jal drawScore	# draw initial score of 0		

startKeyCheck:
	li $v0, 32		# sleep
	li $a0, 100
	syscall
	
	lw $k0, 0xffff0000
	beq $k0, 0, startKeyCheck
	
	lw $k1, 0xffff0004		# s is clicked, start game
	bne $k1, 0x73, startKeyCheck

### INITIALIZATION END ###

### Move Doodle ###
doodleJumpInit:
	li $t1, 0		# counter for distance up and down
	add $t0, $s0, $zero

doodleJumpUp:
	jal drawScore	# update the score after all the redrawing

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
	
	j doodleJumpDown	# continue down	

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
	li $t5, 0		# counter for platform length
	
	#sub $k1, $t3, $gp

checkOnPlatform:
	beq $t3, $s5, onPlatform	# check entire length of platform (length of 6)
	addi $t3, $t3, 4
	
	addi $t5, $t5, 1		# platform length counter
	bne $t5, 6, checkOnPlatform	
	
	addi $t4, $t4, 4	# increment offset
	addi $t2, $t2, 1	# incrememnt platform counter
	bne $t2, 8, checkOnPlatformInit 
	
	j noPlatform
	
onPlatform:
	addi $sp, $sp, -4 	# save pointer back to checkPlatform
	sw $ra, 0($sp)
	
	sub $t8, $s5, $gp	# get number value of doodle
	addi $t9, $s7, 128	# end of the row ($s7 beginning of row)
	ble $t8, $s7, notSamePlatform		# before the row, skip
	blt $t8, $t9, endPlatformCheck		# after row and before next row, no shifting

notSamePlatform:
	addi $a3, $a3, 1 	# add to the score (jumped on platform)

	jal backdropShiftInit	# scroll the screen

	sub $s5, $s5, 128	# jump onto platform
	add $t0, $s0, $zero	# save background colour	

endPlatformCheck:
	li $t1, 0		# reset jump counter
	j doodleJumpUp
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4	# load pointer back to checkPlatform
	
	jr $ra

noPlatform:	
	jr $ra
	
### Background scroll ###
backdropShiftInit: # recolour the background
	li $t2, 0 		# loop counter
	add $t3, $gp, $zero	# base address for display
	
backdropShift:
	sw $s0, 0($t3) 		# save background colour at location
	add $t3, $t3, 4 	# increment to next pixel
	addi $t2, $t2, 1
	bne $t2, 1024, backdropShift	# 1024

platformShiftInit:	
	add $t4, $s3, $zero 	# load platform array
	li $t5, 0		# initialize platform counter
	
platformShiftDown:	# shift platforms down and store
	lw $t6, 0($t4)		# load platform location
	addi $t6, $t6, 128	# shift down
	
	ble $t6, 4096, continuePlatformShift	# skip generation of new top platform
	
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 128		# 1024/8 = 128
	syscall
	
	li $t9, 4		# calculate new top platform value
	mult $t9, $a0
	mflo $t6
	
continuePlatformShift:
	sw $t6, 0($t4)		# save new value to array
	
	addi $t4, $t4, 4	# increment offset to next value in array
	
	li $t8, 0		# reset display location
	add $t8, $gp, $t6
	
	li $t7, 0		# initialize platform length counter
	
platformShiftRight:	# draw the entire platform
	sw $s2, 0($t8)		# colour into display
	addi $t8, $t8, 4	# offset for rest of platform
	
	addi $t7, $t7, 1	# increment platform length counter
	bne $t7, 6, platformShiftRight
	
	addi $t5, $t5, 1		# increment platform counter
	bne $t5, 8, platformShiftDown	# 8 platforms at a time
	
	addi $s5, $s5, 128		# shift doodle position
	
	sub $t9, $s5, $gp	# get number value of doodle
	blt $t9, $s7, backdropShiftInit		# before the row, shift down more
	
	jr $ra

drawCharactersInit:	# take in $t9 for location, $s6 for character
	li $t7, 0		# row counter
	li $t6, 0		# column counter
	j drawCharacterRow

charIncrement:
	addi $t9, $t9, 4	# pixel offset
	addi $s6, $s6, 4	# array offset

drawCharacterRow:
	lw $t8 , 0($s6)		# load value from array
	addi $t7, $t7, 1	# increment row counter
	
	bne $t8, $zero, savePixel	
	beq $t7, 3, charNextRow		
	
	j charIncrement
	
savePixel:
	sw $s1, 0($t9)			# draw if not 0
	bne $t7, 3, charIncrement	# do it again if not end of row

charNextRow:
	addi $t9, $t9, 128		# add next row
	sub $t9, $t9, 12		# sub row values
	
	add $t6, $t6, 1		
	li $t7, 0			# reset row counter
	bne $t6, 5, charIncrement

	jr $ra

drawScore:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	li $k1, 0
	li $t9, 10
			# for 2 digits, this is first digit
drawFirstDigit:	
	div $a3, $t9
	mflo $v1
	
	li $k0, 0		# set to zero for first digit
	add $t9, $gp, $k0
	
	beq $v1, 0, drawZero
	beq $v1, 1, drawOne
	beq $v1, 2, drawTwo
	beq $v1, 3, drawThree
	beq $v1, 4, drawFour
	beq $v1, 5, drawFive
	beq $v1, 6, drawSix
	beq $v1, 7, drawSeven
	beq $v1, 8, drawEight
	beq $v1, 9, drawNine

drawSecondDigit:
	mfhi $v1		# for 2 digits, this is second digit
	li $k0, 16		# set to 12 for second digit
	add $t9, $gp, $k0
	
	beq $k1, 2, endScoreUpdate
	beq $v1, 0, drawZero
	beq $v1, 1, drawOne
	beq $v1, 2, drawTwo
	beq $v1, 3, drawThree
	beq $v1, 4, drawFour
	beq $v1, 5, drawFive
	beq $v1, 6, drawSix
	beq $v1, 7, drawSeven
	beq $v1, 8, drawEight
	beq $v1, 9, drawNine
		
drawZero:
	la $s6, zero
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawOne:					
	la $s6, one
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawTwo:					
	la $s6, two
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawThree:					
	la $s6, three
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawFour:					
	la $s6, four
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawFive:					
	la $s6, five
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawSix:					
	la $s6, six
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawSeven:					
	la $s6, seven
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawEight:					
	la $s6, eight
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawNine:					
	la $s6, nine
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit

endScoreUpdate:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra


Exit:
	li $t9, 0x10008520
	la $s6, B
	jal drawCharactersInit

	li $t9, 0x10008530
	la $s6, Y	
	jal drawCharactersInit
	
	li $t9, 0x10008540
	la $s6, E
	jal drawCharactersInit
	
	li $t9, 0x10008550
	la $s6, exclaim
	jal drawCharactersInit
	
	li $v0, 10 # terminate the program gracefully
	syscall
