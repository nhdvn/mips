.data
mystring: .space 1024
TIME: .space 1024
TIME1: .space 1024
temp: .space 1024
month: .asciiz "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec "
day: .asciiz "Sun Mon Tues Wed Thurs Fri Sat "
empty: .asciiz ""
endline: .ascii "\r\n"
.text
_main:

	li $a0, 29
	li $a1, 2
	li $a2, 2000
	la $a3, TIME
	jal _Date

	li $a0, 28
	li $a1, 2
	li $a2, 2001
	la $a3, TIME1
	jal _Date

	la $a0, TIME
	la $a1, TIME1
	jal _GetTime
	
	la $a0, ($v0)
 	li $v0, 1
 	syscall
	
	la $a0, endline
	li $v0, 4
	syscall
	
	la $a1, empty # clear string buffer to store new value
	la $a0, TIME
	jal _Weekday
	
	la $a0, ($v0)
	li $v0, 4
	syscall
	
	li $v0, 10
	syscall
	
_GetTime: # $a0: address of string TIME	$a1: address of string TIME1		$V0: interger >= 0
	addi $sp, $sp, -4 #save $ra
	sw $ra, 0($sp)
	
 	la $a0, ($a0) #$t0 = day, $t1 = month, $t2 = year
 	jal _Day
 	la $t0, ($v0)
 	jal _Month
 	la $t1, ($v0)
 	jal _Year
 	la $t2, ($v0)
 	
 	la $a0, ($a1) #$t3 = day1, $t4 = month1, $t5 = year1
 	jal _Day
 	la $t3, ($v0)
 	jal _Month
 	la $t4, ($v0)
 	jal _Year
 	la $t5, ($v0)
 	
 	sub $t6, $t5, $t2
 	slt $t7, $zero, $t6
 	bne $t7, $0, GetTime.skip #if (year1 <= year) return 0
 		add $v0, $zero, $zero
 		lw $ra, 0($sp)
 		addi $sp, $sp, 4
		jr $ra
 	GetTime.skip: #means year1 > year
 		slt $t7, $t4, $t1
 		beq $t7, $0, GetTime.skip1 #if(month1 < month) return $t6 - 1
 			subi $v0, $t6, 1
 			lw $ra, 0($sp)
			addi $sp, $sp, 4
			jr $ra
 		GetTime.skip1:
 			slt $t7, $t1, $t4 # if(month > month1) return $t6
 			beq $t7, $0, GetTime.skip2
 				add $v0, $t6, $zero
 				lw $ra, 0($sp)
				addi $sp, $sp, 4
				jr $ra
			GetTime.skip2: #means month = month1, year = year1
				slt $t7, $t3, $t0
				bne $t7, $0, GetTime.skip3 #if(day1 > day0) return $t6
					add $v0, $t6, $zero
 					lw $ra, 0($sp)
					addi $sp, $sp, 4
					jr $ra
				GetTime.skip3:
					bne $t0, 29, GetTime.skip4 # if(day0 = 29 && day1 = 28, month = 2) return $t6
					bne $t3, 28, GetTime.skip4
 					bne $t4, 2, GetTime.skip4
 						add $v0, $t6, $zero
 						lw $ra, 0($sp)
						addi $sp, $sp, 4
						jr $ra
					GetTime.skip4:	#means day1 < day0 return $t6 - 1
						sub $v0, $t6, 1
 						lw $ra, 0($sp)
						addi $sp, $sp, 4
						jr $ra 	

	
#Procedure to write a number into a string buffer
_NumToString:	#Unsigned number only	$a0: num	$a1:buffer
	addi $t0, $0, 10	#t0 = 10
	addi $t8, $a0, 0	#t8 : quotient
	addi $t9, $0, 0		#t9: remainder
	addi $t1, $zero, 0	#counter = 0
	NumToString.loop:
		addi $t1, $t1, 1		#counter++
		div $t8, $t0			
		mflo $t8
		mfhi $t9
		addi $sp, $sp, -4
		sw $t9, 0($sp)			#store remainder into stack
		beq $t8, $zero, NumToString.write	#quotient = 0 then out loop and write
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
	li $t0, 1000
	li $t2, 48
	slt $t1, $a2, $t0
	beq $t1, $zero, Date.L3
	sb $t2, 0($s0)
	addi $s0, $s0, 1
	li $t0, 100
	slt $t1, $a2, $t0
	beq $t1, $zero, Date.L3
	sb $t2, 0($s0)
	addi $s0, $s0, 1
	li $t0, 10
	slt $t1, $a2, $t0
	beq $t1, $zero, Date.L3
	sb $t2, 0($s0)
	addi $s0, $s0, 1
Date.L3:	
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
	
_Weekday: # a0 address of TIME
	addi $sp, $sp, -4
	sw $ra, ($sp)

	la $a0, ($a0)
	jal _Day
 	la $t0, ($v0)
 	jal _Month
 	la $t1, ($v0)
 	jal _Year
 	la $t2, ($v0)
	addi $t9, $zero, 100
	div $t2, $t9 
	mfhi $t2 # last 2 digits of year
	mflo $t3 # first 2 digits of year
	beq $t2, $zero, Weekday.Keep
	addi $t3, $t3, 1 # if year not end with 00 -> century + 1
	Weekday.Keep:
	add $t8, $zero, $zero
	add $t8, $t8, $t0
	add $t8, $t8, $t1
	add $t8, $t8, $t2
	add $t8, $t8, $t3
	addi $t9, $zero, 4
	div $t2, $t9
	mflo $t4 # value of [y/4]
	add $t8, $t8, $t4
	addi $t9, $zero, 7
	div $t8, $t9
	mfhi $t8 # number represent day 
	beq $t8, $zero, Weekday.Final
	la $t9, ' '
	la $t7, day
	add $t6, $zero, $zero # count space char in string day
	Weekday.Loop:
		lb $t5, ($t7)
		bne $t5, $t9, Weekday.Continue # not space char
		addi $t6, $t6, 1 # next day, count by space char
		Weekday.Continue:
		addi $t7, $t7, 1 # next char
		beq $t6, $t8, Weekday.EndLoop
		j Weekday.Loop
	Weekday.EndLoop:
	la $t6, 0($a1) # store address to t6
	Weekday.Final:
		lb $t5, ($t7)
		beq $t5, $t9, Weekday.Out
		sb $t5, ($a1)
		addi $a1, $a1, 1
		addi $t7, $t7, 1
		j Weekday.Final
	Weekday.Out:
	la $v0, 0($t6) # return address

	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra






