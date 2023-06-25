; NOTE: Assertions have been autogenerated by utils/update_mir_test_checks.py
; RUN: llc -mtriple=aarch64-darwin-ios13 -O0 -global-isel -stop-after=irtranslator -verify-machineinstrs -o - %s | FileCheck %s

define void @asm_simple_memory_clobber() {
  ; CHECK-LABEL: name: asm_simple_memory_clobber
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"", 25 /* sideeffect mayload maystore attdialect */, !0
  ; CHECK-NEXT:   INLINEASM &"", 1 /* sideeffect attdialect */, !0
  ; CHECK-NEXT:   RET_ReallyLR
  call void asm sideeffect "", "~{memory}"(), !srcloc !0
  call void asm sideeffect "", ""(), !srcloc !0
  ret void
}

!0 = !{i32 70}

define void @asm_simple_register_clobber() {
  ; CHECK-LABEL: name: asm_simple_register_clobber
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"mov x0, 7", 1 /* sideeffect attdialect */, 12 /* clobber */, implicit-def early-clobber $x0, !0
  ; CHECK-NEXT:   RET_ReallyLR
  call void asm sideeffect "mov x0, 7", "~{x0}"(), !srcloc !0
  ret void
}

define i64 @asm_register_early_clobber() {
  ; CHECK-LABEL: name: asm_register_early_clobber
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"mov $0, 7; mov $1, 7", 1 /* sideeffect attdialect */, 2555915 /* regdef-ec:GPR64common */, def early-clobber %0, 2555915 /* regdef-ec:GPR64common */, def early-clobber %1, !0
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY %0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s64) = COPY %1
  ; CHECK-NEXT:   [[ADD:%[0-9]+]]:_(s64) = G_ADD [[COPY]], [[COPY1]]
  ; CHECK-NEXT:   $x0 = COPY [[ADD]](s64)
  ; CHECK-NEXT:   RET_ReallyLR implicit $x0
  call { i64, i64 } asm sideeffect "mov $0, 7; mov $1, 7", "=&r,=&r"(), !srcloc !0
  %asmresult = extractvalue { i64, i64 } %1, 0
  %asmresult1 = extractvalue { i64, i64 } %1, 1
  %add = add i64 %asmresult, %asmresult1
  ret i64 %add
}

define i32 @test_specific_register_output() nounwind ssp {
  ; CHECK-LABEL: name: test_specific_register_output
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   INLINEASM &"mov ${0:w}, 7", 0 /* attdialect */, 10 /* regdef */, implicit-def $w0
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY $w0
  ; CHECK-NEXT:   $w0 = COPY [[COPY]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  %0 = tail call i32 asm "mov ${0:w}, 7", "={w0}"() nounwind
  ret i32 %0
}

define i32 @test_single_register_output() nounwind ssp {
  ; CHECK-LABEL: name: test_single_register_output
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   INLINEASM &"mov ${0:w}, 7", 0 /* attdialect */, 1507338 /* regdef:GPR32common */, def %0
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY %0
  ; CHECK-NEXT:   $w0 = COPY [[COPY]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  %0 = tail call i32 asm "mov ${0:w}, 7", "=r"() nounwind
  ret i32 %0
}

define i64 @test_single_register_output_s64() nounwind ssp {
  ; CHECK-LABEL: name: test_single_register_output_s64
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   INLINEASM &"mov $0, 7", 0 /* attdialect */, 2555914 /* regdef:GPR64common */, def %0
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY %0
  ; CHECK-NEXT:   $x0 = COPY [[COPY]](s64)
  ; CHECK-NEXT:   RET_ReallyLR implicit $x0
entry:
  %0 = tail call i64 asm "mov $0, 7", "=r"() nounwind
  ret i64 %0
}

; Check support for returning several floats
define float @test_multiple_register_outputs_same() #0 {
  ; CHECK-LABEL: name: test_multiple_register_outputs_same
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"mov $0, #0; mov $1, #0", 0 /* attdialect */, 1507338 /* regdef:GPR32common */, def %0, 1507338 /* regdef:GPR32common */, def %1
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY %0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY %1
  ; CHECK-NEXT:   [[FADD:%[0-9]+]]:_(s32) = G_FADD [[COPY]], [[COPY1]]
  ; CHECK-NEXT:   $s0 = COPY [[FADD]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $s0
  %1 = call { float, float } asm "mov $0, #0; mov $1, #0", "=r,=r"()
  %asmresult = extractvalue { float, float } %1, 0
  %asmresult1 = extractvalue { float, float } %1, 1
  %add = fadd float %asmresult, %asmresult1
  ret float %add
}

; Check support for returning several floats
define double @test_multiple_register_outputs_mixed() #0 {
  ; CHECK-LABEL: name: test_multiple_register_outputs_mixed
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"mov $0, #0; mov $1, #0", 0 /* attdialect */, 1507338 /* regdef:GPR32common */, def %0, 2359306 /* regdef:FPR64 */, def %1
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s32) = COPY %0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s64) = COPY %1
  ; CHECK-NEXT:   $d0 = COPY [[COPY1]](s64)
  ; CHECK-NEXT:   RET_ReallyLR implicit $d0
  %1 = call { float, double } asm "mov $0, #0; mov $1, #0", "=r,=w"()
  %asmresult = extractvalue { float, double } %1, 1
  ret double %asmresult
}

