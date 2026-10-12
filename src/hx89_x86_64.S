.intel_syntax noprefix

.equ MAX_CELLS, 4096
.equ CELL_SIZE, 80
.equ MAX_HEADS, 32
.equ HEAD_SIZE, 88
.equ MAX_STACK, 1024
.equ MAX_NODES, 2048
.equ NODE_SIZE, 32
.equ FB_W, 64
.equ FB_H, 64
.equ FB_SIZE, 12288
.equ SNAP_MAGIC, 0x48583839534e5036
.equ MAX_OP, 38
.equ MAX_NATIVE, 4096
.equ MAX_ACCEL_IR, 64
.equ MAX_ACCEL_CODE, 4096
.equ PROT_READ, 1
.equ PROT_WRITE, 2
.equ PROT_EXEC, 4
.equ MAP_PRIVATE, 2
.equ MAP_ANONYMOUS, 32

.section .rodata
usage:          .asciz "usage: hx89 [--native] [--phase-forward|--phase-reverse] [--target-q 0..24] <polyform> [seed] [max_steps]\n       hx89 [--native] --resume <statefile> [max_steps]\n"
str_native:     .asciz "--native"
str_phase_forward: .asciz "--phase-forward"
str_phase_reverse: .asciz "--phase-reverse"
str_target_q:  .asciz "--target-q"
search_fmt:    .asciz "SEARCH step=%llu head=%llu q=%llu fitness=%llu target=%llu\n"
target_fmt:    .asciz "TARGET_HIT q=%llu step=%llu head=%llu\n"
native_disabled_fmt: .asciz "HX89: native execution requires --native; head stopped\n"
snapshot_bad:   .asciz "HX89: snapshot rejected (length, version or bounds)\n"
open_fail:      .asciz "HX89: cannot open %s\n"
bad_magic:      .asciz "HX89: content is not an HX89 Polyform (missing HX89P1)\n"
bad_cell:       .asciz "HX89: malformed CELL record: %s"
too_many:       .asciz "HX89: too many cells\n"
seed_fmt:       .asciz "HX89 seed=%llu cells=%llu\n"
summary_fmt:    .asciz "HX89 halt steps=%llu heads=%llu nodes=%llu stack=%llu hash=%016llx\n"
limit_fmt:      .asciz "HX89: physical step budget reached at %llu\n"
no_cell_fmt:    .asciz "HX89: head %llu fell out of the sparse field at (%lld,%lld,%lld,%lld,%lld)\n"
invalid_op_fmt: .asciz "HX89: invalid opcode %lld at cell %llu\n"
entropy_fmt:    .asciz "ENTROPY step=%llu head=%llu word=%016llx axis=%llu sign=%lld\n"
qerr_fmt:       .asciz "HX89: QSET requires two base-5 digits\n"
stack_under:    .asciz "HX89: surreal stack underflow\n"
stack_over:     .asciz "HX89: surreal stack overflow\n"
node_over:      .asciz "HX89: surreal node arena exhausted\n"
cut_invalid:    .asciz "HX89: finite Conway cut rejected: left !< right\n"
newline:        .asciz "\n"
str_hx:         .asciz "HX87P1"
str_poly:       .asciz "hx87=1;"
str_cell:       .asciz "CELL"
scan_cell:      .asciz "CELL %lld %lld %lld %lld %lld %lld %lld %lld %lld"
scan_raw:       .asciz "%lld %lld %lld %lld %lld %lld %lld %lld %lld"
mode_r:         .asciz "r"
mode_wb:        .asciz "wb"
mode_rb:        .asciz "rb"
state_name:     .asciz "hx89.state"
regen_name:     .asciz "hx89.regen"
frame_name:     .asciz "frame.ppm"
header_out:     .asciz "HX87P1\n# x y z w v op a b q\n"
cell_out:       .asciz "CELL %lld %lld %lld %lld %lld %lld %lld %lld %lld\n"
ppm_header:     .asciz "P6\n64 64\n255\n"
hash_fmt:       .asciz "HASH %016llx\n"
save_fmt:       .asciz "SNAPSHOT %s bytes=%llu\n"
dump_fmt:       .asciz "REGENERATED %s cells=%llu\n"
resume_fmt:     .asciz "RESUMED %s steps=%llu\n"
node_int_fmt:   .asciz "%lld"
node_dyad_fmt:  .asciz "%lld/2^%lld"
node_neg_l:     .asciz "-("
node_add_l:     .asciz "("
node_plus:      .asciz "+"
node_rp:        .asciz ")"
node_cut_l:     .asciz "{"
node_bar:       .asciz "|"
node_cut_r:     .asciz "}"
node_omega:     .asciz "omega"
node_bad:       .asciz "<?>"
node_mul_l:     .asciz "("
node_mul:       .asciz "*"
node_inv_l:     .asciz "1/("
node_omegapow_l:.asciz "omega^("
native_tag:     .asciz "NATIVE_RAW"
scan_native:    .asciz "NATIVE_RAW %llu"
native_bad:     .asciz "HX89: malformed or oversized NATIVE_RAW payload\n"
native_missing: .asciz "HX89: NATIVE has no raw payload\n"
native_reject:  .asciz "HX89: NABI0 rejected unsafe native byte sequence\n"
native_mmaperr: .asciz "HX89: native executable arena allocation/protection failed\n"
native_fmt:     .asciz "NATIVE_RIP_BRIDGE return=%lld bytes=%llu\n"
rip_host_fmt:   .asciz "RIP5_HOST=%016llx\n"
rip_vec_fmt:    .asciz "RIP5_MIRROR=(%lld,%lld,%lld,%lld,%lld)\n"
rip_obs_fmt:    .asciz "RIP5_OBSERVE op=%lld q=%lld\n"
rip_none_fmt:   .asciz "RIP5_OBSERVE=VOID\n"
qtrace_fmt:     .asciz "Q2 old=%llu qa=%llu qb=%llu next=%llu nqa=%llu nqb=%llu\n"
phase_trace_fmt:.asciz "PHASE old=%llu qa=%llu qb=%llu next=%llu nqa=%llu nqb=%llu\n"
native_header_out: .asciz "NATIVE_RAW %llu\n"
hex_enter_fmt:  .asciz "HEXWORLD_ENTER semantic=HX87SEM3 dims=5 q2=%llu epoch=%llu\n"
hex_stat_fmt:   .asciz "HEXWORLD epoch=%llu cells=%llu heads=%llu surreal=%llu entropy=%016llx\n"
hex_bad_sem:    .asciz "HX89: semantic image rejected by Hexworld\n"
accel_fmt:      .asciz "NATIVE_ACCEL epoch=%llu ir=%llu bytes=%llu result=%lld src=%016llx code=%016llx\n"
accel_bad:      .asciz "HX89: NATIVE_ACCEL rejected malformed IR field\n"
accel_maperr:   .asciz "HX89: NATIVE_ACCEL executable arena transition failed\n"
ir_direct:      .asciz "HX89: native IR cell executed outside NATIVE_ACCEL\n"
rip_hex_fmt:    .asciz "RIP5_HEX=(%llu,%llu,%llu,%llu,%llu)\n"

# Stage-0 HX0 decodes one-bit symbols into this generated image and checks
# against the independent ETCH route. The assembler embeds the result.
.align 8
hx0_semantics:
.incbin "build/hx87_semantics.seed"
hx0_semantics_end:
.equ SEM_VERSION,   8
.equ SEM_QBASE,     9
.equ SEM_QSTATES,   10
.equ SEM_QBIAS,     11
.equ SEM_OPCOUNT,   12
.equ SEM_OPMAP,     13

.section .bss
.align 16
state_begin:
snapshot_magic: .zero 8
cell_count:     .zero 8
head_count:     .zero 8
stack_top:      .zero 8
node_count:     .zero 8
step_count:     .zero 8
entropy_seed:   .zero 8
last_hash:      .zero 8
hexworld_active:.zero 8
hexworld_epoch: .zero 8
native_accel_epoch: .zero 8
native_source_hash: .zero 8
native_code_hash: .zero 8
native_len:     .zero 8
phase_mode:     .zero 8
target_enabled: .zero 8
target_q:       .zero 8
best_score:     .zero 8
target_found:   .zero 8
native_blob:    .zero MAX_NATIVE
cells:          .zero MAX_CELLS*CELL_SIZE
heads:          .zero MAX_HEADS*HEAD_SIZE
sstack:         .zero MAX_STACK*8
nodes:          .zero MAX_NODES*NODE_SIZE
framebuffer:    .zero FB_SIZE
state_end:
native_enabled: .zero 8
# Transient physical-acceleration workspace deliberately lives outside the
# persisted Hexworld state image. It never defines HX87 semantics.
.align 16
native_codegen: .zero MAX_ACCEL_CODE
native_codegen_len: .zero 8
max_steps:      .zero 8

.section .text
.extern fopen
.extern fclose
.extern fgets
.extern sscanf
.extern printf
.extern fprintf
.extern fwrite
.extern fread
.extern strncmp
.extern strcmp
.extern strchr
.extern strtoull
.extern putchar
.extern getchar
.extern getrandom
.extern exit
.extern mmap
.extern mprotect
.extern munmap

.global main
.type main,@function
main:
    push rbp
    mov rbp, rsp
    sub rsp, 1024
    mov qword ptr [max_steps], 1000000
    mov rax, SNAP_MAGIC
    mov qword ptr [snapshot_magic], rax

    cmp edi, 2
    jl .usage
    # Native execution is opt-in and this flag is outside serialized state.
    mov dword ptr [rbp-8], edi
    mov qword ptr [rbp-16], rsi
