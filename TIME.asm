.data
mystring: .space 1024
TIME: .space 1024
TIME1: .space 1024
return: .space 100
monthcode: .word 0, 0, 3, 3, 6, 1, 4, 6, 2, 5, 0, 3, 5
centurycode: .word 4, 2, 0, 6
month: .asciiz "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec "
day: .asciiz "Sun Mon Tues Wed Thurs Fri Sat "
weekdaystr: .space 10
endline: .asciiz "\r\n"
dayinput: .space 4
monthinput: .space 4
yearinput: .space 6
reqday: .asciiz "Nhap ngay Day: "
reqmonth: .asciiz "Nhap thang Month: "
reqyear: .asciiz "Nhap nam Year: "
inputwarning: .asciiz "Nhap ngay sai, vui long nhap lai\r\n"
message: .asciiz "----------Ban hay chon 1 trong cac thao tac duoi day----------\r\n0. Thoat\r\n1. Xuat chuoi TIME theo dinh dang DD/MM/YYYY\r\n2. Chuyen doi chuoi TIME thanh mot trong cac dinh dang sau:\r\n\t0. MM/DD/YYYY\r\n\t1. Month DD, YYYY\r\n\t2. DD Month, YYYY\r\n3. Cho biet ngay vua nhap la ngay thu may trong tuan\r\n4. Kiem tra nam trong chuoi TIME co phai la nam nhuan khong\r\n5. Cho biet khoang thoi gian giua choi TIME_1 va TIME_2\r\n6. Cho biet 2 nam nhuan gan nhat voi nam trong chuoi TIME\r\n"
optioninputmsg: .asciiz "\r\nLua chon: "
optioninputwarning: .asciiz "\r\nLua chon khong ton tai, vui long nhap lai"
resultmsg: .asciiz "\r\nKet qua: "
option2inputmsg: .asciiz "\r\nLua chon (0, 1, 2): "
isLeapYearMsg: .asciiz "la nam nhuan"
notLeapYearMsg: .asciiz "khong la nam nhuan"

.text
_main:
	jal _InputDate
	lw $a0, 0($v0)
	lw $a1, 4($v0)
	lw $a2, 8($v0)
	la $a3, TIME
	jal _Date
	
	la $a0, message
	addi $v0, $zero, 4
	syscall
main.OptionLoop:
	la $a0, optioninputmsg
	syscall
	addi $v0, $zero, 12
	syscall
	add $t0, $zero, $v0
	
	addi $t1, $zero, 48
	beq $t0, $t1, main.Stop
	
	addi $t1, $zero, 49
	bne $t0, $t1, main.OutOpt1
	#Option 1
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	la $a0, TIME
	addi $v0, $zero, 4
	syscall
	j main.OptionLoop
main.OutOpt1:
	addi $t1, $zero, 50
	bne $t0, $t1, main.OutOpt2
	#Option 2
	Option2.Input:
	la $a0, option2inputmsg
	addi $v0, $zero, 4
	syscall
	addi $v0, $zero, 12
	syscall
	add $t0, $zero, $v0
	addi $t0, $t0, -48
	slt $t1, $t0, $zero
	bne $t1, $zero, Option2.L1
	addi $t1, $zero, 2
	slt $t1, $t1, $t0
	bne $t1, $zero, Option2.L1
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	add $a1, $zero, $t0
	la $a0, TIME
	jal _Convert
	la $a0, ($v0)
	addi $v0, $zero, 4
	syscall
	j main.OptionLoop
	Option2.L1:
	la $a0, optioninputwarning
	addi $v0, $zero, 4
	syscall
	j Option2.Input
main.OutOpt2:
	addi $t1, $zero, 51
	bne $t0, $t1, main.OutOpt3
	#Option 3
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	#process code below
	la $a0, TIME
	jal _Weekday
	la $a0, ($v0)
	addi $v0, $zero, 4
	syscall
	j main.OptionLoop
main.OutOpt3:
	addi $t1, $zero, 52
	bne $t0, $t1, main.OutOpt4
	#Option 4
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	la $a0, TIME
	jal _LeapYear
	beq $v0, $zero, Option4.L1
	la $a0, isLeapYearMsg
	j Option4.L2
	Option4.L1:
	la $a0, notLeapYearMsg
	Option4.L2:
	addi $v0, $zero, 4
	syscall
	j main.OptionLoop
main.OutOpt4:
	addi $t1, $zero, 53
	bne $t0, $t1, main.OutOpt5
	#Option 5
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	#process code below
	
	
	j main.OptionLoop
main.OutOpt5:
	addi $t1, $zero, 54
	bne $t0, $t1, main.OutOpt6
	#Option 6
	la $a0, resultmsg
	addi $v0, $zero, 4
	syscall
	#process code below
	j main.OptionLoop
main.OutOpt6:
	la $a0, optioninputwarning
	addi $v0, $zero, 4
	syscall
	j main.OptionLoop
	
