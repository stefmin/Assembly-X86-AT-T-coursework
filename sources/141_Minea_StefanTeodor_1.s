.section .note.GNU-stack,"",@progbits 

.data
    instructions_array: .space 100024
    memory: .fill 1048576
    read_file_name: .asciz "input.txt"
    read_string_format: .asciz "%d"
    output_string_format_uni_add: .asciz "%d: (%d, %d)\n"
    output_string_format_uni_get: .asciz "(%d, %d)\n"
    output_string_format_bi_add: .asciz "%d: ((%d, %d), (%d, %d))\n"
    output_string_format_bi_get: .asciz "((%d, %d), (%d, %d))\n"
    output_test: .asciz "%d\n"

    number_of_operations: .space 4
    number_of_additions: .space 4
    descriptor_of_current_file: .space 1
    size_of_current_file: .space 4
    out_of_memory_message: .asciz "%d: ((0, 0), (0, 0))\n"
    invalid_descriptor_get: .asciz "((0, 0), (0, 0))\n"

    left_end_of_range: .space 4
    right_end_of_range: .space 4
    upper_bound_unidimensional_defragmentation: .long 1024
    memory_segment_index: .long 1
    comparison_number_for_next_line: .long 0

    descriptor_counter: .long 0
    array_of_descriptors_for_defragmentation: .fill 256
    array_of_sizes_of_descriptors: .space 1024

    descriptors_to_check_before_concrete: .fill 256
    absolute_filepath: .fill 1000
    read_format_of_filepath: .asciz "%s"
    multiple_of_four: .long 0
    dir_counter: .long 0
    statbuf: .space 200
    dirstream_pointer: .space 4
    add_after_concrete: .space 4

.text

.global main

read_instructions:
    push %edi
    xor %ecx, %ecx
    lea instructions_array, %edi

loop_read_file:
    push %ecx
    lea (%edi, %ecx, 4), %edx
    push %edx
    push $read_string_format
    call scanf
    add $8, %esp
    pop %ecx

    mov (%edi, %ecx, 4), %edx
    cmp $5, %edx
    je read_filepath

    cmp $1, %eax
    jl eof

    inc %ecx
    jmp loop_read_file

read_filepath:
    inc %ecx
    push %ecx
    lea (%edi, %ecx, 4), %edx
    push %edx
    push $read_string_format
    call scanf
    add $8, %esp
    pop %ecx
    cmp $1, %eax
    jl confirmed_filepath
    inc %ecx
    jmp loop_read_file

confirmed_filepath:
    push %eax
    push %ebx
    push %ecx
    lea (%edi, %ecx, 4), %edx
    push %edx
    push $read_format_of_filepath
    call scanf
    add $8, %esp
    pop %ecx 
    cmp $1, %eax
    jl eof
    mov %ecx, %ebx
    add %ebx, %ebx
    add %ebx, %ebx

increase_iterator_value_past_filepath:
    mov (%edi, %ebx, 1), %al
    inc %ebx
    cmp $0, %al
    je iterator_position_fixed
    incl multiple_of_four
    cmpl $4, multiple_of_four
    jne increase_iterator_value_past_filepath
    inc %ecx
    movl $0, multiple_of_four
    jmp increase_iterator_value_past_filepath

iterator_position_fixed:
    pop %ebx
    pop %eax
    inc %ecx    # separate filepath from other input by one 0 dword
    cmpl $0, multiple_of_four
    je loop_read_file
    inc %ecx
    jmp loop_read_file   

eof:
    pop %edi
    ret


bidimensional_add:
    push %ebx
    lea instructions_array, %edi
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    mov %ebx, number_of_additions

set_blocks_for_file_adding_loop:
    cmpl $0, number_of_additions
    je bidimensional_add_exit
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    movb %bl, descriptor_of_current_file
    inc %ecx

    mov (%edi, %ecx, 4), %ebx
    mov %ebx, size_of_current_file

    #conversia in numar de blocuri
    xor %edx, %edx
    mov size_of_current_file, %eax
    mov $8, %ebx
    div %ebx
    cmp $0, %edx
    je after_calculated_block_size
    inc %eax
