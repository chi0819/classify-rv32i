# Assignment 2: Classify
## Part A
### Abs
Check if the value is positive or not. If the value is not positive, convert it to positive and write it back.
```assembly
abs:
    # Prologue
    ebreak
    # Load number from memory
    lw t0 0(a0)
    bge t0, zero, done    # If the value is positive, directly return

    # TODO: Add your own implementation
    sub t0, zero, t0      # Make the negative value become positive
    sw t0, 0(a0)          # Write back the value

done:
    # Epilogue
    jr ra
```

### ReLU
Simply check whether the value is negative or not. If the value is negative, store 0 back to the corresponding address.
```assembly
relu:
    li t0, 1
    blt a1, t0, error
    li t1, 0

loop_start:
    # TODO: Add your own implementation
    lw t2, 0(a0)
    bge t2, zero, next
    sw zero, 0(a0)   # If negative value then store 0
next:
    addi a1,a1, -1   # Decrease counter
    addi a0, a0, 4   # go to next value address
    blt zero, a1, loop_start  # If not last value then continue
return:
    ret
```

### Argmax
Use `t1` to store the current largest value. Use `t2` to record the current value's index and also to check whether the loop should continue. When comparing the current largest value and the current value, use `bge`. This is because if the current value is equal to the current largest value, we should use the current largest value's index as the `argmax` return value, as we want to find the largest value with the smallest index.
```assembly
argmax:
    li t6, 1
    blt a1, t6, handle_error

    lw t0, 0(a0)  # Record largest value

    li t1, 0            # Record largest value index
    li t2, 0            # Record current value index
    addi a1, a1, -1     # Due to 0 based
loop_start:
    # TODO: Add your own implementation
    beq a1, t2, return  # Compare current value index and number of elements
    addi t2, t2, 1      # Go to next value index
    addi a0, a0, 4      # Move to next value address
    lw t3, 0(a0)        # Load next value
    bge t0, t3, loop_start   # Check whether current value is bigger or not
swap:
    mv t0, t3  # Change largest value to current value
    mv t1, t2  # Change largest value index to current value index
    j loop_start  # Continue
return:
    mv a0, t1  # Set the return data as largest value index
    jr ra
```

### Dot
I encountered an error when handling the stride value because it uses byte addressing, so the offset is `$stride \times 4`. The stride defines how many steps are needed to move to the next element address. Here, I implemented the multiplication without using the `mul` instruction. I used the technique of long multiplication: Check whether the LSB of the multiplier is 1 or 0. If it is 1, add the multiplicand to the result. Then, right shift the multiplier by 1 bit and left shift the multiplicand by 1 bit. If the multiplier becomes 0, the multiplication is finished; otherwise, continue.
```assembly
dot:
    li t0, 1
    blt a2, t0, error_terminate
    blt a3, t0, error_terminate
    blt a4, t0, error_terminate

    li t0, 0           # record result
    li t1, 0           # record mul times
    slli a3, a3, 2     # byte address
    slli a4, a4, 2     # byte address

loop_start:
    bge t1, a2, loop_end
    # TODO: Add your own implementation
    lw t2, 0(a0)       # load data from array1[index * stride]
    lw t3, 0(a1)       # load data from array2[index * stride]
    bge t1, a2, loop_end   # dot finished
    add a0, a0, a3     # go to next value address array1 + index * stride
    add a1, a1, a4     # go to next value address array2 + index * stride
loop_mul:
    andi t4, t3, 1
    beqz t4, check_mul
    add t0, t0, t2
check_mul:
    slli t2, t2, 1
    srli t3, t3, 1
    bnez t3, loop_mul
end_mul:
    addi t1, t1, 1
    j loop_start

loop_end:
    mv a0, t0
    jr ra
```