main.Stop:	
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
			beq $t1, $zero, write.out
			j write.loop
		write.out:
			sb $zero, 0($t3)
			la $v0, ($a1)
			jr $ra

_StringToNum: #		$a0: address of string	$v0: number
	addi $v0, $zero, 0
	la $t2, ($a0)
StringToNum.Loop:
	lb $t0, 0($t2)
	beq $t0, $zero, StringToNum.Out
	addi $t7, $zero, 10
	beq $t0, $t7, StringToNum.Out
	addi $t2, $t2, 1
	addi $t0, $t0, -48
	addi $t1, $zero, 10
	mult $v0, $t1
	mflo $v0
	add $v0, $v0, $t0
	j StringToNum.Loop
StringToNum.Out:
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
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a0, 6($a0)
	jal _StringToNum
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
_IsLeapYear:	#	$a0: value of year	$v0: bool
	li $v0, 0
	li $t7, 4
	div $a0, $t7
	mfhi $t1
	bne $t1, $zero, IsLeapYear.L1
	li $t7, 100
	div $a0, $t7
	mfhi $t1
	beq $t1, $zero, IsLeapYear.L1
	li $v0, 1
IsLeapYear.L1:
	li $t7, 400
	div $a0, $t7
	mfhi $t1
	bne $t1, $zero, IsLeapYear.L2
	li $v0, 1
IsLeapYear.L2:
	jr $ra
	

_LeapYear: #	$a0: address of string TIME	$v0: 1 -> leap	0 -> not leap
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	jal _Year
	add $a0, $zero, $v0
	jal _IsLeapYear
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	jr $ra
	
_Weekday: # a0 address of TIME # (Year Code + Month Code + Century Code + Day Number – Leap Year Code) mod 7
	addi $sp, $sp, -4
	sw $ra, ($sp)
	la $a0, ($a0) # day number
	add $s7, $zero, $zero # result of the formular

	jal _Day
 	la $t0, ($v0)
	add $s7, $s7, $t0 # add day number

 	jal _Month
 	la $t1, ($v0) # month number
	addi $t9, $zero, 4 
	mult $t1, $t9
	mflo $t1 # true index of the month code (bytes address)
	la $t0, monthcode
	add $t0, $t0, $t1 # move adress to true index t1
	lw $t1, ($t0) # t1 = month code
	add $s7, $s7, $t1 # add month code

 	jal _Year
 	la $t2, ($v0)
	addi $t9, $zero, 100
	div $t2, $t9 
	mfhi $t2 # last 2 digits of year
	mflo $t3 # first 2 digits of year
	add $s7, $s7, $t2 # add year code

	addi $t9, $zero, 4
	div $t2, $t9
	mflo $t4 # value of [y/4]
	add $s7, $s7, $t4 # add [y/4] year code
	
	addi $t9, $zero, 17
	sub $t3, $t3, $t9
	addi $t9, $zero, 4
	div $t3, $t9
	mfhi $t3 # index of the century code
	addi $t9, $zero, 4 
	mult $t3, $t9
	mflo $t3 # true index of the century code (bytes address)
	la $t0, centurycode
	add $t0, $t0, $t3 # move adress to true index t3
	lw $t3, ($t0) # t3 = century code
	add $s7, $s7, $t3 # add century code

	jal _LeapYear
	beq $v0, $zero, Weekday.Skip # if is not leap year
	jal _Month
 	la $t1, ($v0) # month number
	addi $t2, $zero 3
	slt $t0, $t1, $t2
	beq $t0, $zero, Weekday.Skip # if is not Jan or Feb
	addi $s7, $s7, -1
	Weekday.Skip:

	addi $t9, $zero, 7
	div $s7, $t9
	mfhi $s7 # number represent weekday 

	la $t7, day
	la $t9, ' '
	beq $s7, $zero, Weekday.EndLoop

	add $t6, $zero, $zero # count space char in string day

	Weekday.Loop:
		lb $t5, ($t7)
		bne $t5, $t9, Weekday.Continue # not space char
		addi $t6, $t6, 1 # next day, count by space char
		Weekday.Continue:
		addi $t7, $t7, 1 # next char
		beq $t6, $s7, Weekday.EndLoop
		j Weekday.Loop
	Weekday.EndLoop:

	la $t6, weekdaystr # store address to t6

	Weekday.Final:
		lb $t5, ($t7)
		beq $t5, $t9, Weekday.Out
		sb $t5, ($t6)
		addi $t6, $t6, 1
		addi $t7, $t7, 1
		j Weekday.Final
	Weekday.Out:

	la $v0, weekdaystr # return address
	lw $ra, ($sp)
	addi $sp, $sp, 4
	jr $ra
	


_IsContainNonNumericCharacter:	#	$a0: string	$v0: bool
	la $t0, ($a0)
	addi $v0, $zero, 0
