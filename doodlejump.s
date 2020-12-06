#####################################################################
#
# CSCB58 Fall 2020 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Winnie Lam, 1004971792
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8					     
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 512
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Fancier graphics
# 2. Boosting / Power ups
# 3. Dynamic on-screen notifications
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). 
#
# Any additional information that the TA needs to know:
# - Some luck is needed in the game due to random platform location spawns :)
# - Press S to start from start screen
# - Use p key for pause screen, s to start it up again
# - both Doodle legs need to be on platform!!!
#####################################################################

.data

# Display locations
doodleStart: 		.word	0x10009dc0
basePlatformRow:	.word	7552		# 0x10008e00 (3584)

# Anmiation delay
jumpDelay:	.word	90

# Colours
backgroundColour:	.word	0xc2e6ec
doodleColour:		.word	0x35427C
platformColour:		.word	0xF2F2F2
titleColour:		.word	0x35627C
infoColour:		.word	0x8FBDD8
white:			.word	0xffffff

# Controls (ASCII numbers)
left:		.word 0x6A	# j 
right:		.word 0x6B	# k
start:		.word 0x73	# s

# Objects
platforms:	.space 	32	# 4 byte * 8 platforms
platformLength:	.word 	8
doodle:		.word 	0, 0, 0, 0, 1, 0, 1, 1, 1, 1, 0, 1, 0, 0, 0
cloud1:		.word	0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0
cloud2:		.word	0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
cloud3:		.word	1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0
cloud4:		.word	0, 0, 0, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 0

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
D:		.word	1, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0
E:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1
J:		.word	0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1, 1, 1
L:		.word	1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 1, 1
M:		.word	1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1
P:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 0, 1, 0, 0
R:		.word	1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1
S:		.word	1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1
T:		.word	1, 1, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0
U:		.word	1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1
W:		.word	1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1
Y:		.word	1, 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 0
exclaim:	.word	0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0
smileLeft:	.word	0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 1, 1, 1
smileRight:	.word	0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1

### REGISTERS ###
# $a2 - score counter
# $a3 - score
# $s0 - background colour
# $s1 - doodle colour
# $s2 - platform colour
# $s3 - jumping speed
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
	lw $s3, jumpDelay
	lw $s4, platformLength
	lw $s5, doodleStart
	lw $s7, basePlatformRow

### Start screen ###
startBackground:
	jal backgroundFillInit
	jal cloudFillInit
	
	lw $s1, titleColour
	
	li $t9, 0x10008510		# spell doodle
	la $s6, D
	jal drawCharactersInit

	li $t9, 0x10008520
	la $s6, zero	
	jal drawCharactersInit
	
	li $t9, 0x10008530
	la $s6, zero
	jal drawCharactersInit
	
	li $t9, 0x10008540
	la $s6, D
	jal drawCharactersInit
	
	li $t9, 0x10008550
	la $s6, L
	jal drawCharactersInit
	
	li $t9, 0x10008560
	la $s6, E
	jal drawCharactersInit
	
	li $t9, 0x10008920		# spell jump
	la $s6, J
	jal drawCharactersInit
	
	li $t9, 0x10008930
	la $s6, U
	jal drawCharactersInit
	
	li $t9, 0x10008940
	la $s6, M
	jal drawCharactersInit
	
	li $t9, 0x10008950
	la $s6, P
	jal drawCharactersInit
	
	lw $s1, infoColour
	
	li $t9, 0x1000950c		# spell press s
	la $s6, P
	jal drawCharactersInit

	li $t9, 0x1000951c
	la $s6, R	
	jal drawCharactersInit
	
	li $t9, 0x1000952c
	la $s6, E
	jal drawCharactersInit
	
	li $t9, 0x1000953c
	la $s6, S
	jal drawCharactersInit
	
	li $t9, 0x1000954c
	la $s6, S
	jal drawCharactersInit
	
	li $t9, 0x10009568
	la $s6, S
	jal drawCharactersInit
	
