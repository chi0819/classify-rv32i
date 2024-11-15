.globl argmax

.text
# =================================================================
# FUNCTION: Maximum Element First Index Finder
#
# Scans an integer array to find its maximum value and returns the
# position of its first occurrence. In cases where multiple elements
# share the maximum value, returns the smallest index.
#
# Arguments:
#   a0 (int *): Pointer to the first element of the array
#   a1 (int):  Number of elements in the array
#
# Returns:
#   a0 (int):  Position of the first maximum element (0-based index)
#
# Preconditions:
#   - Array must contain at least one element
#
# Error Cases:
#   - Terminates program with exit code 36 if array length < 1
# =================================================================
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


handle_error:
    li a0, 36
    j exit