after_calculated_block_size:
    mov %eax, size_of_current_file
    xor %ebx, %ebx
    lea memory, %esi

    xor %edx, %edx
loop_inside_memory_to_add_file:
    push %ebx
    add size_of_current_file, %ebx

#Comparison with multiples of 1024
    push %edx
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    movl %eax, comparison_number_for_next_line
    pop %edx

    cmp %eax, %ebx
    pop %ebx
    ja not_fitting_in_memory
    xor %eax, %eax
memory_space_check_finished:
    cmpl comparison_number_for_next_line, %ebx
    jae not_fitting_in_memory
    mov (%esi, %ebx, 1), %eax
    cmp $0, %al
    jne reset_number_of_null_bytes_add
    inc %edx
    cmpl size_of_current_file, %edx
    je found_memory_for_file
    inc %ebx
    jmp memory_space_check_finished
reset_number_of_null_bytes_add:
    xor %edx, %edx
iteration_end_loop_through_bytes_check_add:    
    inc %ebx
    jmp loop_inside_memory_to_add_file



found_memory_for_file:
    xor %edx, %edx
    xor %eax, %eax
    push %ecx
    
    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    div %ebx
    pop %ebx
    push %edx

    decl memory_segment_index
    pushl memory_segment_index
    inc %ebx
    subl size_of_current_file, %ebx

    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    pop %ebx
    push %edx
    xor %edx, %edx

    pushl memory_segment_index
    incl memory_segment_index
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $output_string_format_bi_add
    call printf
    add $24, %esp
    pop %ecx
    xor %eax, %eax

fill_memory_with_descriptor:
    movb descriptor_of_current_file, %al
    movb %al, (%esi, %ebx, 1)
    inc %edx
    inc %ebx
    cmpl size_of_current_file, %edx
    je prepeare_for_next_add
    jmp fill_memory_with_descriptor

not_fitting_in_memory:
    # verify on next line
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    mov %eax, %ebx
    xor %edx, %edx
    # increase mem segm
    incl memory_segment_index

    # not found on all lines 
    cmp $1048576, %ebx
    jae not_enough_memory_print
    jmp loop_inside_memory_to_add_file

not_enough_memory_print:
    push %ecx 
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $out_of_memory_message
    call printf
    add $8, %esp
    pop %ecx

prepeare_for_next_add:
    decl number_of_additions
    movl $1, memory_segment_index
    jmp set_blocks_for_file_adding_loop

bidimensional_add_exit:
    pop %ebx
    ret




bidimensional_get:
    push %ebx
    lea instructions_array, %edi
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    movb %bl, descriptor_of_current_file
    xor %ebx, %ebx
    xor %eax, %eax
    lea memory, %esi

loop_to_check_existance_of_file:
    cmp $1048576, %ebx
    jae not_found_get
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    je found_get
    inc %ebx
    jmp loop_to_check_existance_of_file

found_get:
    push %ebx
continue_loop_get:
    inc %ebx
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    jne final_position_get
    jmp continue_loop_get
final_position_get:
    pop %eax
    push %ecx
    dec %ebx

    mov %eax, %ecx
    mov %ebx, %eax
    xor %edx, %edx
    mov $1024, %ebx
    div %ebx
    push %edx
    push %eax
    mov %ecx, %eax

    xor %edx, %edx
    mov $1024, %ebx
    div %ebx
    push %edx
    push %eax


    push $output_string_format_bi_get
    call printf
    add $20, %esp
    pop %ecx
    jmp end_get

not_found_get:
    push %ecx
    push $invalid_descriptor_get
    call printf
    add $4, %esp
    pop %ecx
end_get:
    pop %ebx
    ret





get_interval_into_variables:
    push %ebx
    lea instructions_array, %edi
    xor %ebx, %ebx
    xor %eax, %eax
    lea memory, %esi