startKeyCheck:
	li $v0, 32		# sleep
	li $a0, 100
	syscall
	
	lw $k0, 0xffff0000
	beq $k0, 0, startKeyCheck
	
	lw $k1, 0xffff0004		# s is clicked, start game
	bne $k1, 0x73, startKeyCheck
	
	j background

### Draw clouds ###
cloudFillInit:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	li $t0, 0		# counter for 8 clouds
	li $t1, 0		# counter for sections
	lw $s1, white
	
generateCloud:
	li $v0, 42		# RNG for cloud locations
	li $a0, 0		# number stored into $a0
	li $a1, 256		# 2048/4
	syscall
	
	add $a0, $a0, $t1
	addi $t1, $t1, 256
	
	li $t4, 4		# multiplier
	mult $t4, $a0		# RNG * 4 (so multiple of 4)
	mflo $a1
	
cloudFill:	
	add $t9, $gp, $a1
	la $s6, cloud1
	jal drawCharactersInit
	
	addi $a1, $a1, 12
	add $t9, $gp, $a1
	la $s6, cloud2
	jal drawCharactersInit
	
	addi $a1, $a1, 12
	add $t9, $gp, $a1
	la $s6, cloud3
	jal drawCharactersInit
	
	addi $a1, $a1, 12
	add $t9, $gp, $a1
	la $s6, cloud4
	jal drawCharactersInit
	
	addi $t0, $t0, 1
	bne $t0, 8, generateCloud
	
	lw $s1, doodleColour
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra

### Fill background ###
background:
	jal backgroundFillInit
	j initPlatforms

backgroundFillInit:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)

	li $t0, 0 		# loop counter
	add $t1, $gp, $zero
	
backgroundFill:
	sw $s0, 0($t1) 		# save background colour at location
	add $t1, $t1, 4 	# increment to next pixel
	
	addi $t0, $t0, 1
	bne $t0, 2048, backgroundFill	# 2048 pixels
	
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	jr $ra

### Draw platforms ###
initPlatforms:
	li $t0, 0		# counter for # of platforms
	li $t1, 0		# offset shifts for platform array
	li $t2, 0		# partition for platform locations

generateLocation:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 256		# 2048/4
	syscall
	
	add $a0, $a0, $t2 	# add section offset for platform
	addi $t2, $t2, 256
	
	la $t9, platforms
	add $t6, $t9, $t1
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
	li $a1, 8120		# platform pixel location
	la $t6, platforms
	addi $t6, $t6, 28
	sw $a1, 0($t6)			# save to last spot in array	
		
	addi $t7, $s5, 504		# shift down and left 2 from doodle location (128 - 4 - 4 = 120)
	li $t5, 0
	
drawStartingPlatform:		
	sw $s2, 0($t7)			# 8th platform initialized to below doodle
	addi $t5, $t5, 1
	addi $t7, $t7, 4
	bne $t5, $s4, drawStartingPlatform
	
	j drawStartingDoodle

### Draw doodle ###
drawDoodle:	#t9 for position
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		# add pointer to jump up to stack

	add $t9, $zero, $s5
	la $s6, doodle	
	jal drawCharactersInit	
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

### Clear location of doodle
clearDoodle:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	lw $s1, backgroundColour
	
	add $t9, $zero, $s5
	la $s6, doodle	
	jal drawCharactersInit
	
	lw $s1, doodleColour
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

drawStartingDoodle:
	jal drawDoodle
	
	li $a3, 0
	jal drawScore	# draw initial score of 0		

### INITIALIZATION END ###
	
### Move Doodle ###
doodleJumpInit:
	li $t1, 0		# counter for distance up and down
	add $t0, $s0, $zero