### Matrix Multiplication
In the outer loop, move to the next row of the first matrix and the next column of the second matrix. I noticed that at the beginning of the function, the `Prologue` is used to store the saved registers on the stack, but there is no `Epilogue` to restore the saved registers from the stack. Therefore, I added an `Epilogue` block to handle this.
```assembly
matmul:
    # Error checks
    li t0 1
    blt a1, t0, error
    blt a2, t0, error
    blt a4, t0, error
    blt a5, t0, error
    bne a2, a4, error

    # Prologue
    addi sp, sp, -28
    sw ra, 0(sp)

    sw s0, 4(sp)
    sw s1, 8(sp)
    sw s2, 12(sp)
    sw s3, 16(sp)
    sw s4, 20(sp)
    sw s5, 24(sp)

    li s0, 0 # outer loop counter
    li s1, 0 # inner loop counter
    mv s2, a6 # incrementing result matrix pointer
    mv s3, a0 # incrementing matrix A pointer, increments durring outer loop
    mv s4, a3 # incrementing matrix B pointer, increments during inner loop

outer_loop_start:
    #s0 is going to be the loop counter for the rows in A
    li s1, 0
    mv s4, a3
    blt s0, a1, inner_loop_start

    j outer_loop_end

inner_loop_start:
# HELPER FUNCTION: Dot product of 2 int arrays
# Arguments:
#   a0 (int*) is the pointer to the start of arr0
#   a1 (int*) is the pointer to the start of arr1
#   a2 (int)  is the number of elements to use = number of columns of A, or number of rows of B
#   a3 (int)  is the stride of arr0 = for A, stride = 1
#   a4 (int)  is the stride of arr1 = for B, stride = len(rows) - 1
# Returns:
#   a0 (int)  is the dot product of arr0 and arr1
    beq s1, a5, inner_loop_end

    addi sp, sp, -24
    sw a0, 0(sp)
    sw a1, 4(sp)
    sw a2, 8(sp)
    sw a3, 12(sp)
    sw a4, 16(sp)
    sw a5, 20(sp)

    mv a0, s3 # setting pointer for matrix A into the correct argument value
    mv a1, s4 # setting pointer for Matrix B into the correct argument value
    mv a2, a2 # setting the number of elements to use to the columns of A
    li a3, 1 # stride for matrix A
    mv a4, a5 # stride for matrix B

    jal dot

    mv t0, a0 # storing result of the dot product into t0

    lw a0, 0(sp)
    lw a1, 4(sp)
    lw a2, 8(sp)
    lw a3, 12(sp)
    lw a4, 16(sp)
    lw a5, 20(sp)
    addi sp, sp, 24

    sw t0, 0(s2)
    addi s2, s2, 4 # Incrememtning pointer for result matrix

    li t1, 4
    add s4, s4, t1 # incrememtning the column on Matrix B

    addi s1, s1, 1
    j inner_loop_start

inner_loop_end:
    # TODO: Add your own implementation
    slli t0, a2, 2    # colum count = offset of row, slli 2 because byte address
    add s3, s3, t0    # go to next row of M0
    addi s0, s0, 1    # go to next column of M1
    j outer_loop_start
outer_loop_end:
    # Epilogue
    lw ra, 0(sp)
    lw s0, 4(sp)
    lw s1, 8(sp)
    lw s2, 12(sp)
    lw s3, 16(sp)
    lw s4, 20(sp)
    lw s5, 24(sp)
    addi sp, sp, 28
    jr ra
```

## Part B
In part B the assembly code only need implement `mul` instruction in RV32I  
Beside complete the homework, I try to understand the logic behind the teacher provided code
### Read Matrix
NEED EXPLAIN
### Write Matrix
NEED EXPLAIN
### Classify
NEED EXPLAIN

## Appendix
### Return from Callee
I misunderstand the `ecall` and `jr ra` in the part A  
So I use much time to debug the error when test classification  
- `ecall` : Do some system call, but in this homework, we should return back to caller
- `jr ra` : Jump back to the caller by register `ra`

### RISC-V Register Convention
| Register | Name    | Purpose                                         |
|----------|---------|-------------------------------------------------|
| `x0`     | `zero`  | Constant zero                                   |
| `x1`     | `ra`    | Return address                                  |
| `x2`     | `sp`    | Stack pointer                                   |
| `x3`     | `gp`    | Global pointer                                  |
| `x4`     | `tp`    | Thread pointer                                  |
| `x5-x7`  | `t0-t2` | Temporary registers                             |
| `x8`     | `s0/fp` | Saved register / frame pointer                  |
| `x9`     | `s1`    | Saved register                                  |
| `x10-x11`| `a0-a1` | Function arguments / return values              |
| `x12-x17`| `a2-a7` | Function arguments                              |
| `x18-x27`| `s2-s11`| Saved registers                                 |
| `x28-x31`| `t3-t6` | Temporary registers                             |

1. **Function Arguments**:
   - Arguments are passed in `a0-a7` (`x10-x17`).
   - If there are more than 8 arguments, the remaining are passed on the stack.

2. **Return Values**:
   - Return values are placed in `a0` and `a1` (`x10` and `x11`).

3. **Saved Registers**:
   - Registers `s0-s11` (`x8` and `x18-x27`) must be preserved across function calls. 
   - The callee must save and restore these registers if they are used.

4. **Temporary Registers**:
   - Registers `t0-t6` (`x5-x7` and `x28-x31`) are temporary and do not need to be preserved across function calls.

5. **Stack Pointer**:
   - The stack pointer (`sp`, `x2`) must be aligned to a 16-byte boundary before a function call.

6. **Return Address**:
   - The return address (`ra`, `x1`) is set by the caller before a function call. The callee uses this register to return to the caller.