loop_to_check_existance_of_file_generic:
    cmp $1048576, %ebx
    jae not_found_get_generic
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    je found_get_generic
    inc %ebx
    jmp loop_to_check_existance_of_file_generic

found_get_generic:
    push %ebx
continue_loop_get_generic:
    inc %ebx
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    jne final_position_get_generic
    jmp continue_loop_get_generic
final_position_get_generic:
    pop %eax
    dec %ebx
    movl %eax, left_end_of_range
    movl %ebx, right_end_of_range
    jmp end_get_generic

not_found_get_generic:
    movl $0, left_end_of_range
    movl $0, right_end_of_range
end_get_generic:
    pop %ebx
    ret






bidimensional_delete:
    push %ebx
    lea instructions_array, %edi
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    movb %bl, descriptor_of_current_file
    xor %ebx, %ebx
    xor %eax, %eax
    lea memory, %esi
    call get_interval_into_variables
    cmpl $0, right_end_of_range 
    je return_intervals_delete
    mov left_end_of_range, %ebx
    mov right_end_of_range, %edx
    sub left_end_of_range, %edx
    inc %edx
    movl %edx, size_of_current_file
    xor %edx, %edx
fill_memory_with_zero:
    movb $0, (%esi, %ebx, 1)
    inc %edx
    inc %ebx
    cmpl size_of_current_file, %edx
    je return_intervals_delete
    jmp fill_memory_with_zero
return_intervals_delete:
    xor %ebx, %ebx
    xor %eax, %eax
loop_through_intervals_delete:
    movb (%esi, %ebx, 1), %al
    mov %eax, descriptor_of_current_file
    call get_interval_into_variables_defrag
    xor %eax, %eax
    cmpl $0, descriptor_of_current_file
    je prepeare_for_next_interval_delete
print_interval_delete:

    call get_interval_into_variables
    push %ecx

    push %ebx
    movl right_end_of_range, %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    pop %ebx
    push %edx
    xor %edx, %edx
    push %eax
    xor %eax, %eax

    push %ebx
    movl left_end_of_range, %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    pop %ebx
    push %edx
    xor %edx, %edx
    push %eax
    xor %eax, %eax

    push descriptor_of_current_file
    push $output_string_format_bi_add
    call printf
    add $24, %esp
    pop %ecx
prepeare_for_next_interval_delete:
    incl right_end_of_range
    mov right_end_of_range, %ebx
    cmpl $1048576, right_end_of_range
    jae exit_delete
    jmp loop_through_intervals_delete
exit_delete:
    pop %ebx
    ret







add_tailored_for_defragmentation:
    push %ebx
    push %ecx
    xor %ecx, %ecx
    lea array_of_descriptors_for_defragmentation, %edi
    movl descriptor_counter, %ebx
    movl %ebx, number_of_additions
    xor %ebx, %ebx

set_blocks_for_file_adding_loop_defrag:
    cmpl $0, number_of_additions
    je bidimensional_add_exit_defrag
    push %ebx
    mov (%edi, %ecx, 1), %ebx
    movb %bl, descriptor_of_current_file
    pop %ebx

    push %edi
    lea array_of_sizes_of_descriptors, %edi
    push %ebx
    mov (%edi, %ecx, 4), %ebx
    mov %ebx, size_of_current_file
    pop %ebx
    pop %edi

#after_calculated_block_size:
    # xor %ebx, %ebx
    lea memory, %esi
    xor %edx, %edx
loop_inside_memory_to_add_file_defrag:
    push %ebx
    add size_of_current_file, %ebx

#Comparison with multiples of 1024
    push %edx
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    mov %eax, comparison_number_for_next_line
    pop %edx

    cmp %eax, %ebx
    pop %ebx
    ja not_fitting_in_memory_defrag
    xor %eax, %eax