.flag_loop:
    cmp dword ptr [rbp-8], 2
    jl .usage
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    lea rsi, [rip+str_native]
    call strcmp
    test eax, eax
    jnz .check_phase_forward
    mov qword ptr [native_enabled], 1
    jmp .consume_flag
.check_phase_forward:
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    lea rsi, [rip+str_phase_forward]
    call strcmp
    test eax, eax
    jnz .check_phase_reverse
    mov qword ptr [phase_mode], 1
    jmp .consume_flag
.check_phase_reverse:
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    lea rsi, [rip+str_phase_reverse]
    call strcmp
    test eax, eax
    jnz .check_target_q
    mov qword ptr [phase_mode], 2
    jmp .consume_flag
.check_target_q:
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    lea rsi, [rip+str_target_q]
    call strcmp
    test eax, eax
    jnz .arguments_ready
    cmp dword ptr [rbp-8], 4
    jl .usage
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+16]
    mov qword ptr [rbp-32], rdi
    lea rsi, [rbp-24]
    mov edx, 10
    call strtoull
    mov rcx, qword ptr [rbp-32]
    cmp byte ptr [rcx], '0'
    jb .usage
    cmp byte ptr [rcx], '9'
    ja .usage
    mov rcx, qword ptr [rbp-24]
    cmp byte ptr [rcx], 0
    jne .usage
    cmp rax, 24
    ja .usage
    mov qword ptr [target_enabled], 1
    mov qword ptr [target_q], rax
    mov qword ptr [best_score], 5
    sub dword ptr [rbp-8], 1
    add qword ptr [rbp-16], 8
.consume_flag:
    sub dword ptr [rbp-8], 1
    add qword ptr [rbp-16], 8
    jmp .flag_loop
.arguments_ready:
    mov edi, dword ptr [rbp-8]
    mov rsi, qword ptr [rbp-16]
    mov dword ptr [rbp-8], edi
    mov qword ptr [rbp-16], rsi

    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    lea rsi, [rip+str_resume]
    call strcmp
    test eax, eax
    jz .resume_mode

    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+8]
    call load_polyform
    test eax, eax
    jne .fail

    cmp dword ptr [rbp-8], 3
    jl .random_seed
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+16]
    xor esi, esi
    xor edx, edx
    call strtoull
    mov qword ptr [entropy_seed], rax
    jmp .seed_done
.random_seed:
    lea rdi, [rip+entropy_seed]
    mov esi, 8
    xor edx, edx
    call getrandom
    cmp rax, 8
    je .seed_done
    mov rax, 0x9e3779b97f4a7c15
    mov qword ptr [entropy_seed], rax
.seed_done:
    cmp dword ptr [rbp-8], 4
    jl .init_run
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+24]
    xor esi, esi
    xor edx, edx
    call strtoull
    test rax, rax
    jz .init_run
    mov qword ptr [max_steps], rax
.init_run:
    call init_machine
    lea rdi, [rip+seed_fmt]
    mov rsi, qword ptr [entropy_seed]
    mov rdx, qword ptr [cell_count]
    xor eax, eax
    call printf
    call run_machine
    jmp .finish

.resume_mode:
    # Resuming always restores its serialized law; reject an ambiguous override.
    cmp qword ptr [phase_mode], 0
    jne .usage
    cmp qword ptr [target_enabled], 0
    jne .usage
    cmp dword ptr [rbp-8], 3
    jl .usage
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+16]
    call load_state
    test eax, eax
    jne .fail
    cmp dword ptr [rbp-8], 4
    jl .resume_ok
    mov rax, qword ptr [rbp-16]
    mov rdi, qword ptr [rax+24]
    xor esi, esi
    xor edx, edx
    call strtoull
    test rax, rax
    jz .resume_ok
    mov qword ptr [max_steps], rax
.resume_ok:
    lea rdi, [rip+resume_fmt]
    mov rax, qword ptr [rbp-16]
    mov rsi, qword ptr [rax+16]
    mov rdx, qword ptr [step_count]
    xor eax, eax
    call printf
    call run_machine

.finish:
    call compute_hash
    mov qword ptr [last_hash], rax
    lea rdi, [rip+summary_fmt]
    mov rsi, qword ptr [step_count]
    mov rdx, qword ptr [head_count]
    mov rcx, qword ptr [node_count]
    mov r8, qword ptr [stack_top]
    mov r9, qword ptr [last_hash]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

.usage:
    lea rdi, [rip+usage]
    xor eax, eax
    call printf
.fail:
    mov eax, 1
    leave
    ret

.section .rodata
str_resume: .asciz "--resume"

.section .text
# int load_polyform(const char* path)
load_polyform:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 744
    mov r12, rdi
    mov qword ptr [cell_count], 0
    mov qword ptr [head_count], 0
    mov qword ptr [stack_top], 0
    mov qword ptr [node_count], 0
    mov qword ptr [step_count], 0
    mov qword ptr [native_len], 0

    mov rdi, r12
    lea rsi, [rip+mode_r]
    call fopen
    test rax, rax
    jz .lp_open_fail
    mov r13, rax

    lea rdi, [rbp-512]
    mov esi, 512
    mov rdx, r13
    call fgets
    test rax, rax
    jz .lp_bad_magic
    mov qword ptr [rbp-520], 0
    lea rdi, [rbp-512]
    lea rsi, [rip+str_hx]
    mov edx, 6
    call strncmp
    test eax, eax
    jz .lp_magic_ok
    lea rdi, [rbp-512]
    lea rsi, [rip+str_poly]
    mov edx, 7
    call strncmp
    test eax, eax
    jne .lp_bad_magic
    mov qword ptr [rbp-520], 1
.lp_magic_ok:

.lp_loop:
    lea rdi, [rbp-512]
    mov esi, 512
    mov rdx, r13
    call fgets
    test rax, rax
    jz .lp_done
    movzx eax, byte ptr [rbp-512]
    cmp al, '#'
    je .lp_loop
    cmp al, 10
    je .lp_loop
    cmp al, 13
    je .lp_loop

    # Optional raw native facet. It must be the final record because the exact
    # bytes following this line may contain NUL/newline and are read with fread.
    lea rdi, [rbp-512]
    lea rsi, [rip+native_tag]
    mov edx, 10
    call strncmp
    test eax, eax
    jne .lp_not_native
    lea rdi, [rbp-512]
    lea rsi, [rip+scan_native]
    lea rdx, [rip+native_len]
    xor eax, eax
    call sscanf
    cmp eax, 1
    jne .lp_native_bad
    mov rax, qword ptr [native_len]
    test rax, rax
    jz .lp_native_bad
    cmp rax, MAX_NATIVE
    ja .lp_native_bad
    lea rdi, [rip+native_blob]
    mov esi, 1
    mov rdx, rax
    mov rcx, r13
    call fread
    cmp rax, qword ptr [native_len]
    jne .lp_native_bad
    jmp .lp_done
.lp_not_native:
    cmp qword ptr [rbp-520], 0
    jne .lp_poly_line
    lea rdi, [rbp-512]
    lea rsi, [rip+str_cell]
    mov edx, 4
    call strncmp
    test eax, eax
    jne .lp_loop
    lea rax, [rbp-512]
    mov qword ptr [rbp-528], rax
    lea rax, [rip+scan_cell]
    mov qword ptr [rbp-536], rax
    jmp .lp_parse_record
.lp_poly_line:
    cmp byte ptr [rbp-512], 'c'
    jne .lp_loop
    lea rdi, [rbp-512]
    mov esi, '"'
    call strchr
    test rax, rax
    jz .lp_loop
    inc rax
    mov qword ptr [rbp-528], rax
    lea rax, [rip+scan_raw]
    mov qword ptr [rbp-536], rax
.lp_parse_record:

    mov rax, qword ptr [cell_count]
    cmp rax, MAX_CELLS
    jae .lp_too_many
    imul rax, CELL_SIZE
    lea r14, [rip+cells]
    add r14, rax

    # sscanf(line, fmt, &9 fields)
    mov rdi, qword ptr [rbp-528]
    mov rsi, qword ptr [rbp-536]
    lea rdx, [r14+0]
    lea rcx, [r14+8]
    lea r8,  [r14+16]
    lea r9,  [r14+24]
    lea rax, [r14+32]
    mov qword ptr [rsp+0], rax
    lea rax, [r14+40]
    mov qword ptr [rsp+8], rax
    lea rax, [r14+48]
    mov qword ptr [rsp+16], rax
    lea rax, [r14+56]
    mov qword ptr [rsp+24], rax
    lea rax, [r14+64]
    mov qword ptr [rsp+32], rax
    xor eax, eax
    call sscanf
    cmp eax, 9
    jne .lp_bad_cell
    mov qword ptr [r14+72], 0
    inc qword ptr [cell_count]
    jmp .lp_loop

