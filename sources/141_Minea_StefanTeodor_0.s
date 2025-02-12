.section .note.GNU-stack,"",@progbits 

.data
    instructions_array: .space 100024
    memory: .fill 1025
    read_file_name: .asciz "input.txt"
    read_string_format: .asciz "%d"
    output_string_format_uni_add: .asciz "%d: (%d, %d)\n"
    output_string_format_uni_get: .asciz "(%d, %d)\n"
    output_test: .asciz "%d\n"

    number_of_operations: .space 4
    number_of_additions: .space 4
    descriptor_of_current_file: .space 1
    size_of_current_file: .space 4
    out_of_memory_message: .asciz "%d: (0, 0)\n"
    invalid_descriptor_get: .asciz "(0, 0)\n"

    left_end_of_range: .space 4
    right_end_of_range: .space 4
    upper_bound_unidimensional_defragmentation: .long 1024

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

    cmp $1, %eax
    jl eof

    inc %ecx
    jmp loop_read_file

eof:
    pop %edi
    ret

output_result:

unidimensional_add:
    push %ebx
    lea instructions_array, %edi
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    mov %ebx, number_of_additions

set_blocks_for_file_adding_loop:
    cmpl $0, number_of_additions
    je unidimensional_add_exit
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
    cmp $1024, %ebx
    pop %ebx
    ja not_fitting_in_memory
memory_space_check_finished:
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
    inc %ebx
    subl size_of_current_file, %ebx
    push %ebx
    movb descriptor_of_current_file, %al
    push %eax
    push $output_string_format_uni_add
    call printf
    add $16, %esp
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
    jmp set_blocks_for_file_adding_loop

unidimensional_add_exit:
    pop %ebx
    ret









unidimensional_get:
    push %ebx
    lea instructions_array, %edi
    inc %ecx
    mov (%edi, %ecx, 4), %ebx
    movb %bl, descriptor_of_current_file
    xor %ebx, %ebx
    xor %eax, %eax
    lea memory, %esi

loop_to_check_existance_of_file:
    cmp $1024, %ebx
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
    push %ebx
    push %eax
    push $output_string_format_uni_get
    call printf
    add $12, %esp
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
    cmp $1024, %ebx
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








get_interval_into_variables_resume:
    push %ebx
    lea instructions_array, %edi
    xor %eax, %eax
    lea memory, %esi

loop_to_check_existance_of_file_generic_resume:
    cmp $1024, %ebx
    jae not_found_get_generic_resume
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    je found_get_generic_resume
    inc %ebx
    jmp loop_to_check_existance_of_file_generic_resume

found_get_generic_resume:
    push %ebx
continue_loop_get_generic_resume:
    inc %ebx
    mov (%esi, %ebx, 1), %eax
    cmpb descriptor_of_current_file, %al
    jne final_position_get_generic_resume
    jmp continue_loop_get_generic_resume
final_position_get_generic_resume:
    pop %eax
    dec %ebx
    movl %eax, left_end_of_range
    movl %ebx, right_end_of_range
    jmp end_get_generic_resume

not_found_get_generic_resume:
    movl $0, left_end_of_range
    movl $0, right_end_of_range
end_get_generic_resume:
    pop %ebx
    ret








unidimensional_delete:
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
    call get_interval_into_variables_resume
    xor %eax, %eax
    cmpl $0, descriptor_of_current_file
    je prepeare_for_next_interval_delete
print_interval_delete:
    call get_interval_into_variables
    push %ecx
    push right_end_of_range
    push left_end_of_range
    push descriptor_of_current_file
    push $output_string_format_uni_add
    call printf
    add $16, %esp
    pop %ecx
prepeare_for_next_interval_delete:
    incl right_end_of_range
    mov right_end_of_range, %ebx
    cmpl $1024, right_end_of_range
    jae exit_delete
    jmp loop_through_intervals_delete
exit_delete:
    pop %ebx
    ret




verify_if_first_byte_is_zero:
    push %ebx
    xor %eax, %eax
    movb (%esi, %eax, 1), %bl
    cmp $0, %bl
    pop %ebx
    je not_finished_with_defrag
    jmp print_unidimensional_defragmentation

unidimensional_defragmentation:
    push %ebx
    lea instructions_array, %edi
    lea memory, %esi
loop_defragmentation_intervals:
    movl $0, descriptor_of_current_file
    call get_interval_into_variables
    movl right_end_of_range, %eax
    cmpl $0, %eax
    je verify_if_first_byte_is_zero
    cmpl $1023, right_end_of_range
    jae print_unidimensional_defragmentation
not_finished_with_defrag:
    movl left_end_of_range, %eax
    subl %eax, right_end_of_range
    incl right_end_of_range
    movl right_end_of_range, %eax
    movl %eax, size_of_current_file
    subl %eax, upper_bound_unidimensional_defragmentation
    movl left_end_of_range, %ebx
    mov %ebx, %edx
    addl size_of_current_file, %edx
    xor %eax, %eax
loop_move_unallocated_space:
    cmpl %ebx, upper_bound_unidimensional_defragmentation
    je loop_fill_zeros_back 
    movb (%esi, %edx, 1), %al
    movb %al, (%esi, %ebx, 1)
    inc %ebx
    inc %edx
    jmp loop_move_unallocated_space
loop_fill_zeros_back:
    cmpl $0, size_of_current_file
    je loop_defragmentation_intervals
    movb $0, (%esi, %ebx, 1)
    inc %ebx
    decl size_of_current_file
    jmp loop_fill_zeros_back

print_unidimensional_defragmentation:

return_intervals_defragmentation:
    xor %ebx, %ebx
    xor %eax, %eax
loop_through_intervals_defragmentation:
    movb (%esi, %ebx, 1), %al
    mov %eax, descriptor_of_current_file
print_interval_defragmentation:
    call get_interval_into_variables
    cmpb $0, descriptor_of_current_file
    je exit_defragmentation
    push %ecx
    push right_end_of_range
    push left_end_of_range
    push descriptor_of_current_file
    push $output_string_format_uni_add
    call printf
    add $16, %esp
    pop %ecx
prepeare_for_next_interval_defragmentation:
    incl right_end_of_range
    movl right_end_of_range, %ebx
    movb (%esi, %ebx, 1), %al
    cmpb $0, %al
    je exit_defragmentation
    cmp $1024, %ebx
    jae exit_defragmentation
    jmp loop_through_intervals_defragmentation 
exit_defragmentation:
    movl $1024, upper_bound_unidimensional_defragmentation
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
    call unidimensional_add
    jmp continue_instruction_loop

skip_addition:
    cmp $2, %ebx
    jne skip_get
    call unidimensional_get
    jmp continue_instruction_loop

skip_get:
    cmp $3, %ebx
    jne skip_delete
    call unidimensional_delete
    jmp continue_instruction_loop

skip_delete:
    call unidimensional_defragmentation

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
    
    movl $1, %eax
    xorl %ebx, %ebx
    int $0x80

