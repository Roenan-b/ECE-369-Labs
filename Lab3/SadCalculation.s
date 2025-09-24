SAD_subroutine:
    # Load window size and frame base addresses
    # Loop through the window size and compute SAD

    move $t0, $a0         # Frame start address
    move $t1, $a1         # Reference frame start address
    li   $t2, 0           # Initialize SAD to 0

    loop_SAD:
        # Load pixel from current frame
        lb   $t3, 0($t0)
        # Load corresponding pixel from reference frame
        lb   $t4, 0($t1)

        # Compute absolute difference
        sub  $t5, $t3, $t4
        abs  $t5          # Calculate the absolute value

        # Add to SAD
        add  $t2, $t2, $t5

        # Update pointers to the next pixels
        addi $t0, $t0, 1
        addi $t1, $t1, 1

        # Check if done with the block
        bne  $t0, $block_end, loop_SAD

    # Return SAD in $v0
    move $v0, $t2
    jr   $ra