.lp_done:
    mov rdi, r13
    call fclose
    xor eax, eax
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret
.lp_open_fail:
    lea rdi, [rip+open_fail]
    mov rsi, r12
    xor eax, eax
    call printf
    mov eax, 1
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret
.lp_bad_magic:
    mov rdi, r13
    call fclose
    lea rdi, [rip+bad_magic]
    xor eax, eax
    call printf
    mov eax, 1
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret
.lp_native_bad:
    mov rdi, r13
    call fclose
    lea rdi, [rip+native_bad]
    xor eax, eax
    call printf
    mov eax, 1
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret
.lp_too_many:
    mov rdi, r13
    call fclose
    lea rdi, [rip+too_many]
    xor eax, eax
    call printf
    mov eax, 1
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret
.lp_bad_cell:
    lea rdi, [rip+bad_cell]
    lea rsi, [rbp-512]
    xor eax, eax
    call printf
    mov rdi, r13
    call fclose
    mov eax, 1
    add rsp, 744
    pop r14
    pop r13
    pop r12
    leave
    ret

init_machine:
    push rbp
    mov rbp, rsp
    lea rdi, [rip+heads]
    mov ecx, HEAD_SIZE/8
    xor rax, rax
    rep stosq
    mov qword ptr [head_count], 1
    lea rax, [rip+heads]
    mov qword ptr [rax+40], 1      # dx=+1
    mov qword ptr [rax+80], 1      # alive
    call hexworld_enter
    leave
    ret

# Hexworld is the semantic machine. The native process is only its host capsule.
# Verify the HX0-produced semantic image before any Polyform cell can execute.
hexworld_enter:
    push rbp
    mov rbp, rsp
    lea rax, [rip+hx0_semantics]
    cmp byte ptr [rax+0], 'H'
    jne .hx_bad
    cmp byte ptr [rax+1], 'X'
    jne .hx_bad
    cmp byte ptr [rax+2], '8'
    jne .hx_bad
    cmp byte ptr [rax+3], '7'
    jne .hx_bad
    cmp byte ptr [rax+4], 'S'
    jne .hx_bad
    cmp byte ptr [rax+5], 'E'
    jne .hx_bad
    cmp byte ptr [rax+6], 'M'
    jne .hx_bad
    cmp byte ptr [rax+7], '3'
    jne .hx_bad
    cmp byte ptr [rax+SEM_QBASE], 5
    jne .hx_bad
    cmp byte ptr [rax+SEM_QSTATES], 25
    jne .hx_bad
    cmp byte ptr [rax+SEM_OPCOUNT], MAX_OP+1
    jne .hx_bad
    mov qword ptr [hexworld_active], 1
    mov qword ptr [hexworld_epoch], 0
    mov qword ptr [native_accel_epoch], 0
    mov qword ptr [native_source_hash], 0
    mov qword ptr [native_code_hash], 0
    lea rdi, [rip+hex_enter_fmt]
    movzx rsi, byte ptr [rax+SEM_QSTATES]
    mov rdx, qword ptr [hexworld_epoch]
    xor eax, eax
    call printf
    mov eax, 1
    leave
    ret
.hx_bad:
    mov qword ptr [hexworld_active], 0
    lea rdi, [rip+hex_bad_sem]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

# rdi=head ptr => rax=cell ptr or 0
find_cell:
    push rbp
    mov rbp, rsp
    xor rcx, rcx
    mov r8, qword ptr [cell_count]
.fc_loop:
    cmp rcx, r8
    jae .fc_none
    mov rax, rcx
    imul rax, CELL_SIZE
    lea r9, [rip+cells]
    add r9, rax
    mov r10, qword ptr [rdi+0]
    cmp r10, qword ptr [r9+0]
    jne .fc_next
    mov r10, qword ptr [rdi+8]
    cmp r10, qword ptr [r9+8]
    jne .fc_next
    mov r10, qword ptr [rdi+16]
    cmp r10, qword ptr [r9+16]
    jne .fc_next
    mov r10, qword ptr [rdi+24]
    cmp r10, qword ptr [r9+24]
    jne .fc_next
    mov r10, qword ptr [rdi+32]
    cmp r10, qword ptr [r9+32]
    jne .fc_next
    mov rax, r9
    leave
    ret
.fc_next:
    inc rcx
    jmp .fc_loop
.fc_none:
    xor eax, eax
    leave
    ret

# rdi=head pointer; advance by direction
advance_head:
    mov rax, qword ptr [rdi+40]
    add qword ptr [rdi+0], rax
    mov rax, qword ptr [rdi+48]
    add qword ptr [rdi+8], rax
    mov rax, qword ptr [rdi+56]
    add qword ptr [rdi+16], rax
    mov rax, qword ptr [rdi+64]
    add qword ptr [rdi+24], rax
    mov rax, qword ptr [rdi+72]
    add qword ptr [rdi+32], rax
    ret

# rdi=cell pointer automatic deterministic mutation
mutate_executed:
    # Quinary-squared evolution. q=5*qa+qb, qa/qb in 0..4.
    # qa'=(qa+qb+1)%5
    # qb'=(qb+qa+opcode)%5
    mov rax, qword ptr [rdi+64]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    div rcx
    mov rax, rdx                    # normalized q
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov r8, rax                     # old qa
    mov r9, rdx                     # old qb

    cmp qword ptr [phase_mode], 1
    je .mx_forward
    cmp qword ptr [phase_mode], 2
    je .mx_reverse

    mov rax, r8
    add rax, r9
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBIAS]
    add rax, rcx
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov r10, rdx                    # new qa

    mov rax, r9
    add rax, r8
    add rax, qword ptr [rdi+40]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov r11, rdx                    # new qb
    jmp .mx_join

    # Two shears over Z/5Z. Their composition has determinant one.
    # F(a,b)=(a+b,b+a+b); F^-1(A,B)=(A-(B-A),B-A).
.mx_forward:
    mov rax, r8
    add rax, r9
    xor rdx, rdx
    mov ecx, 5
    div rcx
    mov r10, rdx
    mov rax, r9
    add rax, r10
    xor rdx, rdx
    div rcx
    mov r11, rdx
    jmp .mx_join
.mx_reverse:
    mov rax, r9
    add rax, 5
    sub rax, r8
    xor rdx, rdx
    mov ecx, 5
    div rcx
    mov r11, rdx
    mov rax, r8
    add rax, 5
    sub rax, r11
    xor rdx, rdx
    div rcx
    mov r10, rdx
.mx_join:

    mov rax, r10
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    imul rax, rcx
    add rax, r11
    mov qword ptr [rdi+64], rax
    inc qword ptr [rdi+72]

    # Mandatory post-retirement self modification uses the evolved Q² state.
    mov rcx, qword ptr [rdi+40]
    lea rax, [rcx+rax+1]
    xor rdx, rdx
    mov rcx, MAX_OP+1
    div rcx
    mov qword ptr [rdi+40], rdx
    ret

# xorshift64* => rax word, state updated
entropy_next:
    mov rax, qword ptr [entropy_seed]
    test rax, rax
    jne .en_nonzero
    mov rax, 0x9e3779b97f4a7c15
.en_nonzero:
    mov rcx, rax
    shr rcx, 12
    xor rax, rcx
    mov rcx, rax
    shl rcx, 25
    xor rax, rcx
    mov rcx, rax
    shr rcx, 27
    xor rax, rcx
    mov qword ptr [entropy_seed], rax
    mov rcx, 0x2545F4914F6CDD1D
    imul rax, rcx
    ret

run_machine:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 72
    cmp qword ptr [hexworld_active], 1
    jne .rm_inactive
.rm_outer:
    mov rax, qword ptr [step_count]
    cmp rax, qword ptr [max_steps]
    jae .rm_limit
    xor r12, r12
    xor r13, r13                 # live count this pass
    mov r14, qword ptr [head_count]
.rm_head_loop:
    cmp r12, r14
    jae .rm_pass_done
    mov rax, r12
    imul rax, HEAD_SIZE
    lea r15, [rip+heads]
    add r15, rax
    cmp qword ptr [r15+80], 0
    je .rm_next_head
    inc r13
    mov rdi, r15
    call find_cell
    test rax, rax
    jnz .rm_have_cell
    mov qword ptr [r15+80], 0
    lea rdi, [rip+no_cell_fmt]
    mov rsi, r12
    mov rdx, qword ptr [r15+0]
    mov rcx, qword ptr [r15+8]
    mov r8,  qword ptr [r15+16]
    mov r9,  qword ptr [r15+24]
    mov rax, qword ptr [r15+32]
    mov qword ptr [rsp+0], rax
    xor eax, eax
    call printf
    jmp .rm_next_head
.rm_have_cell:
    mov rbx, rax
    mov rdi, r15
    mov rsi, rbx
    mov rdx, r12
    call execute_cell
    cmp qword ptr [r15+80], 0
    je .rm_mutate
    mov rdi, r15
    call advance_head
.rm_mutate:
    mov rdi, rbx
    call mutate_executed
    inc qword ptr [step_count]
    inc qword ptr [hexworld_epoch]
    cmp qword ptr [target_enabled], 1
    jne .rm_next_head
    # Toroidal L1 metric on F5 x F5: cyclic distance of both phase digits.
    mov rax, qword ptr [rbx+64]
    xor edx, edx
    mov ecx, 5
    div rcx
    mov r8, rax                      # candidate a
    mov r9, rdx                      # candidate b
    mov rax, qword ptr [target_q]
    xor edx, edx
    div rcx
    mov r10, rax                     # target a
    mov r11, rdx                     # target b
    cmp r8, r10
    jae .rm_a_ge
    xchg r8, r10
.rm_a_ge:
    sub r8, r10
    mov rax, 5
    sub rax, r8
    cmp r8, rax
    jbe .rm_a_done
    mov r8, rax
