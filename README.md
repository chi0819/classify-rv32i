# Assignment 2: Classify

# Part A
## ReLU
Check the current number is greater 0 or not  
If the number smaller than 0 then store 0 to the array  
```assembly
loop_start:
    lw t2, 0(a0)
    bge t2, zero, next
    sw zero, 0(a0)
next:
    addi a1,a1, -1
    addi a0, a0, 4
    blt zero, a1, loop_start
return:
    ret
```

## Argmax
Check the number if smaller than current largest number  
Here use `bge` because we want to find the smallest index of largest number  
Use `mv` to store return value to register `a1` and set `a0` with 10 (exit)  
Call ecall to exit the function  
```assembly
loop_start:
    addi a0, a0, 4
    lw t3, 0(a0)
    bge t0, t3, next
    mv t0, t3
    mv t1, t2
next:
    addi t2, t2, 1
    blt t2, a1, loop_start
return:
    mv a1, t1
    li a0, 10
    ecall
```

## Dot
Because we can't use RV32M extension instruction like `mul`  
Use `andi` to check multiplicand LSB, store the result to `t4`  
If `t4` is 1 then add `t2` to `t0`  
Then shift multiplier right 1 and shift left multiplicand 1  
This method is like long multiplication  
```assembly
loop_start:
    bge t1, a2, loop_end
    lw t2, 0(a0)
    lw t3, 0(a1)
loop_mul:
    andi t4, t3, 1
    beqz t4, end_mul
    add t0, t0, t2
end_mul:
    slli t2, t2, 1
    srli t3, t3, 1
    bnez t3, loop_mul
finished_mul:
    add a0, a0, a3
    add a1, a1, a2
    addi t1, t1, 1
loop_end:
    mv a1, t0
    li a0, 10
    ecall
```

## Matrix Multiplication

**Arguments**
- First Matrix (M0)
    - `a0`: Memory address of first element
    - `a1`: Row count
    - `a2`: Column count
- Second Matrix (M1)
    - `a3`: Memory address of first element
    - `a4`: Row count
    - `a5`: Column count
- Output Matrix (D)
    - `a6`: Memory address for result storage
- outer loop counter: `s0`
- inner loop counter: `s1`
```assembly
inner_loop_end:
    addi s0, s0, 1
    add s3, s3, a2
    addi s4, s4, 1
    blt s0, a5, outer_loop_start
outer_loop_end:
    li a0, 10
    ecall
```