doodleJumpUp:
	jal drawScore	# update the score after all the redrawing
	jal clearDoodle
	
	sub $s5, $s5, 128	# up
	jal drawDoodle	
	jal moveDoodle
	
	addi $t1, $t1, 1
	
	li $v0, 32		# sleep to delay animation
	add $a0, $zero, $s3
	syscall
	
	jal keyCheck
	jal checkPlatforms
	
	bne $t1, 15, doodleJumpUp	# continue up
	
doodleJumpDown:
	jal clearDoodle
	
	addi $s5, $s5, 128	# down
	jal drawDoodle	
	jal moveDoodle
	
	sub $t1, $t1, 1
	
	li $v0, 32		# sleep to delay animation
	add $a0, $zero, $s3
	syscall
	
	jal keyCheck		# check for input while movement to continue
	jal checkPlatforms
	
	bge $s5, 0x1000a000, Exit
	
	j doodleJumpDown	# continue down	

### Pause game ###
pause:
	li $t9, 0x10008518		# spell doodle
	la $s6, P
	jal drawCharactersInit

	li $t9, 0x10008528
	la $s6, A	
	jal drawCharactersInit
	
	li $t9, 0x10008538
	la $s6, U
	jal drawCharactersInit
	
	li $t9, 0x10008548
	la $s6, S
	jal drawCharactersInit
	
	li $t9, 0x10008558
	la $s6, E
	jal drawCharactersInit
	
	j pauseWait

pauseWait:
	li $v0, 32		# sleep
	li $a0, 100
	syscall
	
	lw $k1, 0xffff0004		
	bne $k1, 0x73, pauseWait	# s is clicked, unpause game

	j doodleJumpInit

### Check for input ###
keyCheck:
	lw $k0, 0xffff0000
	beq $k0, 1, movementKeyPress
	
	jr $ra

movementKeyPress:
	lw $k0, 0xffff0004
	beq $k0, 0x73, main	# s for restart
	beq $k0, 0x70, pause	# p for pause
	
	beq $k0, 0x6A, moveDoodleLeft	# j
	beq $k0, 0x6B, moveDoodleRight	# k
	
	j doodleJumpInit		# not a movement key, continue looping
	
moveDoodleLeft:
	addi $sp, $sp, -4	# save jump location keyPress
	sw $ra, 0($sp)
	
	jal clearDoodle

	sub $s5, $s5, 8		# move left
	
	jal moveDoodle		# skip over moveDoodleRight
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
moveDoodleRight:
	addi $sp, $sp, -4	# save jump location keyPress
	sw $ra, 0($sp)
	
	jal clearDoodle
	
	add $s5, $s5, 8		
	
	jal moveDoodle
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

moveDoodle:	# colour saving and loading	
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	jal drawDoodle
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4 
	
	jr $ra

### Movement to platforms ###
checkPlatforms:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)		# add pointer to jump up to stack

	la $t4, platforms	# load platform location
	li $t2, 0		# initialize platform counter

	jal checkOnPlatformInit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

checkOnPlatformInit:
	lw $t3, 0($t4)		# load platform location
	add $t3, $t3, $gp	# $gp is same as displayAddress
	sub $t3, $t3, 512 	# add 3 rows to account for doodle
	li $t5, 0		# counter for platform length

checkOnPlatform:
	beq $t3, $s5, onPlatform	# check entire length of platform (length of 8)
	addi $t3, $t3, 4
	
	addi $t5, $t5, 1		# platform length counter
	bne $t5, $s4, checkOnPlatform	
	
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
	jal backdropShiftInit	# scroll the screen

	sub $s5, $s5, 128	# jump onto platform
	add $t0, $s0, $zero	# save background colour	

endPlatformCheck:
	j doodleJumpInit
	
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
	bne $t2, 2048, backdropShift	# 2048

platformShiftInit:
	la $t4, platforms	# load platform array
	li $t5, 0		# initialize platform counter
	