.rm_a_done:
    cmp r9, r11
    jae .rm_b_ge
    xchg r9, r11
.rm_b_ge:
    sub r9, r11
    mov rax, 5
    sub rax, r9
    cmp r9, rax
    jbe .rm_b_done
    mov r9, rax
.rm_b_done:
    add r8, r9
    cmp r8, qword ptr [best_score]
    jae .rm_next_head
    mov qword ptr [best_score], r8
    lea rdi, [rip+search_fmt]
    mov rsi, qword ptr [step_count]
    mov rdx, r12
    mov rcx, qword ptr [rbx+64]
    mov r9, qword ptr [target_q]
    xor eax, eax
    call printf
    cmp qword ptr [best_score], 0
    jne .rm_next_head
    mov qword ptr [target_found], 1
    lea rdi, [rip+target_fmt]
    mov rsi, qword ptr [rbx+64]
    mov rdx, qword ptr [step_count]
    mov rcx, r12
    xor eax, eax
    call printf
    jmp .rm_success
.rm_next_head:
    inc r12
    jmp .rm_head_loop
.rm_pass_done:
    # Count actual alive heads.
    xor r12, r12
    xor r13, r13
    mov r14, qword ptr [head_count]
.rm_alive_loop:
    cmp r12, r14
    jae .rm_alive_done
    mov rax, r12
    imul rax, HEAD_SIZE
    lea rcx, [rip+heads]
    add rcx, rax
    cmp qword ptr [rcx+80], 0
    je .rm_alive_next
    inc r13
.rm_alive_next:
    inc r12
    jmp .rm_alive_loop
.rm_alive_done:
    test r13, r13
    jnz .rm_outer
.rm_success:
    xor eax, eax
    add rsp, 72
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret
.rm_inactive:
    lea rdi, [rip+hex_bad_sem]
    xor eax, eax
    call printf
    mov eax, 3
    add rsp, 72
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret
.rm_limit:
    lea rdi, [rip+limit_fmt]
    mov rsi, qword ptr [step_count]
    xor eax, eax
    call printf
    mov eax, 2
    add rsp, 72
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

# execute_cell(head=rdi, cell=rsi, head_index=rdx)
execute_cell:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 104
    mov r12, rdi
    mov r13, rsi
    mov r14, rdx
    mov rax, qword ptr [r13+40]
    cmp rax, MAX_OP
    ja .ec_bad
    lea rcx, [rip+hx0_semantics+SEM_OPMAP]
    movzx eax, byte ptr [rcx+rax]
    cmp eax, MAX_OP
    ja .ec_bad
    lea rcx, [rip+.op_table]
    jmp qword ptr [rcx+rax*8]

.op_halt:
    mov qword ptr [r12+80], 0
    jmp .ec_done
.op_emit:
    mov edi, dword ptr [r13+48]
    call putchar
    jmp .ec_done
.op_dir:
    # axis=a 0..4, sign=b
    mov rax, qword ptr [r13+48]
    cmp rax, 4
    ja .ec_done
    lea rdi, [r12+40]
    mov ecx, 5
    xor eax, eax
    rep stosq
    mov rax, qword ptr [r13+48]
    mov rcx, qword ptr [r13+56]
    mov qword ptr [r12+40+rax*8], rcx
    jmp .ec_done
.op_fork:
    mov rax, qword ptr [head_count]
    cmp rax, MAX_HEADS
    jae .ec_done
    mov rcx, rax
    imul rcx, HEAD_SIZE
    lea rdi, [rip+heads]
    add rdi, rcx
    mov rsi, r12
    mov ecx, HEAD_SIZE/8
    rep movsq
    # set cloned direction
    lea rdi, [rdi-HEAD_SIZE+40]
    mov ecx, 5
    xor eax, eax
    rep stosq
    mov rax, qword ptr [r13+48]
    cmp rax, 4
    ja .fork_finish
    mov rcx, qword ptr [r13+56]
    mov qword ptr [rdi-40+rax*8], rcx
.fork_finish:
    # A clone is born at its first child coordinate, not on the already-retired
    # parent cell. This makes FORK stable under mandatory self-modification.
    sub rdi, 80
    call advance_head
    inc qword ptr [head_count]
    jmp .ec_done
.op_sint:
    mov rdi, 1
    mov rsi, qword ptr [r13+48]
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_sdyad:
    mov rdi, 2
    mov rsi, qword ptr [r13+48]
    mov rdx, qword ptr [r13+56]
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_somega:
    mov rdi, 3
    xor esi, esi
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_sneg:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, 4
    mov rsi, rax
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_sadd:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov r15, rax
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, 5
    mov rsi, rax
    mov rdx, r15
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_scut:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov r15, rax                   # right
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rbx, rax                   # left
    mov rdi, rbx
    mov rsi, r15
    call finite_less
    cmp eax, -1                    # unknown allowed lazily
    je .cut_make
    test eax, eax
    jnz .cut_make
    lea rdi, [rip+cut_invalid]
    xor eax, eax
    call printf
    jmp .ec_done
.cut_make:
    mov rdi, 6
    mov rsi, rbx
    mov rdx, r15
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_sprint:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call print_node
    lea rdi, [rip+newline]
    xor eax, eax
    call printf
    jmp .ec_done
.op_qset:
    mov rax, qword ptr [r13+48]
    mov rcx, qword ptr [r13+56]
    movzx rdx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    cmp rax, rdx
    jae .q_bad
    cmp rcx, rdx
    jae .q_bad
    imul rax, rdx
    add rax, rcx
    mov qword ptr [r13+64], rax
    jmp .ec_done
.q_bad:
    lea rdi, [rip+qerr_fmt]
    xor eax, eax
    call printf
    jmp .ec_done
.op_entropy:
    call entropy_next
    mov r15, rax
    xor rdx, rdx
    mov rcx, 5
    div rcx
    mov r8, rdx                    # axis
    mov rcx, r15
    shr rcx, 8
    and rcx, 1
    lea r9, [rcx*2-1]              # sign -1/+1
    lea rdi, [r12+40]
    mov ecx, 5
    xor eax, eax
    rep stosq
    mov qword ptr [r12+40+r8*8], r9
    lea rdi, [rip+entropy_fmt]
    mov rsi, qword ptr [step_count]
    mov rdx, r14
    mov rcx, r15
    # r8 axis already, r9 sign already
    xor eax, eax
    call printf
    jmp .ec_done
.op_mutnext:
    # temporarily move coordinate, mutate target, restore
    sub rsp, 48
    mov rdi, rsp
    mov rsi, r12
    mov ecx, 5
    rep movsq
    mov rdi, r12
    call advance_head
    mov rdi, r12
    call find_cell
    mov r15, rax
    mov rdi, r12
    mov rsi, rsp
    mov ecx, 5
    rep movsq
    add rsp, 48
    test r15, r15
    jz .ec_done
    mov rcx, qword ptr [r13+48]
    test rcx, rcx
    jnz .mut_have
    mov rcx, 1
.mut_have:
    mov rax, qword ptr [r15+64]
    add rax, rcx
    xor rdx, rdx
    movzx rbx, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    div rbx
    mov qword ptr [r15+64], rdx
    mov rax, qword ptr [r15+40]
    add rax, rcx
    xor rdx, rdx
    mov rbx, MAX_OP+1
    div rbx
    mov qword ptr [r15+40], rdx
    jmp .ec_done
.op_collapse:
    xor rcx, rcx
    mov rax, qword ptr [head_count]
.col_loop:
    cmp rcx, rax
    jae .ec_done
    cmp rcx, r14
    je .col_next
    mov rdx, rcx
    imul rdx, HEAD_SIZE
    lea rdi, [rip+heads]
    add rdi, rdx
    mov qword ptr [rdi+80], 0
.col_next:
    inc rcx
    jmp .col_loop
.op_pix:
    mov rax, qword ptr [r12+0]
    cqo
    mov rcx, FB_W
    idiv rcx
    mov r8, rdx
    test r8, r8
    jns .px_xok
    add r8, FB_W
.px_xok:
    mov rax, qword ptr [r12+8]
    cqo
    mov rcx, FB_H
    idiv rcx
    mov r9, rdx
    test r9, r9
    jns .px_yok
    add r9, FB_H
.px_yok:
    mov rax, r9
    imul rax, FB_W
    add rax, r8
    imul rax, 3
    lea rdi, [rip+framebuffer]
    add rdi, rax
    mov rax, qword ptr [r13+48]
    mov rcx, rax
    shr rcx, 16
    mov byte ptr [rdi], cl
    mov rcx, rax
    shr rcx, 8
    mov byte ptr [rdi+1], cl
    mov byte ptr [rdi+2], al
    jmp .ec_done
.op_clear:
    mov rax, qword ptr [r13+48]
    mov r8, rax
    shr r8, 16
    mov r9, rax
    shr r9, 8
    lea rdi, [rip+framebuffer]
    mov rcx, FB_W*FB_H
.clr_loop:
    mov byte ptr [rdi], r8b
    mov byte ptr [rdi+1], r9b
    mov byte ptr [rdi+2], al
    add rdi, 3
    loop .clr_loop
    jmp .ec_done
.op_frame:
    call write_frame
    jmp .ec_done
.op_save:
    # Snapshot the state *after* this SAVE retires, while leaving the live
    # machine untouched so the normal retirement path still runs once.
    sub rsp, 144
    mov rdi, rsp
    mov rsi, r13
    mov ecx, CELL_SIZE/8
    rep movsq
    lea rdi, [rsp+80]
    mov rsi, r12
    mov ecx, 5
    rep movsq
    mov rax, qword ptr [step_count]
    mov qword ptr [rsp+120], rax
    mov rdi, r13
    call mutate_executed
    mov rdi, r12
    call advance_head
    inc qword ptr [step_count]
    call save_state
    mov rax, qword ptr [rsp+120]
    mov qword ptr [step_count], rax
    mov rdi, r12
    lea rsi, [rsp+80]
    mov ecx, 5
    rep movsq
    mov rdi, r13
    mov rsi, rsp
    mov ecx, CELL_SIZE/8
    rep movsq
    add rsp, 144
    jmp .ec_done
.op_dump:
    call dump_polyform
    jmp .ec_done
.op_nop:
    jmp .ec_done
.op_move:
    mov rax, qword ptr [r13+48]
    cmp rax, 4
    ja .ec_done
    mov rcx, qword ptr [r13+56]
    add qword ptr [r12+rax*8], rcx
    jmp .ec_done
.op_getchar:
    call getchar
    movsx rsi, eax
    mov rdi, 1
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done
.op_ifzero_dir:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call finite_is_zero
    test eax, eax
    jz .ec_done
    mov rax, qword ptr [r13+48]
    cmp rax, 4
    ja .ec_done
    lea rdi, [r12+40]
    mov ecx, 5
    xor eax, eax
    rep stosq
    mov rax, qword ptr [r13+48]
    mov rcx, qword ptr [r13+56]
    mov qword ptr [r12+40+rax*8], rcx
    jmp .ec_done
.op_hash:
    call compute_hash
    lea rdi, [rip+hash_fmt]
    mov rsi, rax
    xor eax, eax
    call printf
    jmp .ec_done

.op_nop25:
    jmp .ec_done

# RIP-MIRROR: create a temporary UNO-reversed 5D head, step it once backward,
# observe the live (possibly self-modified) cell there, mirror its Q² state into
# the current cell, then discard the probe. The executing head is never redirected.
.op_ripmirror:
    lea r15, [rip+.rip_anchor]
.rip_anchor:
    sub rsp, 96
    mov rdi, rsp
    mov rsi, r12
    mov ecx, HEAD_SIZE/8
    rep movsq
    neg qword ptr [rsp+40]
    neg qword ptr [rsp+48]
    neg qword ptr [rsp+56]
    neg qword ptr [rsp+64]
    neg qword ptr [rsp+72]
    mov rdi, rsp
    call advance_head

    lea rdi, [rip+rip_host_fmt]
    mov rsi, r15
    xor eax, eax
    call printf
    lea rdi, [rip+rip_vec_fmt]
    mov rsi, qword ptr [rsp+0]
    mov rdx, qword ptr [rsp+8]
    mov rcx, qword ptr [rsp+16]
    mov r8,  qword ptr [rsp+24]
    mov r9,  qword ptr [rsp+32]
    xor eax, eax
    call printf

    # Project physical RIP into five hexadecimal lanes. This projection is
    # observation only; the mirrored probe above remains the semantic reader.
    mov rsi, r15
    and rsi, 0xfff
    mov rdx, r15
    shr rdx, 12
    and rdx, 0xfff
    mov rcx, r15
    shr rcx, 24
    and rcx, 0xfff
    mov r8, r15
    shr r8, 36
    and r8, 0xfff
    mov r9, r15
    shr r9, 48
    and r9, 0xffff
    lea rdi, [rip+rip_hex_fmt]
    xor eax, eax
    call printf

    mov rdi, rsp
    call find_cell
    test rax, rax
    jz .rip_void
    mov rbx, rax
    lea rdi, [rip+rip_obs_fmt]
    mov rsi, qword ptr [rbx+40]
    mov rdx, qword ptr [rbx+64]
    xor eax, eax
    call printf
    mov rax, qword ptr [rbx+64]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    div rcx
    movzx rax, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    dec rax
    sub rax, rdx
    mov qword ptr [r13+64], rax
    add rsp, 96
    jmp .ec_done
.rip_void:
    lea rdi, [rip+rip_none_fmt]
    xor eax, eax
    call printf
    add rsp, 96
    jmp .ec_done

# NATIVE executes exact raw bytes carried by the Polyform. NABI0 deliberately
# accepts only straight-line register arithmetic ending in RET; no memory, calls,
# jumps, privileged operations or syscalls. The page is RW while copied, then RX.
.op_native:
    cmp qword ptr [native_enabled], 1
    jne .native_disabled
    mov r15, qword ptr [native_len]
    test r15, r15
    jnz .native_have
    lea rdi, [rip+native_missing]
    xor eax, eax
    call printf
    jmp .ec_done
.native_have:
    lea rdi, [rip+native_blob]
    mov rsi, r15
    call validate_native
    test eax, eax
    jnz .native_valid
    lea rdi, [rip+native_reject]
    xor eax, eax
    call printf
    jmp .ec_done
.native_valid:
    xor edi, edi
    mov esi, 4096
    mov edx, PROT_READ|PROT_WRITE
    mov ecx, MAP_PRIVATE|MAP_ANONYMOUS
    mov r8, -1
    xor r9d, r9d
    call mmap
    cmp rax, -1
    je .native_mapfail
    mov rbx, rax
    mov rdi, rbx
    lea rsi, [rip+native_blob]
    mov rcx, r15
    rep movsb
    mov rdi, rbx
    mov esi, 4096
    mov edx, PROT_READ|PROT_EXEC
    call mprotect
    test eax, eax
    jne .native_unmapfail
    call rbx                         # host RIP actually enters Polyform-originated bytes
    mov r15, rax
    lea rdi, [rip+native_fmt]
    mov rsi, r15
    mov rdx, qword ptr [native_len]
    xor eax, eax
    call printf
    mov rdi, rbx
    mov esi, 4096
    call munmap
    jmp .ec_done
.native_unmapfail:
    mov rdi, rbx
    mov esi, 4096
    call munmap
.native_mapfail:
    lea rdi, [rip+native_mmaperr]
    xor eax, eax
    call printf
    jmp .ec_done

# QPIX projects current Q² state onto the 64x64 surface. q drives Y/color;
# x/z/w/v fold into X, so a 5D path has a deterministic 2D projection.
.op_qpix:
    mov rax, qword ptr [r13+64]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    div rcx
    mov r10, rdx                    # q
    mov rax, r10
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov r8, rax                     # qa
    mov r9, rdx                     # qb

    mov rax, qword ptr [r12+0]
    mov rcx, qword ptr [r12+16]
    imul rcx, 7
    add rax, rcx
    mov rcx, qword ptr [r12+24]
    imul rcx, 11
    add rax, rcx
    mov rcx, qword ptr [r12+32]
    imul rcx, 13
    add rax, rcx
    cqo
    mov rcx, 64
    idiv rcx
    mov r11, rdx
    test r11, r11
    jns .qp_xok
    add r11, 64
.qp_xok:
    mov rax, qword ptr [r12+8]
    add rax, r10
    cqo
    mov rcx, 64
    idiv rcx
    mov rdx, rdx
    test rdx, rdx
    jns .qp_yok
    add rdx, 64
.qp_yok:
    mov rax, rdx
    imul rax, FB_W
    add rax, r11
    imul rax, 3
    lea rdi, [rip+framebuffer]
    add rdi, rax
    mov rax, r8
    imul rax, 63
    mov byte ptr [rdi], al
    mov rax, r9
    imul rax, 63
    mov byte ptr [rdi+1], al
    mov rax, r8
    add rax, r9
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    imul rdx, 63
    mov byte ptr [rdi+2], dl
    jmp .ec_done

.op_qtrace:
    mov rax, qword ptr [r13+64]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QSTATES]
    div rcx
    mov r15, rdx                    # old q normalized
    mov rax, r15
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov rbx, rax                    # old qa
    mov r10, rdx                    # old qb
    cmp qword ptr [phase_mode], 1
    je .qt_forward
    cmp qword ptr [phase_mode], 2
    je .qt_reverse
    mov rax, rbx
    add rax, r10
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBIAS]
    add rax, rcx
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov r11, rdx                    # new qa
    mov rax, r10
    add rax, rbx
    add rax, qword ptr [r13+40]
    xor rdx, rdx
    movzx rcx, byte ptr [rip+hx0_semantics+SEM_QBASE]
    div rcx
    mov rax, rdx                    # new qb
    jmp .qt_join
.qt_forward:
    mov rax, rbx
    add rax, r10
    xor rdx, rdx
    mov ecx, 5
    div rcx
    mov r11, rdx
    mov rax, r10
    add rax, r11
    xor rdx, rdx
    div rcx
    mov rax, rdx
    jmp .qt_join
.qt_reverse:
    # b=(B-A) mod 5, then a=(A-b) mod 5.
    mov rax, r10
    add rax, 5
    sub rax, rbx
    xor rdx, rdx
    mov ecx, 5
    div rcx
    mov r9, rdx
    mov r11, rbx
    add r11, 5
    sub r11, r9
    mov rax, r11
    xor edx, edx
    div rcx
    mov r11, rdx
    mov rax, r9