memory_space_check_finished_defrag:
    cmp comparison_number_for_next_line, %ebx
    jae not_fitting_in_memory_defrag
    mov (%esi, %ebx, 1), %eax
    cmp $0, %eax
    jne reset_number_of_null_bytes_add_defrag
    inc %edx
    cmpl size_of_current_file, %edx
    je found_memory_for_file_defrag
    jmp iteration_end_loop_through_bytes_check_add_defrag
reset_number_of_null_bytes_add_defrag:
    xor %edx, %edx
iteration_end_loop_through_bytes_check_add_defrag:    
    inc %ebx
    jmp memory_space_check_finished_defrag



found_memory_for_file_defrag:

    xor %edx, %edx
    xor %eax, %eax
    push %ecx
    
    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    div %ebx
    pop %ebx
    push %edx

    decl memory_segment_index
    pushl memory_segment_index
    inc %ebx
    subl size_of_current_file, %ebx

    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    pop %ebx
    push %edx
    xor %edx, %edx

    pushl memory_segment_index
    incl memory_segment_index
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $output_string_format_bi_add
    call printf
    add $24, %esp
    pop %ecx
    xor %eax, %eax

fill_memory_with_descriptor_defrag:
    movb descriptor_of_current_file, %al
    movb %al, (%esi, %ebx, 1)
    inc %edx
    inc %ebx
    cmpl size_of_current_file, %edx
    je prepeare_for_next_add_defrag
    jmp fill_memory_with_descriptor_defrag

not_fitting_in_memory_defrag:
    # verify on next line
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    mov %eax, %ebx
    xor %edx, %edx
    # increase mem segm
    incl memory_segment_index

    # not found on all lines 
    cmp $1048576, %ebx
    jae not_enough_memory_print_defrag
    jmp loop_inside_memory_to_add_file_defrag

not_enough_memory_print_defrag:
    push %ecx 
    push $out_of_memory_message
    call printf
    add $4, %esp
    pop %ecx

prepeare_for_next_add_defrag:
    decl number_of_additions
    inc %ecx
    jmp set_blocks_for_file_adding_loop_defrag

bidimensional_add_exit_defrag:
    movl $0, descriptor_counter
    push %edi
    push %esi
    push %eax
    xor %eax, %eax
    lea array_of_descriptors_for_defragmentation, %edi
    lea array_of_sizes_of_descriptors, %esi

loop_to_zero_arrays_of_descriptors_and_sizes:
    cmp $256, %eax
    je exit_zeroing_arraays_of_descriptors_and_sizes
    movb $0, (%edi, %eax, 1)
    movl $0, (%esi, %eax, 4)
    inc %eax
    jmp loop_to_zero_arrays_of_descriptors_and_sizes

exit_zeroing_arraays_of_descriptors_and_sizes:
    movl $1, memory_segment_index
    pop %eax
    pop %esi
    pop %edi

    pop %ecx
    pop %ebx
    ret









get_interval_into_variables_defrag:
    push %ebx
    lea instructions_array, %edi
    xor %eax, %eax
    lea memory, %esi

loop_to_check_existance_of_file_defrag:
    cmp $1048576, %ebx
    jae not_found_get_defrag
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    je found_get_defrag
    inc %ebx
    jmp loop_to_check_existance_of_file_defrag

found_get_defrag:
    push %ebx
continue_loop_get_defrag:
    inc %ebx
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    jne final_position_get_defrag
    jmp continue_loop_get_defrag
final_position_get_defrag:
    pop %eax
    dec %ebx
    movl %eax, left_end_of_range
    movl %ebx, right_end_of_range
    jmp end_get_defrag

not_found_get_defrag:
    movl $0, left_end_of_range
    movl $0, right_end_of_range
end_get_defrag:
    pop %ebx
    ret










bidimensional_defragmentation:
    push %edi
    push %ebx
    push %ecx
    xor %ecx, %ecx
    lea array_of_descriptors_for_defragmentation, %edi
    lea memory, %esi
    xor %ebx, %ebx
    xor %eax, %eax
