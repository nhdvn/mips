.data
mystring: .space 1024
TIME: .space 1024
temp: .space 1024
month: .asciiz "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Noc Dec "
endline: .ascii "\r\n"
.text
_main:
	li $a0, 13
	li $a1, 12
	li $a2, 2000
	la $a3, TIME
	jal _Date
	la $a0, ($v0)
	li $a1, 1
	jal _Convert
	la $a0, ($v0)
	li $v0, 4
	syscall
	li $v0, 10
	syscall
	
#Procedure to write a number into a string buffer
_NumToString:	#Positive number only	$a0: num	$a1:buffer
	addi $t0, $0, 10	#t0 = 10
	addi $t8, $a0, 0	#t8 : quotient
	addi $t9, $0, 0		#t9: remainder
	addi $t1, $zero, 0	#counter = 0
	NumToString.loop:
		beqz $t8, NumToString.write	#quotient = 0 then out loop and write
		addi $t1, $t1, 1		#counter++
		div $t8, $t0			
		mflo $t8
		mfhi $t9
		addi $sp, $sp, -4
		sw $t9, 0($sp)			#store remainder into stack
		j NumToString.loop
	NumToString.write:	#write counter characters from stack
		la $t3, ($a1)
		write.loop: 
			addi $t1, $t1, -1
			lw $t2, 0($sp)
			addi $sp, $sp, 4
			addi $t2, $t2, 48
			sb $t2, 0($t3)
			addi $t3, $t3, 1
			beqz $t1, write.out
			j write.loop
		write.out:
			sb $zero, 0($t3)
			la $v0, ($a1)
			jr $ra

#Procedure to print string TIME as dd/mm/yyyy
_Date:	#$a0: day	$a1: month	$a2: year	$a3: TIME	$v0: address of the final string
	li $t0, 10			#10
	la $s0, ($a3)	
	slt $t1, $a0, $t0 		#if day < 10 then write '0' to buffer
	beq $t1, $zero, Date.L1
	li $t2, 48			#character '0'
	sb $t2, 0($s0)
	addi $s0, $s0, 1
	
Date.L1:				#call _NumToString to write day to buffer
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a1, 0($sp)
	la $a1, ($s0)
	jal _NumToString
	lw $a1, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	li $t3, 47			#write '/'
	sb $t3, 2($a3)
	la $s0, 3($a3)
	li $t0, 10			#if month < 10 then write '0' to buffer
	slt $t1, $a1, $t0
	beq $t1, $zero, Date.L2
	li $t2, 48
	sb $t2, 0($s0)
	addi $s0, $s0, 1
	
Date.L2:				#call _NumToString to write day to buffer
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)
	add $a0, $a1, $zero
	la $a1, ($s0)
	jal _NumToString
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	li $t3, 47			#write '/'
	sb $t3, 5($a3)
	la $s0, 6($a3)
	addi $sp, $sp, -12		#call _NumToString to write year
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)
	add $a0, $a2, $zero
	la $a1, ($s0)
	jal _NumToString
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	la $v0, ($a3)
	jr $ra

#Procedure Convert
_Convert: 	#a0: address of string TIME	#a1: type -> 0: MM/DD/YYYY	1: Month DD, YYYY	2: DD Month, YYYY	#v0: address of final string
	la $t0, mystring
	la $t7, ($a0)
Convert.copy: #copy from TIME to mystring
	lb $t1, 0($t7)
	sb $t1, 0($t0)
	addi $t7, $t7, 1
	addi $t0, $t0, 1
	beq $t1, $zero, Convert.outcopy
	j Convert.copy
Convert.outcopy:	
	la $t0, mystring
Convert.case0:
	bne $a1, $zero, Convert.case1
	lb $t1, 0($a0)
	sb $t1, 3($t0)
	lb $t1, 1($a0)
	sb $t1, 4($t0)
	lb $t1, 3($a0)
	sb $t1, 0($t0)
	lb $t1, 4($a0)
	sb $t1, 1($t0)
	j Convert.out