.qt_join:
    mov qword ptr [rsp+0], r11      # sixth vararg: nqa
    mov qword ptr [rsp+8], rax      # seventh vararg: nqb
    mov rcx, r11
    imul rcx, 5
    add rcx, rax                    # next q in rcx temporarily
    lea rdi, [rip+qtrace_fmt]
    cmp qword ptr [phase_mode], 0
    je .qt_format_ready
    lea rdi, [rip+phase_trace_fmt]
.qt_format_ready:
    mov rsi, r15                    # old
    mov rdx, rbx                    # qa
    # rcx must be qb for printf; next goes in r8
    mov r8, rcx
    mov rcx, r10
    mov r9, qword ptr [rsp+0]
    mov rax, qword ptr [rsp+8]
    mov qword ptr [rsp+0], rax      # stack arg nqb
    xor eax, eax
    call printf
    jmp .ec_done

.op_smul:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov r15, rax
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, 7
    mov rsi, rax
    mov rdx, r15
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done

.op_srecip:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, 8
    mov rsi, rax
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done

.op_somegapow:
    call stack_pop
    test rax, rax
    jz .ec_done
    mov rdi, 9
    mov rsi, rax
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done

# NATIVE_ACCEL lowers a run of HX87-native IR cells into a temporary host
# capsule. The IR remains authoritative Hexworld state; generated x86 is only
# an acceleration realization and is never persisted in snapshots.
.op_naccel:
    cmp qword ptr [native_enabled], 1
    jne .native_disabled
    mov rdi, r12
    mov rsi, r13
    call native_accelerate_ir
    test rdx, rdx
    jz .ec_done
    mov r15, rax
    mov rdi, 1
    mov rsi, r15
    xor edx, edx
    call new_node
    test rax, rax
    jz .ec_done
    mov rdi, rax
    call stack_push
    jmp .ec_done

.op_ir_direct:
    lea rdi, [rip+ir_direct]
    xor eax, eax
    call printf
    mov qword ptr [r12+80], 0
    jmp .ec_done

.native_disabled:
    lea rdi, [rip+native_disabled_fmt]
    xor eax, eax
    call printf
    mov qword ptr [r12+80], 0
    jmp .ec_done

.op_hexstat:
    lea rdi, [rip+hex_stat_fmt]
    mov rsi, qword ptr [hexworld_epoch]
    mov rdx, qword ptr [cell_count]
    mov rcx, qword ptr [head_count]
    mov r8, qword ptr [node_count]
    mov r9, qword ptr [entropy_seed]
    xor eax, eax
    call printf
    jmp .ec_done

.ec_bad:
    lea rdi, [rip+invalid_op_fmt]
    mov rsi, qword ptr [r13+40]
    # derive cell index
    lea rax, [rip+cells]
    mov rdx, r13
    sub rdx, rax
    mov rax, rdx
    xor edx, edx
    mov rcx, CELL_SIZE
    div rcx
    mov rdx, rax
    xor eax, eax
    call printf
    mov qword ptr [r12+80], 0
.ec_done:
    add rsp, 104
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

.align 8
.op_table:
    .quad .op_halt, .op_emit, .op_dir, .op_fork, .op_sint, .op_sdyad
    .quad .op_somega, .op_sneg, .op_sadd, .op_scut, .op_sprint, .op_qset
    .quad .op_entropy, .op_mutnext, .op_collapse, .op_pix, .op_clear, .op_frame
    .quad .op_save, .op_dump, .op_nop, .op_move, .op_getchar, .op_ifzero_dir, .op_hash, .op_nop25
    .quad .op_ripmirror, .op_native, .op_qpix, .op_qtrace, .op_smul, .op_srecip
    .quad .op_somegapow, .op_naccel, .op_ir_direct, .op_ir_direct, .op_ir_direct, .op_ir_direct
    .quad .op_hexstat

# validate_native(ptr=rdi,len=rsi) => eax=1 valid NABI0, 0 reject.
# Accepted exact x86-64 bytecode subset: NOP; MOV EAX,imm32; ADD/SUB/XOR
# EAX,imm32; IMUL EAX,EAX,imm32; final RET. No memory/control/syscalls.
validate_native:
    xor rdx, rdx
.vn_loop:
    cmp rdx, rsi
    jae .vn_bad
    movzx eax, byte ptr [rdi+rdx]
    cmp al, 0x90
    je .vn_1
    cmp al, 0xb8
    je .vn_5
    cmp al, 0x05
    je .vn_5
    cmp al, 0x2d
    je .vn_5
    cmp al, 0x35
    je .vn_5
    cmp al, 0x69
    je .vn_imul
    cmp al, 0xc3
    je .vn_ret
    jmp .vn_bad
.vn_1:
    inc rdx
    jmp .vn_loop
.vn_5:
    lea rcx, [rdx+5]
    cmp rcx, rsi
    ja .vn_bad
    mov rdx, rcx
    jmp .vn_loop
.vn_imul:
    lea rcx, [rdx+6]
    cmp rcx, rsi
    ja .vn_bad
    cmp byte ptr [rdi+rdx+1], 0xc0
    jne .vn_bad
    mov rdx, rcx
    jmp .vn_loop
.vn_ret:
    inc rdx
    cmp rdx, rsi
    jne .vn_bad
    mov eax, 1
    ret
.vn_bad:
    xor eax, eax
    ret

# native_accelerate_ir(head=rdi, trigger_cell=rsi) => rax=result, rdx=1 on success.
# Cells immediately following NATIVE_ACCEL along the current 5D direction are
# HX87 IR: NIMM/NADD/NXOR/NMUL. The IR is lowered into transient x86-64,
# transitioned RW->RX, executed, returned to Hexworld, then made non-executable
# and unmapped. Generated bytes are not part of the persisted machine state.
native_accelerate_ir:
    push rbp
    mov rbp, rsp
    push rbx
    push r12
    push r13
    push r14
    push r15
    sub rsp, 152
    mov r12, rdi
    mov r13, rsi
    cmp qword ptr [hexworld_active], 1
    jne .nai_bad
    mov r14, qword ptr [r13+48]
    test r14, r14
    jz .nai_bad
    cmp r14, MAX_ACCEL_IR
    ja .nai_bad
    mov qword ptr [rsp+88], r14

    # Temporary 5D probe begins at the trigger head.
    lea rdi, [rsp]
    mov rsi, r12
    mov ecx, HEAD_SIZE/8
    rep movsq

    # Every capsule starts from a deterministic zero accumulator: xor eax,eax.
    lea rdi, [rip+native_codegen]
    mov byte ptr [rdi+0], 0x31
    mov byte ptr [rdi+1], 0xc0
    mov rbx, 2
    mov r15, 1469598103934665603
    mov qword ptr [rsp+136], 0
.nai_scan:
    mov rcx, qword ptr [rsp+136]
    cmp rcx, r14
    jae .nai_scanned
    lea rdi, [rsp]
    call advance_head
    lea rdi, [rsp]
    call find_cell
    test rax, rax
    jz .nai_bad
    mov r10, rax
    mov r11, qword ptr [r10+40]

    # Source hash covers semantic IR op + immediate, not host addresses.
    xor r15, r11
    mov rax, 1099511628211
    imul r15, rax
    mov rcx, qword ptr [r10+48]
    xor r15, rcx
    mov rax, 1099511628211
    imul r15, rax

    # Native accelerator immediates are signed 32-bit by contract.
    mov rax, qword ptr [r10+48]
    movsxd rcx, eax
    cmp rax, rcx
    jne .nai_bad
    lea rdi, [rip+native_codegen]
    add rdi, rbx
    cmp r11, 34                 # NIMM
    je .nai_imm
    cmp r11, 35                 # NADD
    je .nai_add
    cmp r11, 36                 # NXOR
    je .nai_xor
    cmp r11, 37                 # NMUL
    je .nai_mul
    jmp .nai_bad
.nai_imm:
    cmp rbx, MAX_ACCEL_CODE-6
    jae .nai_bad
    mov byte ptr [rdi], 0xb8
    mov eax, dword ptr [r10+48]
    mov dword ptr [rdi+1], eax
    add rbx, 5
    jmp .nai_next
.nai_add:
    cmp rbx, MAX_ACCEL_CODE-6
    jae .nai_bad
    mov byte ptr [rdi], 0x05
    mov eax, dword ptr [r10+48]
    mov dword ptr [rdi+1], eax
    add rbx, 5
    jmp .nai_next
.nai_xor:
    cmp rbx, MAX_ACCEL_CODE-6
    jae .nai_bad
    mov byte ptr [rdi], 0x35
    mov eax, dword ptr [r10+48]
    mov dword ptr [rdi+1], eax
    add rbx, 5
    jmp .nai_next
.nai_mul:
    cmp rbx, MAX_ACCEL_CODE-7
    jae .nai_bad
    mov byte ptr [rdi], 0x69
    mov byte ptr [rdi+1], 0xc0
    mov eax, dword ptr [r10+48]
    mov dword ptr [rdi+2], eax
    add rbx, 6
.nai_next:
    inc qword ptr [rsp+136]
    jmp .nai_scan

.nai_scanned:
    lea rdi, [rip+native_codegen]
    mov byte ptr [rdi+rbx], 0xc3
    inc rbx
    mov qword ptr [native_codegen_len], rbx
    mov qword ptr [rsp+96], rbx
    mov qword ptr [rsp+112], r15

    # Hash the generated physical realization separately from the HX87 IR.
    mov r15, 1469598103934665603
    xor rcx, rcx
    lea rdi, [rip+native_codegen]
