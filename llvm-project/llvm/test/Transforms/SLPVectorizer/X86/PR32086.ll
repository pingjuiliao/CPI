; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -passes=slp-vectorizer -slp-vectorize-hor -slp-vectorize-hor-store -S < %s -mtriple=x86_64-unknown-linux-gnu -mcpu=bdver2 | FileCheck %s

define void @i64_simplified(ptr noalias %st, ptr noalias %ld) {
; CHECK-LABEL: @i64_simplified(
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, ptr [[LD:%.*]], align 8
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <2 x i64> [[TMP2]], <2 x i64> poison, <4 x i32> <i32 0, i32 1, i32 0, i32 1>
; CHECK-NEXT:    store <4 x i64> [[SHUFFLE]], ptr [[ST:%.*]], align 8
; CHECK-NEXT:    ret void
;
  %arrayidx1 = getelementptr inbounds i64, ptr %ld, i64 1

  %t0 = load i64, ptr %ld, align 8
  %t1 = load i64, ptr %arrayidx1, align 8

  %arrayidx3 = getelementptr inbounds i64, ptr %st, i64 1
  %arrayidx4 = getelementptr inbounds i64, ptr %st, i64 2
  %arrayidx5 = getelementptr inbounds i64, ptr %st, i64 3

  store i64 %t0, ptr %st, align 8
  store i64 %t1, ptr %arrayidx3, align 8
  store i64 %t0, ptr %arrayidx4, align 8
  store i64 %t1, ptr %arrayidx5, align 8
  ret void
}

define void @i64_simplifiedi_reversed(ptr noalias %st, ptr noalias %ld) {
; CHECK-LABEL: @i64_simplifiedi_reversed(
; CHECK-NEXT:    [[TMP2:%.*]] = load <2 x i64>, ptr [[LD:%.*]], align 8
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <2 x i64> [[TMP2]], <2 x i64> poison, <4 x i32> <i32 1, i32 0, i32 1, i32 0>
; CHECK-NEXT:    store <4 x i64> [[SHUFFLE]], ptr [[ST:%.*]], align 8
; CHECK-NEXT:    ret void
;
  %arrayidx1 = getelementptr inbounds i64, ptr %ld, i64 1

  %t0 = load i64, ptr %ld, align 8
  %t1 = load i64, ptr %arrayidx1, align 8

  %arrayidx3 = getelementptr inbounds i64, ptr %st, i64 1
  %arrayidx4 = getelementptr inbounds i64, ptr %st, i64 2
  %arrayidx5 = getelementptr inbounds i64, ptr %st, i64 3

  store i64 %t1, ptr %st, align 8
  store i64 %t0, ptr %arrayidx3, align 8
  store i64 %t1, ptr %arrayidx4, align 8
  store i64 %t0, ptr %arrayidx5, align 8
  ret void
}

define void @i64_simplifiedi_extract(ptr noalias %st, ptr noalias %ld) {
; CHECK-LABEL: @i64_simplifiedi_extract(
; CHECK-NEXT:    [[ARRAYIDX1:%.*]] = getelementptr inbounds i64, ptr [[LD:%.*]], i64 1
; CHECK-NEXT:    [[T0:%.*]] = load i64, ptr [[LD]], align 8
; CHECK-NEXT:    [[T1:%.*]] = load i64, ptr [[ARRAYIDX1]], align 8
; CHECK-NEXT:    [[ARRAYIDX3:%.*]] = getelementptr inbounds i64, ptr [[ST:%.*]], i64 1
; CHECK-NEXT:    [[ARRAYIDX4:%.*]] = getelementptr inbounds i64, ptr [[ST]], i64 2
; CHECK-NEXT:    [[ARRAYIDX5:%.*]] = getelementptr inbounds i64, ptr [[ST]], i64 3
; CHECK-NEXT:    store i64 [[T0]], ptr [[ST]], align 8
; CHECK-NEXT:    store i64 [[T0]], ptr [[ARRAYIDX3]], align 8
; CHECK-NEXT:    store i64 [[T0]], ptr [[ARRAYIDX4]], align 8
; CHECK-NEXT:    store i64 [[T1]], ptr [[ARRAYIDX5]], align 8
; CHECK-NEXT:    store i64 [[T1]], ptr [[LD]], align 8
; CHECK-NEXT:    ret void
;
  %arrayidx1 = getelementptr inbounds i64, ptr %ld, i64 1

  %t0 = load i64, ptr %ld, align 8
  %t1 = load i64, ptr %arrayidx1, align 8

  %arrayidx3 = getelementptr inbounds i64, ptr %st, i64 1
  %arrayidx4 = getelementptr inbounds i64, ptr %st, i64 2
  %arrayidx5 = getelementptr inbounds i64, ptr %st, i64 3

  store i64 %t0, ptr %st, align 8
  store i64 %t0, ptr %arrayidx3, align 8
  store i64 %t0, ptr %arrayidx4, align 8
  store i64 %t1, ptr %arrayidx5, align 8
  store i64 %t1, ptr %ld, align 8
  ret void
}