get_memory_into_array:
    movb (%esi, %ebx, 1), %al
    movb %al, descriptor_of_current_file
    push %eax
    push %edi
    push %esi
    call get_interval_into_variables_defrag
    cmpl $1048575, right_end_of_range
    pop %esi
    pop %edi
    pop %eax
    jae end_of_memory

    push %edx
    mov left_end_of_range, %edx
    subl %edx, right_end_of_range
    pop %edx
    incl right_end_of_range
    cmp $0, %eax
    je check_zero_in_memory

    movb %al, (%edi, %ecx, 1)
    push %edi
    push %ebx
    lea array_of_sizes_of_descriptors, %edi
    movl right_end_of_range, %ebx
    movl %ebx, (%edi, %ecx, 4)
    pop %ebx
    pop %edi
    incl descriptor_counter
    inc %ecx
    addl right_end_of_range, %ebx
    jmp get_memory_into_array

check_zero_in_memory:
    addl right_end_of_range, %ebx
    jmp get_memory_into_array

end_of_memory:
    xor %ecx, %ecx
zero_the_memory:
    movb $0, (%esi, %ecx, 1) 
    inc %ecx
    cmp $1048576, %ecx 
    jae add_back_values
    jmp zero_the_memory

add_back_values:
    call add_tailored_for_defragmentation

exit_defragmentation:
    pop %ecx
    pop %ebx
    pop %edi
    ret









add_tailored_for_concrete:
    push %ebx
    push %ecx
    xor %ecx, %ecx
    lea array_of_descriptors_for_defragmentation, %edi
    xor %ebx, %ebx

set_blocks_for_file_adding_loop_concrete:
    cmpl $0, number_of_additions
    je bidimensional_add_exit_concrete
    movl $1, memory_segment_index
    mov (%edi, %ecx, 1), %ebx
    movb %bl, descriptor_of_current_file

    push %edi
    lea array_of_sizes_of_descriptors, %edi
    mov (%edi, %ecx, 4), %ebx
    mov %ebx, size_of_current_file
    pop %edi

#after_calculated_block_size:
    xor %ebx, %ebx
    lea memory, %esi
    xor %edx, %edx
loop_inside_memory_to_add_file_concrete:
    push %ebx
    add size_of_current_file, %ebx

#Comparison with multiples of 1024
    push %edx
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    mov %eax, comparison_number_for_next_line
    pop %edx

    cmp %eax, %ebx
    pop %ebx
    ja not_fitting_in_memory_concrete
    xor %eax, %eax
memory_space_check_finished_concrete:
    cmp comparison_number_for_next_line, %ebx
    jae not_fitting_in_memory_concrete
    mov (%esi, %ebx, 1), %eax
    cmp $0, %eax
    jne reset_number_of_null_bytes_add_concrete
    inc %edx
    cmpl size_of_current_file, %edx
    je found_memory_for_file_concrete
    jmp iteration_end_loop_through_bytes_check_add_concrete
reset_number_of_null_bytes_add_concrete:
    xor %edx, %edx
iteration_end_loop_through_bytes_check_add_concrete:    
    inc %ebx
    jmp memory_space_check_finished_concrete



found_memory_for_file_concrete:

    push %ecx
    push %eax
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $output_test
    call printf
    add $8, %esp
    pop %eax

    push %eax
    xor %eax, %eax
    mov size_of_current_file, %eax
    push %eax
    push $output_test
    call printf
    add $8, %esp
    pop %eax
    pop %ecx

    xor %edx, %edx
    xor %eax, %eax
    push %ecx
    
    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    div %ebx
    pop %ebx
    push %edx

    decl memory_segment_index
    pushl memory_segment_index
    inc %ebx
    subl size_of_current_file, %ebx

    push %ebx
    mov %ebx, %eax
    mov $1024, %ebx
    xor %edx, %edx
    div %ebx
    pop %ebx
    push %edx
    xor %edx, %edx

    pushl memory_segment_index
    incl memory_segment_index
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $output_string_format_bi_add
    call printf
    add $24, %esp
    pop %ecx
    xor %eax, %eax