.nai_hash_loop:
    cmp rcx, rbx
    jae .nai_hash_done
    movzx rax, byte ptr [rdi+rcx]
    xor r15, rax
    mov rax, 1099511628211
    imul r15, rax
    inc rcx
    jmp .nai_hash_loop
.nai_hash_done:
    mov qword ptr [rsp+120], r15
    mov qword ptr [native_source_hash], r15
    # Correct source hash is restored below; native_code_hash gets generated hash.
    mov qword ptr [native_code_hash], r15
    mov rax, qword ptr [rsp+112]
    mov qword ptr [native_source_hash], rax

    xor edi, edi
    mov esi, 4096
    mov edx, PROT_READ|PROT_WRITE
    mov ecx, MAP_PRIVATE|MAP_ANONYMOUS
    mov r8, -1
    xor r9d, r9d
    call mmap
    cmp rax, -1
    je .nai_mapbad
    mov qword ptr [rsp+128], rax
    mov rdi, rax
    lea rsi, [rip+native_codegen]
    mov rcx, qword ptr [rsp+96]
    rep movsb
    mov rdi, qword ptr [rsp+128]
    mov esi, 4096
    mov edx, PROT_READ|PROT_EXEC
    call mprotect
    test eax, eax
    jne .nai_unmapbad

    mov rbx, qword ptr [rsp+128]
    call rbx
    movsxd rax, eax
    mov qword ptr [rsp+104], rax

    # Remove execute permission before releasing the host realization.
    mov rdi, qword ptr [rsp+128]
    mov esi, 4096
    mov edx, PROT_READ
    call mprotect
    mov rdi, qword ptr [rsp+128]
    mov esi, 4096
    call munmap

    # Consume the IR cells in semantic space. run_machine performs one more
    # normal advance after this operation, landing after the accelerated field.
    xor rbx, rbx
.nai_consume:
    cmp rbx, qword ptr [rsp+88]
    jae .nai_consumed
    mov rdi, r12
    call advance_head
    inc rbx
    jmp .nai_consume
.nai_consumed:
    inc qword ptr [native_accel_epoch]
    lea rdi, [rip+accel_fmt]
    mov rsi, qword ptr [native_accel_epoch]
    mov rdx, qword ptr [rsp+88]
    mov rcx, qword ptr [rsp+96]
    mov r8, qword ptr [rsp+104]
    mov r9, qword ptr [rsp+112]
    mov rax, qword ptr [rsp+120]
    mov qword ptr [rsp+0], rax
    xor eax, eax
    call printf
    mov rax, qword ptr [rsp+104]
    mov edx, 1
    jmp .nai_done

.nai_unmapbad:
    mov rdi, qword ptr [rsp+128]
    mov esi, 4096
    call munmap
.nai_mapbad:
    lea rdi, [rip+accel_maperr]
    xor eax, eax
    call printf
    xor eax, eax
    xor edx, edx
    jmp .nai_done
.nai_bad:
    lea rdi, [rip+accel_bad]
    xor eax, eax
    call printf
    xor eax, eax
    xor edx, edx
.nai_done:
    add rsp, 152
    pop r15
    pop r14
    pop r13
    pop r12
    pop rbx
    leave
    ret

# new_node(type=rdi,a=rsi,b=rdx) => rax=node_index+1 or 0
new_node:
    push rbp
    mov rbp, rsp
    mov rax, qword ptr [node_count]
    cmp rax, MAX_NODES
    jae .nn_over
    mov rcx, rax
    imul rcx, NODE_SIZE
    lea r8, [rip+nodes]
    add r8, rcx
    mov qword ptr [r8+0], rdi
    mov qword ptr [r8+8], rsi
    mov qword ptr [r8+16], rdx
    mov qword ptr [r8+24], 0
    inc qword ptr [node_count]
    inc rax
    leave
    ret
.nn_over:
    lea rdi, [rip+node_over]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

stack_push:
    mov rax, qword ptr [stack_top]
    cmp rax, MAX_STACK
    jae .sp_over
    lea rcx, [rip+sstack]
    mov qword ptr [rcx+rax*8], rdi
    inc qword ptr [stack_top]
    mov eax, 1
    ret
.sp_over:
    push rbp
    mov rbp, rsp
    lea rdi, [rip+stack_over]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

stack_pop:
    mov rax, qword ptr [stack_top]
    test rax, rax
    jz .spo_under
    dec rax
    mov qword ptr [stack_top], rax
    lea rcx, [rip+sstack]
    mov rax, qword ptr [rcx+rax*8]
    ret
.spo_under:
    push rbp
    mov rbp, rsp
    lea rdi, [rip+stack_under]
    xor eax, eax
    call printf
    xor eax, eax
    leave
    ret

# ptr from node ref in rdi => rax or 0
node_ptr:
    test rdi, rdi
    jz .np_none
    dec rdi
    cmp rdi, qword ptr [node_count]
    jae .np_none
    imul rdi, NODE_SIZE
    lea rax, [rip+nodes]
    add rax, rdi
    ret
.np_none:
    xor eax, eax
    ret

# finite_value node ref rdi => eax 1 if exact integer/dyad representable, rdx=num, rcx=exp ; 0 otherwise
finite_value:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    call node_ptr
    test rax, rax
    jz .fv_no
    mov r8, qword ptr [rax]
    cmp r8, 1
    je .fv_int
    cmp r8, 2
    je .fv_dyad
    cmp r8, 4
    je .fv_neg
    cmp r8, 5
    je .fv_add
    jmp .fv_no
.fv_int:
    mov rdx, qword ptr [rax+8]
    xor ecx, ecx
    mov eax, 1
    leave
    ret
.fv_dyad:
    mov rdx, qword ptr [rax+8]
    mov rcx, qword ptr [rax+16]
    cmp rcx, 60
    ja .fv_no
    mov eax, 1
    leave
    ret
.fv_neg:
    mov rdi, qword ptr [rax+8]
    call finite_value
    test eax, eax
    jz .fv_no
    neg rdx
    mov eax, 1
    leave
    ret
.fv_add:
    mov r9, qword ptr [rax+8]
    mov r10, qword ptr [rax+16]
    mov qword ptr [rbp-24], r9
    mov qword ptr [rbp-32], r10
    mov rdi, qword ptr [rbp-24]
    call finite_value
    test eax, eax
    jz .fv_no
    mov qword ptr [rbp-8], rdx
    mov qword ptr [rbp-16], rcx
    mov rdi, qword ptr [rbp-32]
    call finite_value
    test eax, eax
    jz .fv_no
    mov r8, qword ptr [rbp-16]
    cmp r8, rcx
    je .fv_add_same
    cmp r8, rcx
    ja .fv_shift_b
    # a has smaller exponent; scale a
    mov r9, rcx
    sub r9, r8
    cmp r9, 60
    ja .fv_no
    mov rax, qword ptr [rbp-8]
    mov cl, r9b
    shl rax, cl
    add rdx, rax
    mov rcx, qword ptr [rbp-16]
    add rcx, r9
    mov eax, 1
    leave
    ret
.fv_shift_b:
    mov r9, r8
    sub r9, rcx
    cmp r9, 60
    ja .fv_no
    mov rax, rdx
    mov cl, r9b
    shl rax, cl
    add rax, qword ptr [rbp-8]
    mov rdx, rax
    mov rcx, r8
    mov eax, 1
    leave
    ret
.fv_add_same:
    add rdx, qword ptr [rbp-8]
    mov rcx, r8
    mov eax, 1
    leave
    ret
.fv_no:
    xor eax, eax
    leave
    ret

# finite_less(left ref rdi,right ref rsi) => eax 1 true,0 false,-1 unknown
finite_less:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 40
    mov r12, rsi
    call finite_value
    test eax, eax
    jz .fl_unknown
    mov qword ptr [rbp-16], rdx
    mov qword ptr [rbp-24], rcx
    mov rdi, r12
    call finite_value
    test eax, eax
    jz .fl_unknown
    mov r8, qword ptr [rbp-24]
    cmp r8, rcx
    je .fl_cmp
    cmp r8, rcx
    ja .fl_scale_right
    mov r9, rcx
    sub r9, r8
    cmp r9, 60
    ja .fl_unknown
    mov rax, qword ptr [rbp-16]
    mov cl, r9b
    shl rax, cl
    mov qword ptr [rbp-16], rax
    jmp .fl_cmp
.fl_scale_right:
    mov r9, r8
    sub r9, rcx
    cmp r9, 60
    ja .fl_unknown
    mov rax, rdx
    mov cl, r9b
    shl rax, cl
    mov rdx, rax
.fl_cmp:
    mov rax, qword ptr [rbp-16]
    cmp rax, rdx
    setl al
    movzx eax, al
    add rsp, 40
    pop r12
    leave
    ret
.fl_unknown:
    mov eax, -1
    add rsp, 40
    pop r12
    leave
    ret

finite_is_zero:
    push rbp
    mov rbp, rsp
    call finite_value
    test eax, eax
    jz .fz_no
    test rdx, rdx
    setz al
    movzx eax, al
    leave
    ret
.fz_no:
    xor eax, eax
    leave
    ret

