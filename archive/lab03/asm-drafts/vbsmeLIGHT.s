# Fall 2025
# Team Members:    
# % Effort    :   
#
# ECE369A,  
# 

########################################################################################################################
### data
########################################################################################################################
.data
# test input
# asize : dimensions of the frame [i, j] and window [k, l]
#         i: number of rows,  j: number of cols
#         k: number of rows,  l: number of cols  
# frame : frame data with i*j number of pixel values
# window: search window with k*l number of pixel values
#
# $v0 is for row / $v1 is for column

# test 0 For the 4x4 frame size and 2X2 window size
# small size for validation and debugging purpose
# The result should be 0, 2
asize0:  .word    4,  4,  2, 2    #i, j, k, l
frame0:  .word    0,  0,  1,  2, 
         .word    0,  0,  3,  4
         .word    0,  0,  0,  0
         .word    0,  0,  0,  0, 
window0: .word    1,  2, 
         .word    3,  4, 

         
newline: .asciiz     "\n" 


########################################################################################################################
### main
########################################################################################################################

.text

.globl main

main: 
    addi    $sp, $sp, -4    # Make space on stack
    sw      $ra, 0($sp)     # Save return address
        # Start test 0
      ############################################################
    la      $a0, asize0     # 1st parameter: address of asize1[0]
    la      $a1, frame0     # 2nd parameter: address of frame1[0]
    la      $a2, window0    # 3rd parameter: address of window1[0] 
   
    jal     vbsme           # call function
    jal     print_result    # print results to console
         
    
################### Print Result ####################################
print_result:
    # Printing $v0
    add     $a0, $v0, $zero     # Load $v0 for printing
    li      $v0, 1              # Load the system call numbers
    syscall
   
    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
    syscall
   
    # Printing $v1
    add     $a0, $v1, $zero      # Load $v1 for printing
    li      $v0, 1                # Load the system call numbers
    syscall

    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
    syscall
   
    # Print newline.
    la      $a0, newline          # Load value for printing
    li      $v0, 4                # Load the system call numbers
    syscall
   
    jr      $ra                   #function return

#####################################################################
### vbsme
#####################################################################


# vbsme.s 
# motion estimation is a routine in h.264 video codec that 
# takes about 80% of the execution time of the whole code
# given a frame(2d array, x and y dimensions can be any integer 
# between 16 and 64) where "frame data" is stored under "frame"  
# and a window (2d array of size 4x4, 4x8, 8x4, 8x8, 8x16, 16x8 
# or 16x16) where "window data" is stored under "window" 
# and size of "window" and "frame" arrays are stored under 
# "asize"

# - initially current sum of difference is set to a very large value
# - move "window" over the "frame" one cell at a time starting with location (0,0)
# - moves are based on the defined search pattern 
# - for each move, function calculates  the sum of absolute difference (SAD) 
#   between the window and the overlapping block on the frame.
# - if the calculated sum of difference is LESS THAN OR EQUAL to the current sum of difference
#   then the current sum of difference is updated and the coordinate of the top left corner 
#   for that matching block in the frame is recorded. 

# for example SAD of two 4x4 arrays "window" and "block" shown below is 3  
# window         block
# -------       --------
# 1 2 2 3       1 4 2 3  
# 0 0 3 2       0 0 3 2
# 0 0 0 0       0 0 0 0 
# 1 0 0 5       1 0 0 4

# program keeps track of the window position that results 
# with the minimum sum of absolute difference. 
# after scannig the whole frame
# program returns the coordinates of the block with the minimum SAD
# in $v0 (row) and $v1 (col) 


# Sample Inputs and Output shown below:
# Frame:
#
#  0   1   2   3   0   0   0   0   0   0   0   0   0   0   0   0 
#  1   2   3   4   4   5   6   7   8   9  10  11  12  13  14  15 
#  2   3  32   1   2   3  12  14  16  18  20  22  24  26  28  30 
#  3   4   1   2   3   4  18  21  24  27  30  33  36  39  42  45 
#  0   4   2   3   4   5  24  28  32  36  40  44  48  52  56  60 
#  0   5   3   4   5   6  30  35  40  45  50  55  60  65  70  75 
#  0   6  12  18  24  30  36  42  48  54  60  66  72  78  84  90 
#  0   7  14  21  28  35  42  49  56  63  70  77  84  91  98 105 
#  0   8  16  24  32  40  48  56  64  72  80  88  96 104 112 120 
#  0   9  18  27  36  45  54  63  72  81  90  99 108 117 126 135 
#  0  10  20  30  40  50  60  70  80  90 100 110 120 130 140 150 
#  0  11  22  33  44  55  66  77  88  99 110 121 132 143 154 165 
#  0  12  24  36  48  60  72  84  96 108 120 132   0   1   2   3 
#  0  13  26  39  52  65  78  91 104 117 130 143   1   2   3   4 
#  0  14  28  42  56  70  84  98 112 126 140 154   2   3   4   5 
#  0  15  30  45  60  75  90 105 120 135 150 165   3   4   5   6 

# Window:
#  0   1   2   3 
#  1   2   3   4 
#  2   3   4   5 
#  3   4   5   6 