fill_memory_with_descriptor_concrete:
    movb descriptor_of_current_file, %al
    movb %al, (%esi, %ebx, 1)
    inc %edx
    inc %ebx
    cmpl size_of_current_file, %edx
    je prepeare_for_next_add_concrete
    jmp fill_memory_with_descriptor_concrete

not_fitting_in_memory_concrete:
    # verify on next line
    mov $1024, %edx
    movl memory_segment_index, %eax
    mul %edx
    mov %eax, %ebx
    xor %edx, %edx
    # increase mem segm
    incl memory_segment_index

    # not found on all lines 
    cmp $1048576, %ebx
    jae not_enough_memory_print_concrete
    jmp loop_inside_memory_to_add_file_concrete

not_enough_memory_print_concrete:

    push %ecx
    push %eax
    xor %eax, %eax
    movb descriptor_of_current_file, %al
    push %eax
    push $output_test
    call printf
    add $8, %esp
    pop %eax

    push %eax
    xor %eax, %eax
    mov size_of_current_file, %eax
    push %eax
    push $output_test
    call printf
    add $8, %esp
    pop %eax
    pop %ecx

    push %ecx 
    push $out_of_memory_message
    call printf
    add $4, %esp
    pop %ecx

prepeare_for_next_add_concrete:
    decl number_of_additions
    inc %ecx
    movl $1, memory_segment_index
    jmp set_blocks_for_file_adding_loop_concrete

bidimensional_add_exit_concrete:
    movl $0, descriptor_counter
    push %edi
    push %esi
    push %eax
    xor %eax, %eax
    lea array_of_descriptors_for_defragmentation, %edi
    lea array_of_sizes_of_descriptors, %esi

loop_to_zero_arrays_of_descriptors_and_sizes_concrete:
    cmp $256, %eax
    je exit_zeroing_arraays_of_descriptors_and_sizes_concrete
    movb $0, (%edi, %eax, 1)
    movl $0, (%esi, %eax, 4)
    inc %eax
    jmp loop_to_zero_arrays_of_descriptors_and_sizes_concrete

exit_zeroing_arraays_of_descriptors_and_sizes_concrete:
    movl $1, memory_segment_index
    pop %eax
    pop %esi
    pop %edi

    pop %ecx
    pop %ebx
    ret












concrete:
    push %ebx
    push %eax
    push %edx
    push %edi
    lea instructions_array, %edi
    inc %ecx
    push %ecx
    # mov $0, %ebx
    # push %ebx
    # push %ebx
    lea (%edi, %ecx, 4), %ebx
    push %ebx
    call opendir
    add $4, %esp
    pop %ecx
    # movl %eax, descriptor_of_current_file
    movl %eax, dirstream_pointer
    movl $0, number_of_additions
    movl $0, dir_counter
    movl $0, add_after_concrete


getting_each_file:
    push %ecx
    # movl descriptor_of_current_file, %eax
    movl dirstream_pointer, %eax
    push %eax
    call readdir
    add $4, %esp
    cmp $0, %eax
    pop %ecx            #keeps stack alligned if branching occurs
    jle no_more_files
    push %ecx           #keeps stack alligned if branching occurs

    push %edi
    push %esi
    push %eax
    lea (%edi, %ecx, 4), %esi
    lea absolute_filepath, %edi
    xor %ebx, %ebx
get_directory_path:
    movb (%esi, %ebx, 1), %al
    cmp $0, %al
    je get_filename_into_path
    movb %al, (%edi, %ebx, 1)
    inc %ebx 
    jmp get_directory_path
get_filename_into_path:
    cmpl $0, dir_counter
    jne skip_filepath_ecx_increment
    add %ebx, add_after_concrete
skip_filepath_ecx_increment:
    pop %eax
    movb $47, (%edi, %ebx, 1)
    inc %ebx
    lea (%edi, %ebx, 1), %esi
    mov %esi, %edi
    lea 11(%eax), %esi
    push %eax
    xor %ebx, %ebx