platformShiftDown:	# shift platforms down and store
	lw $t6, 0($t4)		# load platform location
	addi $t6, $t6, 128	# shift down
	
	ble $t6, 8192, continuePlatformShift	# skip generation of new top platform
	
	addi $a3, $a3, 1 	# add to the score (platform reached EOL)
	
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 256		# 2048/8 = 256
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
	bne $t7, $s4, platformShiftRight
	
	addi $t5, $t5, 1		# increment platform counter
	bne $t5, 8, platformShiftDown	# 8 platforms at a time
	
	addi $s5, $s5, 128		# shift doodle position
	
	sub $t9, $s5, $gp	# get number value of doodle
	blt $t9, $s7, backdropShiftInit		# before the row, shift down more
	
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	jal printWow
	jal shortenPlatformInit
	
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

### Draw characters on screen ###
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

### Draw score on screen ###
drawScore:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	li $k1, 0
	li $t9, 10
			
drawFirstDigit:	
	div $a3, $t9
	mflo $v1	# first digit
	
	addi $t9, $gp, 132
	
	j checkNumber

drawSecondDigit:
	mfhi $v1	# second digit
	addi $t9, $gp, 148

	j checkNumber

checkNumber:
	beq $k1, 2, endScoreUpdate	# went through first and second digit
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

drawNumber:
	jal drawCharactersInit
	
	addi $k1, $k1, 1
	j drawSecondDigit
	
drawZero:
	la $s6, zero
	j drawNumber	
	
drawOne:					
	la $s6, one
	j drawNumber
	
drawTwo:					
	la $s6, two
	j drawNumber
	
drawThree:					
	la $s6, three
	j drawNumber
	
drawFour:					
	la $s6, four
	j drawNumber
	
drawFive:					
	la $s6, five
	j drawNumber
	
drawSix:					
	la $s6, six
	j drawNumber
	
drawSeven:					
	la $s6, seven
	j drawNumber
	
drawEight:					
	la $s6, eight
	j drawNumber
	
drawNine:					
	la $s6, nine
	j drawNumber

endScoreUpdate:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

### Platform shortener ###
shortenPlatformInit:
	li $t9, 10
	div $a3, $t9
	mflo $v1	# grab first digit
	
	beq $v1, 0, noShorten	# starts with 0
	
	andi $t9, $v1, 1
	bne $t9, $zero, noShorten
	
	beq $a2, $v0, noShorten		# if multiple of 20 already subbed
	add $a2, $zero, $v0
	
	sub $s4, $s4, 1
	
noShorten:
	jr $ra
	
### Print WOW! ###
printWow:
	addi $sp, $sp, -4 	
	sw $ra, 0($sp)
	
	beq $a3, 0, noWow	# 0 has no wow
	
	li $t9, 10
	div $a3, $t9
	mfhi $v1
	
	bne $v1, 0, noWow	# no wow if not multiple of 10
	
	sub $s3, $s3, 5 	# update jump speed

	li $t9, 0x10008520	# draw wow
	la $s6, W
	jal drawCharactersInit

	li $t9, 0x10008530
	la $s6, zero	
	jal drawCharactersInit
	
	li $t9, 0x10008540
	la $s6, W
	jal drawCharactersInit
	
	li $t9, 0x10008550
	la $s6, exclaim
	jal drawCharactersInit

	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

noWow:
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

Exit:
	jal backgroundFillInit
	jal cloudFillInit
	
	lw $s1, titleColour
	
	li $t9, 0x10008920
	la $s6, B
	jal drawCharactersInit

	li $t9, 0x10008930
	la $s6, Y	
	jal drawCharactersInit
	
	li $t9, 0x10008940
	la $s6, E
	jal drawCharactersInit
	
	li $t9, 0x10008950
	la $s6, exclaim
	jal drawCharactersInit
	
	li $t9, 0x10008f30
	la $s6, smileLeft
	jal drawCharactersInit
	
	li $t9, 0x10008f3c
	la $s6, smileRight
	jal drawCharactersInit
	
	jal drawScore
	
	li $v0, 10	# terminate the program gracefully
	syscall
