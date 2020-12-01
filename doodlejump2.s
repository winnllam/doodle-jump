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

platformPrep:
	li $v0, 42		# RNG for platform locations
	li $a0, 0		# number stored into $a0
	li $a1, 128		# 1024/4
	syscall
	
	add $a0, $a0, $t2 	# add section offset for platform
	addi $t2, $t2, 128
	
	add $t6, $s3, $t1
	addi $t1, $t1, 4	# update platform array offset

	li $t5, 0 		# loop counter
	
loadPlatformLocation:
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
	bne $t0, 7, platformPrep	# loop to generate another platform (7 times)
	
	addi $t7, $s5, 120
	li $t5, 0
	
drawStartingPlatform:		
	sw $s2, 0($t7)			# 8th platform initialized to below doodle
	addi $t5, $t5, 1
	addi $t7, $t7, 4
	bne $t5, $s4, drawStartingPlatform
	