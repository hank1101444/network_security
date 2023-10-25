.data
str1: .string "s1101444\n"
str2: .string "\nmagic numbers are : "
str3: .string "\nanswer="
str4: .string "\nNO Answer!!" 
str5: .string "X X X "
_n: .string "\n"
comma: .string ","
d1: .string "input divisor 1:"
d2: .string "input divisor 2:"
d3: .string "input divisor 3:"
r1: .string "input remainder 1:"
r2: .string "input remainder 2:"
r3: .string "input remainder 3:"


.text
main:
	la a0, str1
	li a7, 4
	ecall 
	la a0, d1
	li a7, 4
	ecall
	li a7, 5	# input d1
	ecall
	mv s0, a0
	
	
	la a0, d2
	li a7, 4
	ecall
	li a7, 5	# input d2
	ecall
	mv s1, a0
	
	
	la a0, d3
	li a7, 4
	ecall
	li a7, 5	# input d3
	ecall
	mv s2, a0
	
	
	la a0, r1
	li a7, 4
	ecall
	li a7, 5	# input r1
	ecall
	mv s3, a0
	bge s3, zero, input_r2	# if r1 < 0 append d1
	add s3, s3, s0
	
input_r2:
	la a0, r2
	li a7, 4
	ecall
	li a7, 5	# input r2
	ecall
	mv s4, a0
	bge s4, zero, input_r3	# if r2 < 0 append d2
	add s4, s4, s1
input_r3:
	la a0, r3
	li a7, 4
	ecall
	li a7, 5	# input r3
	ecall
	mv s5, a0
	bge s5, zero, op	# if r3 < 0 append d3
	add s5, s5, s2
op:	# calculate the LCM, ans = lcm(lcm(m1, m2), m3); for three digits
	mv a1, s0	 # let a1 = a
	mv a2, s1	# let a2 = b
	jal gcd
	# calculate lcm(d0, d1)
	mul t0, s0, s1	# t0 = d1 * d2
	div a0, t0, a1	#  a0 = (d1 * d2) / gcd (d1, d2) {lcm(d0, d1)}
	
	
	mv a1, a0 # a1 = a0 (temp_lcm) 
	mv a2, s2 # a2 = d3
	jal gcd
	mul t0, a0, s2	# a0  = lcm(d1, d2), s2 = d3
	div a0, t0, a1	# lcm
	mv s9, a0 #result_lcm

check_multiple:
	# if any two digeits have multiple relationship jump to multiple_case {3 * 2 cases}
	rem t0, s0, s1
	beq t0, zero, multiple_case
	rem t0, s1, s0
	beq t0, zero, multiple_case
	rem t0, s1, s2
	beq t0, zero, multiple_case
	rem t0, s2, s1
	beq t0, zero, multiple_case
	rem t0, s0, s2
	beq t0, zero, multiple_case
	rem t0, s2, s0
	beq t0, zero, multiple_case


	li s6, 0	# init magic (s6 ~ s8)
	li s7, 0
	li s8, 0
	li t0, 0	# t0  = i
	li a4, 1	# a4 = 1
	
	# s0 ~ s2 = divisor�A s3 ~ s5 = remainder�As6~s9 = magic * 3, result_lcm �Aa1�Ba2, a�Bb

### get_magic ###
#    while ((magic1 % num1 != 1) || (magic2 % num2 != 1) || (magic3 % num3 != 1)) {
#       i++;
#      if (magic1 % num1 != 1)
#         magic1 = num2 * num3 * i;
#`    if (magic2 % num2 != 1)
#            magic2 = num1 * num3 * i;
#      if (magic3 % num3 != 1)
#            magic3 = num1 * num2 * i;
#   }

get_magic:	# t1 ~ t3 ->  magic(i) % numi
	rem t1, s6, s0
	rem t2, s7, s1
	rem t3, s8, s2
	addi t0, t0, 1	# i += 1
	bne t1, a4, magic1_renew
L2:
	bne t2, a4, magic2_renew
L3:
	bne t3, a4, magic3_renew
	j keep

magic1_renew:
	mul s6, s1, s2
	mul s6, s6, t0
	j L2
magic2_renew:
	mul s7, s0, s2
	mul s7, s7, t0
	j L3
magic3_renew:
	mul s8, s0, s1
	mul s8, s8, t0
	j keep
keep:
	bne t1, a4, get_magic	# if t1 != 1 continue
	bne t2, a4, get_magic	# if t2 != 1 continue
	bne t3, a4, get_magic	# if t3 != 1 continue
	j answer

gcd:
	beq a2, zero, back2ra	# b == 0 return a
	rem t0, a1, a2	# t0 = a % b
	mv a1, a2	# a = b
	mv a2, t0	# b = a % b
	j gcd
	
back2ra:
	ret

# s0 ~ s2 = divisor�A s3 ~ s5 = remainder�As6~s9 = magic * 3, result_lcm �Aa1�Ba2, a�Bb
multiple_case:
	li t0, -1	# t0 = i
	li a1, 0	# a1 = dividend
mul_loop:
	addi t0, t0, 1
	beq t0, s9, No_magic_op_lcm # no ans, still need to op lcm
	rem t1, t0, s0	
	bne t1, s3, mul_loop
	rem t1, t0, s1
	bne t1, s4, mul_loop
	rem t1, t0, s2
	bne t1, s5, mul_loop 
	add a1, t0, zero	#  if (i % m1 == a1 && i % m2 == a2 && i % m3 == a3) {result = i }

No_magic_op_lcm:	
	la a0, str2	# op "nmagic numbers are : "
	li a7, 4
	ecall
	la a0, str5	# op X X X
	li a7, 4
	ecall
	mv a0, s9	# op lcm
	li a7, 1
	ecall
break:
	beq a1, zero, no_answer	# if a1(result) == 0 -> no answer
	
	la a0, str3	# op "\nanswer="
	li a7, 4
	ecall
	mv a0, a1	# op dividend
	li a7, 1
	ecall
	j end
	
no_answer:	# NO ans case
	la a0, str4
	li a7, 4
	ecall 
	j end
	
answer:	# s0 ~ s2 = divisor�A s3 ~ s5 = remainder�As6~s9 = magic * 3, result_lcm �Aa1�Ba2, a�Bb
	la a0, _n
	li a7, 4
	ecall
	
	la a0, str2
	li a7, 4
	ecall 
	mv a0, s6
	li a7, 1
	ecall
	la a0, comma
	li a7, 4
	ecall
	mv a0, s7
	li a7, 1
	ecall
	la a0, comma
	li a7, 4
	ecall
	mv a0, s8
	li a7, 1
	ecall
	la a0, comma
	li a7, 4
	ecall
	
	mv a0, s9
	li a7, 1
	ecall
	
	la a0, str3
	li a7, 4
	ecall
	
	mul t0, s3, s6	# t0 = all
	mul t1, s4, s7 
	mul t2, s5, s8
	add t3, t0, t1
	add t3, t3, t2
	rem t3, t3, s9
	
	mv a0, t3
	li a7, 1
	ecall

end:	# end program
	li a7,  10
	ecall
