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

displayAddress:	.word	0x10008000

# Colours
backgroundColour:	.word	0xc2e6ec 	# blue
doodleColour:		.word	0x745185 	# purple
platformColour:		.word	0x74bea7	# green

# Controls (ASCII numbers)
direction:	.word 0
left:		.word 74	# j
right:		.word 75	# k

# Objects
platforms:	.space 	26	# 4 * 6
platformLength:	.word 	5


.text
main:
### Fill background
	lw $a0, pixel		# 1024
	lw $a1, backgroundColour

	li $t0, 0 		# loop counter
	lw $t1, displayAddress	# base address for display

backgroundFill:
	sw $a1, 0($t1) 		# save background colour at location
	add $t1, $t1, 4 	# increment to next pixel
	addi $t0, $t0, 1
	bne $t0, $a0, backgroundFill	# 1024
	

### Draw platforms
initPlatforms:
	la $t9, platforms	# load space for platform array
	li $t8, 0		# counter for # of platforms
	li $t7, 0		# offset shifts for platform array

platformPrep:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 1024		# 1024/4
	syscall
	
	add $t6, $t9, $t7
	sw $a0, 0($t6)		# store into memory (array)
	addi $t7, $t7, 4	# update platform array offset
	
	lw $a3, platformLength
	lw $t4, platformColour

	li $t0, 0 		# loop counter
	lw $t1, displayAddress	# base address for display
	
loadPlatformLocation:
	li $t5, 4		# multiplier
	
	mult $t5, $a0		# RNG * 4 (so multiple of 4)
	mflo $a1
	
	add $t1, $t1, $a1	# load rng location

drawPlatform:
	sw $t4, 0($t1) 			# save platform colour at location
	add $t1, $t1, 4 		# increment to next pixel horizontal
	addi $t0, $t0, 1
	bne $t0, $a3, drawPlatform	# platform length is 5
	
	addi $t8, $t8, 1		# increment to next platform
	bne $t8, 6, platformPrep	# loop to generate another platform (6 times)


Exit:
	li $v0, 10 # terminate the program gracefully
	syscall