define i32 @test_specific_register_output_trunc() nounwind ssp {
  ; CHECK-LABEL: name: test_specific_register_output_trunc
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   INLINEASM &"mov ${0:w}, 7", 0 /* attdialect */, 10 /* regdef */, implicit-def $x0
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $x0
  ; CHECK-NEXT:   [[TRUNC:%[0-9]+]]:_(s32) = G_TRUNC [[COPY]](s64)
  ; CHECK-NEXT:   $w0 = COPY [[TRUNC]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  %0 = tail call i32 asm "mov ${0:w}, 7", "={x0}"() nounwind
  ret i32 %0
}

define zeroext i8 @test_register_output_trunc(ptr %src) nounwind {
  ;
  ; CHECK-LABEL: name: test_register_output_trunc
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   liveins: $x0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; CHECK-NEXT:   INLINEASM &"mov ${0:w}, 32", 0 /* attdialect */, 1507338 /* regdef:GPR32common */, def %1
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY %1
  ; CHECK-NEXT:   [[TRUNC:%[0-9]+]]:_(s8) = G_TRUNC [[COPY1]](s32)
  ; CHECK-NEXT:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s8)
  ; CHECK-NEXT:   $w0 = COPY [[ZEXT]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  %0 = tail call i8 asm "mov ${0:w}, 32", "=r"() nounwind
  ret i8 %0
}

define float @test_vector_output() nounwind {
  ; CHECK-LABEL: name: test_vector_output
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 0
  ; CHECK-NEXT:   INLINEASM &"fmov ${0}.2s, #1.0", 1 /* sideeffect attdialect */, 10 /* regdef */, implicit-def $d14
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(<2 x s32>) = COPY $d14
  ; CHECK-NEXT:   [[EVEC:%[0-9]+]]:_(s32) = G_EXTRACT_VECTOR_ELT [[COPY]](<2 x s32>), [[C]](s64)
  ; CHECK-NEXT:   $s0 = COPY [[EVEC]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $s0
  %1 = tail call <2 x float> asm sideeffect "fmov ${0}.2s, #1.0", "={v14}"() nounwind
  %2 = extractelement <2 x float> %1, i32 0
  ret float %2
}

define void @test_input_register_imm() {
  ; CHECK-LABEL: name: test_input_register_imm
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 42
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:gpr64common = COPY [[C]](s64)
  ; CHECK-NEXT:   INLINEASM &"mov x0, $0", 1 /* sideeffect attdialect */, 2555913 /* reguse:GPR64common */, [[COPY]]
  ; CHECK-NEXT:   RET_ReallyLR
  call void asm sideeffect "mov x0, $0", "r"(i64 42)
  ret void
}

; Make sure that boolean immediates are properly (zero) extended.
define i32 @test_boolean_imm_ext() {
  ; CHECK-LABEL: name: test_boolean_imm_ext
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s32) = G_CONSTANT i32 1
  ; CHECK-NEXT:   INLINEASM &"#TEST 42 + ${0:c} - .\0A\09", 9 /* sideeffect mayload attdialect */, 13 /* imm */, 1
  ; CHECK-NEXT:   $w0 = COPY [[C]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  tail call void asm sideeffect "#TEST 42 + ${0:c} - .\0A\09", "i"(i1 true)
  ret i32 1
}

define void @test_input_imm() {
  ; CHECK-LABEL: name: test_input_imm
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   INLINEASM &"mov x0, $0", 9 /* sideeffect mayload attdialect */, 13 /* imm */, 42
  ; CHECK-NEXT:   RET_ReallyLR
  call void asm sideeffect "mov x0, $0", "i"(i64 42)
  ret void
}

define zeroext i8 @test_input_register(ptr %src) nounwind {
  ; CHECK-LABEL: name: test_input_register
  ; CHECK: bb.1.entry:
  ; CHECK-NEXT:   liveins: $x0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:gpr64common = COPY [[COPY]](p0)
  ; CHECK-NEXT:   INLINEASM &"ldtrb ${0:w}, [$1]", 0 /* attdialect */, 1507338 /* regdef:GPR32common */, def %1, 2555913 /* reguse:GPR64common */, [[COPY1]]
  ; CHECK-NEXT:   [[COPY2:%[0-9]+]]:_(s32) = COPY %1
  ; CHECK-NEXT:   [[TRUNC:%[0-9]+]]:_(s8) = G_TRUNC [[COPY2]](s32)
  ; CHECK-NEXT:   [[ZEXT:%[0-9]+]]:_(s32) = G_ZEXT [[TRUNC]](s8)
  ; CHECK-NEXT:   $w0 = COPY [[ZEXT]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
entry:
  %0 = tail call i8 asm "ldtrb ${0:w}, [$1]", "=r,r"(ptr %src) nounwind
  ret i8 %0
}

define i32 @test_memory_constraint(ptr %a) nounwind {
  ; CHECK-LABEL: name: test_memory_constraint
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   liveins: $x0
  ; CHECK-NEXT: {{  $}}
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(p0) = COPY $x0
  ; CHECK-NEXT:   INLINEASM &"ldr $0, $1", 8 /* mayload attdialect */, 1507338 /* regdef:GPR32common */, def %1, 262158 /* mem:m */, [[COPY]](p0)
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY %1
  ; CHECK-NEXT:   $w0 = COPY [[COPY1]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
  %1 = tail call i32 asm "ldr $0, $1", "=r,*m"(ptr elementtype(i32) %a)
  ret i32 %1
}

define i16 @test_anyext_input() {
  ; CHECK-LABEL: name: test_anyext_input
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s16) = G_CONSTANT i16 1
  ; CHECK-NEXT:   [[ANYEXT:%[0-9]+]]:_(s32) = G_ANYEXT [[C]](s16)
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:gpr32common = COPY [[ANYEXT]](s32)
  ; CHECK-NEXT:   INLINEASM &"", 1 /* sideeffect attdialect */, 1507338 /* regdef:GPR32common */, def %0, 1507337 /* reguse:GPR32common */, [[COPY]]
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY %0
  ; CHECK-NEXT:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY1]](s32)
  ; CHECK-NEXT:   [[ANYEXT1:%[0-9]+]]:_(s32) = G_ANYEXT [[TRUNC]](s16)
  ; CHECK-NEXT:   $w0 = COPY [[ANYEXT1]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
  %1 = call i16 asm sideeffect "", "=r,r"(i16 1)
  ret i16 %1
}

define i16 @test_anyext_input_with_matching_constraint() {
  ; CHECK-LABEL: name: test_anyext_input_with_matching_constraint
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s16) = G_CONSTANT i16 1
  ; CHECK-NEXT:   [[ANYEXT:%[0-9]+]]:_(s32) = G_ANYEXT [[C]](s16)
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:gpr32common = COPY [[ANYEXT]](s32)
  ; CHECK-NEXT:   INLINEASM &"", 1 /* sideeffect attdialect */, 1507338 /* regdef:GPR32common */, def %0, 2147483657 /* reguse tiedto:$0 */, [[COPY]](tied-def 3)
  ; CHECK-NEXT:   [[COPY1:%[0-9]+]]:_(s32) = COPY %0
  ; CHECK-NEXT:   [[TRUNC:%[0-9]+]]:_(s16) = G_TRUNC [[COPY1]](s32)
  ; CHECK-NEXT:   [[ANYEXT1:%[0-9]+]]:_(s32) = G_ANYEXT [[TRUNC]](s16)
  ; CHECK-NEXT:   $w0 = COPY [[ANYEXT1]](s32)
  ; CHECK-NEXT:   RET_ReallyLR implicit $w0
  %1 = call i16 asm sideeffect "", "=r,0"(i16 1)
  ret i16 %1
}

define i64 @test_input_with_matching_constraint_to_physical_register() {
  ; CHECK-LABEL: name: test_input_with_matching_constraint_to_physical_register
  ; CHECK: bb.1 (%ir-block.0):
  ; CHECK-NEXT:   [[C:%[0-9]+]]:_(s64) = G_CONSTANT i64 0
  ; CHECK-NEXT:   INLINEASM &"", 0 /* attdialect */, 10 /* regdef */, implicit-def $x2, 2147483657 /* reguse tiedto:$0 */, [[C]](tied-def 3)(s64)
  ; CHECK-NEXT:   [[COPY:%[0-9]+]]:_(s64) = COPY $x2
  ; CHECK-NEXT:   $x0 = COPY [[COPY]](s64)
  ; CHECK-NEXT:   RET_ReallyLR implicit $x0
  %1 = tail call i64 asm "", "={x2},0"(i64 0)
  ret i64 %1
}