# cord x = 12, cord y = 12 returned in $v0 and $v1 registers

.text
.globl  vbsme

# Your program must follow the required search pattern.  

# Preconditions:
#   1st parameter (a0) address of the first element of the dimension info (address of asize[0])
#   2nd parameter (a1) address of the first element of the frame array (address of frame[0][0])
#   3rd parameter (a2) address of the first element of the window array (address of window[0][0])
# Postconditions:	
#   result (v0) x coordinate of the block in the frame with the minimum SAD
#          (v1) y coordinate of the block in the frame with the minimum SAD


# Begin subroutine
vbsme:  
    li      $v0, 0              # reset $v0 and $V1
    li      $v1, 0



    # Save ONLY the registers we'll modify
    addi    $sp, $sp, -32
    sw      $s0, 0($sp)     # asize address
    sw      $s1, 4($sp)     # frame address  
    sw      $s2, 8($sp)     # window address
    sw      $s3, 12($sp)    # frame rows (i)
    sw      $s4, 16($sp)    # frame cols (j)
    sw      $s5, 20($sp)    # window rows (k)
    sw      $s6, 24($sp)    # window cols (l)
    sw      $s7, 28($sp)    # min SAD value
    
    # Save parameters
    move    $s0, $a0
    move    $s1, $a1
    move    $s2, $a2
    
    # Load dimensions
    lw      $s3, 0($s0)     # frame rows (i)
    lw      $s4, 4($s0)     # frame cols (j)
    lw      $s5, 8($s0)     # window rows (k)
    lw      $s6, 12($s0)    # window cols (l)
    
    # Initialize min SAD and best position
    li      $s7, 0x7FFFFFFF
    li      $v0, 0
    li      $v1, 0
    
    # Calculate max valid positions
    sub     $t8, $s3, $s5    # max_row = frame_rows - window_rows
    sub     $t9, $s4, $s6    # max_col = frame_cols - window_cols
    addi    $t8, $t8, 1      # max_row = max_row + 1 for making the feasible search window
    addi    $t9, $t9, 1      # max_row = max_col + 1 for making the feasible search window
    # Diagonal search: d = row + col
    add     $t0, $t8, $t9    # total diagonals
    li      $t1, 0           # current diagonal
    
diag_loop:
    bgt     $t1, $t0, done
    
    # For this diagonal, check all rows
    li      $t2, 0           # current row
    
row_loop:
    bgt     $t2, $t8, next_diag
    
    # Calculate col = diagonal - row
    sub     $t3, $t1, $t2
    
    # Check if col is valid
    bltz    $t3, next_row
    bgt     $t3, $t9, next_row
    
    # Valid position: row=$t2, col=$t3
    # Calculate frame starting address
    mul     $t4, $t2, $s4    # row * frame_cols
    add     $t4, $t4, $t3    # + col
    sll     $t4, $t4, 2      # * 4
    add     $t4, $s1, $t4    # frame base address
    
    # Calculate SAD for this position
    li      $t5, 0           # SAD = 0
    li      $t6, 0           # win_row = 0
    
sad_row_loop:
    bge     $t6, $s5, check_sad    # if win_row >= window_rows
    
    li      $t7, 0           # win_col = 0
    
    # Calculate window row address
    mul     $a1, $t6, $s6    # win_row * window_cols
    sll     $a1, $a1, 2      # * 4
    add     $a1, $s2, $a1    # window row start
    
    # Calculate frame row address
    mul     $a0, $t6, $s4    # win_row * frame_cols
    sll     $a0, $a0, 2      # * 4
    add     $a0, $t4, $a0    # frame row start
    
sad_col_loop:
    bge     $t7, $s6, sad_row_done    # if win_col >= window_cols
    
    # Load frame and window pixels
    lw      $a2, 0($a0)
    lw      $a3, 0($a1)
    
    # Calculate absolute difference
    sub     $a2, $a2, $a3
    bgez    $a2, abs_done
    sub     $a2, $zero, $a2
abs_done:
    
    # Add to SAD
    add     $t5, $t5, $a2
    
    # Move to next column
    addi    $a0, $a0, 4
    addi    $a1, $a1, 4
    addi    $t7, $t7, 1
    j       sad_col_loop
    
sad_row_done:
    addi    $t6, $t6, 1
    j       sad_row_loop
    
check_sad:
    # Check if this SAD is better (<=)
    bgt     $t5, $s7, next_row
    
    # Update minimum and best position
    move    $s7, $t5
    move    $v0, $t2
    move    $v1, $t3
    
    beq     $s7, $zero, done
    
next_row:
    addi    $t2, $t2, 1
    j       row_loop
    
next_diag:
    addi    $t1, $t1, 1
    j       diag_loop
    
done:
    # Restore saved registers (NO $ra)
    lw      $s0, 0($sp)
    lw      $s1, 4($sp)
    lw      $s2, 8($sp)
    lw      $s3, 12($sp)
    lw      $s4, 16($sp)
    lw      $s5, 20($sp)
    lw      $s6, 24($sp)
    lw      $s7, 28($sp)
    addi    $sp, $sp, 32
    
    jr      $ra