Convert.case1:
	li $t1, 1
	bne $a1, $t1, Convert.case2
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _Month
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)
	la $a1, ($t0)
	add $a0, $v0, $zero
	jal _WriteMonthToString
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	lw $ra, 8($sp)
	addi $sp, $sp, 12
	lb $t1, 0($a0)
	sb $t1, 4($t0)
	lb $t1, 1($a0)
	sb $t1, 5($t0)
	j Convert.outcase
Convert.case2:
	li $t1, 2
	bne $a1, $t1, Convert.out
	li $t1, ' '
	sb $t1, 2($t0)
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _Month
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	addi $sp, $sp, -12
	sw $ra, 8($sp)
	sw $a1, 4($sp)
	sw $a0, 0($sp)
	la $a1, 3($t0)
	add $a0, $v0, $zero
	jal _WriteMonthToString
	lw $ra, 8($sp)
	lw $a1, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 12
	j Convert.outcase
Convert.outcase:
	li $t1, ','
	sb $t1, 6($t0)
	li $t1, ' '
	sb $t1, 7($t0)
	lh $t1, 6($a0)
	sh $t1, 8($t0)
	lh $t1, 8($a0)
	sh $t1, 10($t0)
Convert.out:
	la $v0, ($t0)
	jr $ra

_WriteMonthToString: #	$a0: value of month 1-12	$a1: buffer to write to		$v0: address of final string
	sll $t7, $a0, 2
	addi $t7, $t7, -4
	la $t8, month
	add $t8, $t8, $t7
	lb $t9, 0($t8)
	sb $t9, 0($a1)
	lb $t9, 1($t8)
	sb $t9, 1($a1)
	lb $t9, 2($t8)
	sb $t9, 2($a1)
	lb $t9, 3($t8)
	sb $t9, 3($a1)
	la $v0, ($a1)
	jr $ra
		
	
_Month: #get month from string TIME		$a0: address of string TIME	$v0: value of month (1-12)
	lb $t7, 3($a0)
	addi $t7, $t7, -48
	li $t8, 10
	mult $t7, $t8
	mflo $v0
	lb $t7, 4($a0)
	addi $t7, $t7, -48
	add $v0, $v0, $t7
	jr $ra
	
_Day: #get day from string TIME			$a0: address of string TIME	$v0: value of day (1-31)
	lb $t7, 0($a0)
	addi $t7, $t7, -48
	li $t8, 10
	mult $t7, $t8
	mflo $v0
	lb $t7, 1($a0)
	addi $t7, $t7, -48
	add $v0, $v0, $t7
	jr $ra
	
_Year: #get year from string TIME		$a0: address of string TIME	$v0: value of year
	lb $t7, 6($a0)
	addi $t7, $t7, -48
	li $t8, 10
	mult $t7, $t8
	mflo $v0
	lb $t7, 7($a0)
	addi $t7, $t7, -48
	add $v0, $v0, $t7
	mult $v0, $t8
	mflo $v0
	lb $t7, 8($a0)
	addi $t7, $t7, -48
	add $v0, $v0, $t7
	mult $v0, $t8
	mflo $v0
	lb $t7, 9($a0)
	addi $t7, $t7, -48
	add $v0, $v0, $t7
	jr $ra

_LeapYear: #	$a0: address of string TIME	$v0: 1 -> leap	0 -> not leap
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _Year
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	add $t0, $v0, $zero
	li $v0, 0
	li $t7, 4
	div $t0, $t7
	mfhi $t1
	bne $t1, $zero, LeapYear.L1
	li $t7, 100
	div $t0, $t7
	mfhi $t1
	beq $t1, $zero, LeapYear.L1
	li $v0, 1
LeapYear.L1:
	li $t7, 400
	div $t0, $t7
	mfhi $t1
	bne $t1, $zero, LeapYear.L2
	li $v0, 1
LeapYear.L2:
	jr $ra