loop_to_get_filepath:
    movb (%esi, %ebx, 1), %al
    cmp $0, %al
    je got_filename_into_path
    movb %al, (%edi, %ebx, 1)
    inc %ebx
    jmp loop_to_get_filepath

got_filename_into_path:
    cmp $2, %ebx
    pop %eax
    pop %esi
    pop %edi
    pop %ecx
    jle exclude_dot_returns
    push %ecx
    # lea 11(%eax), %ebx
    lea (absolute_filepath), %ebx
    mov %ebx, %eax
    mov $0, %ebx
    push %ebx
    push %ebx
    push %eax
    call open
    add $12, %esp
    push %eax
    lea statbuf, %ebx
    push %ebx
    push %eax
    call fstat
    add $8, %esp
    movl 44(%ebx), %eax
    xor %edx, %edx
    mov $1024, %ebx
    div %ebx
    cmp $0, %edx
    je size_is_good
    inc %eax
    movl %eax, size_of_current_file
size_is_good:
    pop %eax
    pop %ecx

    xor %edx, %edx
    mov $255, %ebx
    div %ebx
    inc %edx

    push %edx
    movl size_of_current_file, %ebx
    push %ebx
    movl %edx, descriptor_of_current_file
    call get_interval_into_variables
    cmpl $0, right_end_of_range
    pop %ebx
    movl %ebx, size_of_current_file
    pop %edx
    jne exclude_dot_returns
    
    movl number_of_additions, %eax
    push %edi
    push %esi
    lea array_of_descriptors_for_defragmentation, %edi
    lea array_of_sizes_of_descriptors, %esi
    mov %edx, (%edi, %eax, 1)
    movl size_of_current_file, %ebx
    mov %ebx, (%esi, %eax, 4)
    pop %esi
    pop %edi
    incl number_of_additions
exclude_dot_returns:
    push %edi
    lea (absolute_filepath), %edi
    xor %ebx, %ebx
loop_to_zero_filepath:
    movb $0, (%edi, %ebx, 1)
    cmp $999, %ebx
    je finished_zeroing_filepath
    inc %ebx
    jmp loop_to_zero_filepath 
finished_zeroing_filepath:
    pop %edi
    incl dir_counter
    jmp getting_each_file

no_more_files:

    call add_tailored_for_concrete

close_open_files:


exit_concrete:
    movl $0, dir_counter
    push %eax
    push %edx
    push %ebx
    xor %edx, %edx
    movl add_after_concrete, %eax
    mov $4, %ebx
    div %ebx
    cmp $0, %edx
    je ecx_is_alligned
    inc %eax
ecx_is_alligned:
    addl %eax, %ecx
    pop %ebx
    pop %edx
    pop %eax
    movl $0, add_after_concrete
    pop %edi 
    pop %edx
    pop %eax
    pop %ebx
    ret





main:
    call read_instructions
    xor %ecx, %ecx
    lea instructions_array, %edi
    mov (%edi, %ecx, 4), %ebx
    mov %ebx, number_of_operations
    inc %ecx

go_to_proper_instruction:
    mov (%edi, %ecx, 4), %ebx
    cmp $1, %ebx
    jne skip_addition
    call bidimensional_add
    jmp continue_instruction_loop

skip_addition:
    cmp $2, %ebx
    jne skip_get
    call bidimensional_get
    jmp continue_instruction_loop

skip_get:
    cmp $3, %ebx
    jne skip_delete
    call bidimensional_delete
    jmp continue_instruction_loop

skip_delete:
    cmp $4, %ebx
    jne skip_defragmentation
    call bidimensional_defragmentation
    jmp continue_instruction_loop

skip_defragmentation:
    call concrete

continue_instruction_loop:
    inc %ecx
    decl number_of_operations
    cmpl $0, number_of_operations
    je et_exit
    jmp go_to_proper_instruction

et_exit:	
    pushl $0
    call fflush
    popl %eax

    mov $1, %eax
    xor %ebx, %ebx
    int $0x80