# print_node(ref rdi), depth-bounded implicitly by arena
print_node:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    mov qword ptr [rbp-8], rdi
    call node_ptr
    test rax, rax
    jz .pn_bad
    mov r8, qword ptr [rax]
    cmp r8, 1
    je .pn_int
    cmp r8, 2
    je .pn_dyad
    cmp r8, 3
    je .pn_omega
    cmp r8, 4
    je .pn_neg
    cmp r8, 5
    je .pn_add
    cmp r8, 6
    je .pn_cut
    cmp r8, 7
    je .pn_mul
    cmp r8, 8
    je .pn_inv
    cmp r8, 9
    je .pn_omegapow
    jmp .pn_bad
.pn_int:
    lea rdi, [rip+node_int_fmt]
    mov rsi, qword ptr [rax+8]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_dyad:
    lea rdi, [rip+node_dyad_fmt]
    mov rsi, qword ptr [rax+8]
    mov rdx, qword ptr [rax+16]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_omega:
    lea rdi, [rip+node_omega]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_neg:
    mov r9, qword ptr [rax+8]
    mov qword ptr [rbp-16], r9
    lea rdi, [rip+node_neg_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_rp]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_add:
    mov r9, qword ptr [rax+8]
    mov r10, qword ptr [rax+16]
    mov qword ptr [rbp-16], r9
    mov qword ptr [rbp-24], r10
    lea rdi, [rip+node_add_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_plus]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-24]
    call print_node
    lea rdi, [rip+node_rp]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_cut:
    mov r9, qword ptr [rax+8]
    mov r10, qword ptr [rax+16]
    mov qword ptr [rbp-16], r9
    mov qword ptr [rbp-24], r10
    lea rdi, [rip+node_cut_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_bar]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-24]
    call print_node
    lea rdi, [rip+node_cut_r]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_mul:
    mov r9, qword ptr [rax+8]
    mov r10, qword ptr [rax+16]
    mov qword ptr [rbp-16], r9
    mov qword ptr [rbp-24], r10
    lea rdi, [rip+node_mul_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_mul]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-24]
    call print_node
    lea rdi, [rip+node_rp]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_inv:
    mov r9, qword ptr [rax+8]
    mov qword ptr [rbp-16], r9
    lea rdi, [rip+node_inv_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_rp]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_omegapow:
    mov r9, qword ptr [rax+8]
    mov qword ptr [rbp-16], r9
    lea rdi, [rip+node_omegapow_l]
    xor eax, eax
    call printf
    mov rdi, qword ptr [rbp-16]
    call print_node
    lea rdi, [rip+node_rp]
    xor eax, eax
    call printf
    jmp .pn_done
.pn_bad:
    lea rdi, [rip+node_bad]
    xor eax, eax
    call printf
.pn_done:
    leave
    ret

write_frame:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    lea rdi, [rip+frame_name]
    lea rsi, [rip+mode_wb]
    call fopen
    test rax, rax
    jz .wf_done
    mov r12, rax
    mov rdi, r12
    lea rsi, [rip+ppm_header]
    xor eax, eax
    call fprintf
    lea rdi, [rip+framebuffer]
    mov esi, 1
    mov edx, FB_SIZE
    mov rcx, r12
    call fwrite
    mov rdi, r12
    call fclose
.wf_done:
    add rsp, 8
    pop r12
    leave
    ret

save_state:
    push rbp
    mov rbp, rsp
    push r12
    sub rsp, 8
    lea rdi, [rip+state_name]
    lea rsi, [rip+mode_wb]
    call fopen
    test rax, rax
    jz .ss_done
    mov r12, rax
    lea rdi, [rip+state_begin]
    mov esi, 1
    lea rdx, [rip+state_end]
    lea rax, [rip+state_begin]
    sub rdx, rax
    mov rcx, r12
    call fwrite
    mov rdi, r12
    call fclose
    lea rdi, [rip+save_fmt]
    lea rsi, [rip+state_name]
    lea rdx, [rip+state_end]
    lea rax, [rip+state_begin]
    sub rdx, rax
    xor eax, eax
    call printf
.ss_done:
    add rsp, 8
    pop r12
    leave
    ret

# int load_state(path)
load_state:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 8
    mov r12, rdi
    mov rdi, r12
    lea rsi, [rip+mode_rb]
    call fopen
    test rax, rax
    jz .ls_fail
    mov r13, rax
    lea rdi, [rip+state_begin]
    mov esi, 1
    lea rdx, [rip+state_end]
    lea rax, [rip+state_begin]
    sub rdx, rax
    mov rcx, r13
    call fread
    mov r14, rax
    mov rdi, r13
    call fclose
    lea rax, [rip+state_end]
    lea rcx, [rip+state_begin]
    sub rax, rcx
    cmp r14, rax
    jne .ls_fail
    mov rax, SNAP_MAGIC
    cmp qword ptr [snapshot_magic], rax
    jne .ls_fail
    cmp qword ptr [cell_count], MAX_CELLS
    ja .ls_fail
    cmp qword ptr [head_count], 1
    jb .ls_fail
    cmp qword ptr [head_count], MAX_HEADS
    ja .ls_fail
    cmp qword ptr [stack_top], MAX_STACK
    ja .ls_fail
    cmp qword ptr [node_count], MAX_NODES
    ja .ls_fail
    cmp qword ptr [native_len], MAX_NATIVE
    ja .ls_fail
    cmp qword ptr [phase_mode], 2
    ja .ls_fail
    cmp qword ptr [target_enabled], 1
    ja .ls_fail
    cmp qword ptr [target_q], 24
    ja .ls_fail
    cmp qword ptr [best_score], 5
    ja .ls_fail
    cmp qword ptr [target_found], 1
    ja .ls_fail
    cmp qword ptr [hexworld_active], 1
    jne .ls_fail
    xor eax, eax
    add rsp, 8
    pop r14
    pop r13
    pop r12
    leave
    ret
.ls_fail:
    lea rdi, [rip+snapshot_bad]
    xor eax, eax
    call printf
    mov eax, 1
    add rsp, 8
    pop r14
    pop r13
    pop r12
    leave
    ret

dump_polyform:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14
    sub rsp, 56
    lea rdi, [rip+regen_name]
    lea rsi, [rip+mode_wb]
    call fopen
    test rax, rax
    jz .dp_done
    mov r12, rax
    mov rdi, r12
    lea rsi, [rip+header_out]
    xor eax, eax
    call fprintf
    xor r13, r13
.dp_loop:
    cmp r13, qword ptr [cell_count]
    jae .dp_close
    mov rax, r13
    imul rax, CELL_SIZE
    lea r14, [rip+cells]
    add r14, rax
    mov rdi, r12
    lea rsi, [rip+cell_out]
    mov rdx, qword ptr [r14+0]
    mov rcx, qword ptr [r14+8]
    mov r8, qword ptr [r14+16]
    mov r9, qword ptr [r14+24]
    mov rax, qword ptr [r14+32]
    mov qword ptr [rsp+0], rax
    mov rax, qword ptr [r14+40]
    mov qword ptr [rsp+8], rax
    mov rax, qword ptr [r14+48]
    mov qword ptr [rsp+16], rax
    mov rax, qword ptr [r14+56]
    mov qword ptr [rsp+24], rax
    mov rax, qword ptr [r14+64]
    mov qword ptr [rsp+32], rax
    xor eax, eax
    call fprintf
    inc r13
    jmp .dp_loop
.dp_close:
    mov rax, qword ptr [native_len]
    test rax, rax
    jz .dp_really_close
    mov rdi, r12
    lea rsi, [rip+native_header_out]
    mov rdx, rax
    xor eax, eax
    call fprintf
    lea rdi, [rip+native_blob]
    mov esi, 1
    mov rdx, qword ptr [native_len]
    mov rcx, r12
    call fwrite
.dp_really_close:
    mov rdi, r12
    call fclose
    lea rdi, [rip+dump_fmt]
    lea rsi, [rip+regen_name]
    mov rdx, qword ptr [cell_count]
    xor eax, eax
    call printf
.dp_done:
    add rsp, 56
    pop r14
    pop r13
    pop r12
    leave
    ret

compute_hash:
    push rbp
    mov rbp, rsp
    mov rax, 0xcbf29ce484222325
    mov rcx, qword ptr [cell_count]
    imul rcx, CELL_SIZE
    lea rsi, [rip+cells]
    xor rdx, rdx
.ch_loop:
    cmp rdx, rcx
    jae .ch_done
    movzx r8, byte ptr [rsi+rdx]
    xor rax, r8
    mov r8, 0x100000001b3
    imul rax, r8
    inc rdx
    jmp .ch_loop
.ch_done:
    # The transition law is part of the semantic state, including at step zero.
    cmp qword ptr [phase_mode], 0
    je .ch_legacy
    xor rax, qword ptr [phase_mode]
    mov r9, 0x100000001b3
    imul rax, r9
.ch_legacy:
    cmp qword ptr [target_enabled], 0
    je .ch_no_target
    xor rax, qword ptr [target_q]
    mov r9, 0x100000001b3
    imul rax, r9
    xor rax, qword ptr [best_score]
    imul rax, r9
    xor rax, qword ptr [target_found]
    imul rax, r9
.ch_no_target:
    mov r8, qword ptr [native_len]
    xor rax, r8
    mov r9, 0x100000001b3
    imul rax, r9
    xor rdx, rdx
    lea rsi, [rip+native_blob]
.ch_native:
    cmp rdx, r8
    jae .ch_return
    movzx rcx, byte ptr [rsi+rdx]
    xor rax, rcx
    imul rax, r9
    inc rdx
    jmp .ch_native
.ch_return:
    leave
    ret

.section .note.GNU-stack,"",@progbits