ICNNC.Loop:
	lb $t1, 0($t0)
	beq $t1, $zero, ICNNC.Out
	addi $t7, $zero, 10
	beq $t1, $t7, ICNNC.Out
	addi $t0, $t0, 1
	addi $t2, $zero, 48
	slt $t3, $t1, $t2
	bne $t3, $zero, ICNNC.True
	addi $t2, $zero, 57
	slt $t3, $t2, $t1
	bne $t3, $zero, ICNNC.True
	j ICNNC.Loop
ICNNC.True:
	addi $v0, $zero, 1
ICNNC.Out:
	jr $ra
	

_CheckDateInput:	#	$a0: string day		$a1: string month	$a2: string year	$v0: bool
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _IsContainNonNumericCharacter
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bne $v0, $zero, CheckDateInput.False
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a0, ($a1)
	jal _IsContainNonNumericCharacter
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	bne $v0, $zero, CheckDateInput.False
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a0, ($a2)
	jal _IsContainNonNumericCharacter
	lw $a0, 0($sp)
	lw $ra, 4($sp)
	addi $sp, $sp, 8
	bne $v0, $zero, CheckDateInput.False
#Get number value of day month year
	#day -> s0
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _StringToNum
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	add $s0, $zero, $v0
	#month -> s1
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a0, ($a1)
	jal _StringToNum
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
	add $s1, $zero, $v0
	#year -> s2
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	la $a0, ($a2)
	jal _StringToNum
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
	add $s2, $zero, $v0
	
	#check if year < 0
	slt $t0, $s2, $zero
	bne $t0, $zero, CheckDateInput.False
	
	addi $t0, $zero, 1
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 3
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 5
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 7
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 8
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 10
	beq $s1, $t0, CheckDateInput.Case31
	addi $t0, $zero, 12
	beq $s1, $t0, CheckDateInput.Case31
	j CheckDateInput.CheckCase30
CheckDateInput.Case31:
	slt $t0, $zero, $s0
	beq $t0, $zero, CheckDateInput.False
	addi $t1, $zero, 31
	slt $t0, $t1, $s0
	bne $t0, $zero, CheckDateInput.False
	j CheckDateInput.OutCase
CheckDateInput.CheckCase30:
	addi $t0, $zero, 4
	beq $s1, $t0, CheckDateInput.Case30
	addi $t0, $zero, 6
	beq $s1, $t0, CheckDateInput.Case30
	addi $t0, $zero, 9
	beq $s1, $t0, CheckDateInput.Case30
	addi $t0, $zero, 11
	beq $s1, $t0, CheckDateInput.Case30
	j CheckDateInput.CheckCase2
CheckDateInput.Case30:
	slt $t0, $zero, $s0
	beq $t0, $zero, CheckDateInput.False
	addi $t1, $zero, 30
	slt $t0, $t1, $s0
	bne $t0, $zero, CheckDateInput.False
	j CheckDateInput.OutCase
CheckDateInput.CheckCase2:
	addi $t0, $zero, 2
	beq $s1, $t0, CheckDateInput.Case2
	j CheckDateInput.False
CheckDateInput.Case2:
	slt $t0, $zero, $s0
	beq $t0, $zero, CheckDateInput.False
	addi $sp, $sp, -8
	sw $ra, 4($sp)
	sw $a0, 0($sp)
	add $a0, $zero, $s2
	jal _IsLeapYear
	lw $ra, 4($sp)
	lw $a0, 0($sp)
	addi $sp, $sp, 8
	beq $v0, $zero, Case2.28
	addi $t1, $zero, 29
	j Case2.2829
	Case2.28:
	addi $t1, $zero, 28
	Case2.2829:
	slt $t0, $t1, $s0
	bne $t0, $zero, CheckDateInput.False
CheckDateInput.OutCase:
	addi $v0, $zero, 1
	jr $ra
CheckDateInput.False:
	addi $v0, $zero, 0
	jr $ra
	
_InputDate:	#	v0: address of an array contain 3 integer value of day, month, year
InputDate.Loop:
	la $a0, reqday
	addi $v0, $zero, 4
	syscall 
	la $a0, dayinput
	addi $a1, $zero, 4
	addi $v0, $zero, 8
	syscall
	
	la $a0, reqmonth
	addi $v0, $zero, 4
	syscall 
	la $a0, monthinput
	addi $a1, $zero, 4
	addi $v0, $zero, 8
	syscall
	
	la $a0, reqyear
	addi $v0, $zero, 4
	syscall 
	la $a0, yearinput
	addi $a1, $zero, 6
	addi $v0, $zero, 8
	syscall
	
	la $a0, dayinput
	la $a1, monthinput
	la $a2, yearinput
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal _CheckDateInput
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	bne $v0, $zero, InputDate.Outloop
	la $a0, inputwarning
	addi $v0, $zero, 4
	syscall
	j InputDate.Loop
InputDate.Outloop:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, dayinput
	jal _StringToNum
	la $t0, return
	sw $v0, 0($t0)
	la $a0, monthinput
	jal _StringToNum
	la $t0, return 
	sw $v0, 4($t0)
	la $a0, yearinput
	jal _StringToNum
	la $t0, return
	sw $v0, 8($t0)
	la $v0, return
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	





