; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --version 5
; RUN: opt -S -passes=sccp < %s | FileCheck %s

define i1 @test_no_attr(ptr %p) {
; CHECK-LABEL: define i1 @test_no_attr(
; CHECK-SAME: ptr [[P:%.*]]) {
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne ptr [[P]], null
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %cmp = icmp ne ptr %p, null
  ret i1 %cmp
}

define i1 @test_nonnull(ptr nonnull %p) {
; CHECK-LABEL: define i1 @test_nonnull(
; CHECK-SAME: ptr nonnull [[P:%.*]]) {
; CHECK-NEXT:    ret i1 true
;
  %cmp = icmp ne ptr %p, null
  ret i1 %cmp
}

define i1 @test_nonnull_eq(ptr nonnull %p) {
; CHECK-LABEL: define i1 @test_nonnull_eq(
; CHECK-SAME: ptr nonnull [[P:%.*]]) {
; CHECK-NEXT:    ret i1 false
;
  %cmp = icmp eq ptr %p, null
  ret i1 %cmp
}

define i1 @test_dereferenceable(ptr dereferenceable(4) %p) {
; CHECK-LABEL: define i1 @test_dereferenceable(
; CHECK-SAME: ptr dereferenceable(4) [[P:%.*]]) {
; CHECK-NEXT:    ret i1 true
;
  %cmp = icmp ne ptr %p, null
  ret i1 %cmp
}

define i1 @test_gep_no_flags(ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_gep_no_flags(
; CHECK-SAME: ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne ptr [[GEP]], null
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %gep = getelementptr i8, ptr %p, i64 %x
  %cmp = icmp ne ptr %gep, null
  ret i1 %cmp
}

define i1 @test_gep_nuw(ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_gep_nuw(
; CHECK-SAME: ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr nuw i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    ret i1 true
;
  %gep = getelementptr nuw i8, ptr %p, i64 %x
  %cmp = icmp ne ptr %gep, null
  ret i1 %cmp
}

define i1 @test_gep_inbounds(ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_gep_inbounds(
; CHECK-SAME: ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    ret i1 true
;
  %gep = getelementptr inbounds i8, ptr %p, i64 %x
  %cmp = icmp ne ptr %gep, null
  ret i1 %cmp
}

define i1 @test_gep_inbounds_null_pointer_valid(ptr nonnull %p, i64 %x) null_pointer_is_valid {
; CHECK-LABEL: define i1 @test_gep_inbounds_null_pointer_valid(
; CHECK-SAME: ptr nonnull [[P:%.*]], i64 [[X:%.*]]) #[[ATTR0:[0-9]+]] {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr inbounds i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne ptr [[GEP]], null
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %gep = getelementptr inbounds i8, ptr %p, i64 %x
  %cmp = icmp ne ptr %gep, null
  ret i1 %cmp
}

define i1 @test_select(i1 %c, ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_select(
; CHECK-SAME: i1 [[C:%.*]], ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr nuw i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[C]], ptr [[P]], ptr [[GEP]]
; CHECK-NEXT:    ret i1 true
;
  %gep = getelementptr nuw i8, ptr %p, i64 %x
  %sel = select i1 %c, ptr %p, ptr %gep
  %cmp = icmp ne ptr %sel, null
  ret i1 %cmp
}

define i1 @test_select_not_nuw(i1 %c, ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_select_not_nuw(
; CHECK-SAME: i1 [[C:%.*]], ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    [[SEL:%.*]] = select i1 [[C]], ptr [[P]], ptr [[GEP]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp ne ptr [[SEL]], null
; CHECK-NEXT:    ret i1 [[CMP]]
;
  %gep = getelementptr i8, ptr %p, i64 %x
  %sel = select i1 %c, ptr %p, ptr %gep
  %cmp = icmp ne ptr %sel, null
  ret i1 %cmp
}

define i1 @test_phi(i1 %c, ptr nonnull %p, i64 %x) {
; CHECK-LABEL: define i1 @test_phi(
; CHECK-SAME: i1 [[C:%.*]], ptr nonnull [[P:%.*]], i64 [[X:%.*]]) {
; CHECK-NEXT:  [[ENTRY:.*]]:
; CHECK-NEXT:    br i1 [[C]], label %[[IF:.*]], label %[[JOIN:.*]]
; CHECK:       [[IF]]:
; CHECK-NEXT:    [[GEP:%.*]] = getelementptr nuw i8, ptr [[P]], i64 [[X]]
; CHECK-NEXT:    br label %[[JOIN]]
; CHECK:       [[JOIN]]:
; CHECK-NEXT:    [[PHI:%.*]] = phi ptr [ [[P]], %[[ENTRY]] ], [ [[GEP]], %[[IF]] ]
; CHECK-NEXT:    ret i1 true
;
entry:
  br i1 %c, label %if, label %join

if:
  %gep = getelementptr nuw i8, ptr %p, i64 %x
  br label %join

join:
  %phi = phi ptr [ %p, %entry ], [ %gep, %if ]
  %cmp = icmp ne ptr %phi, null
  ret i1 %cmp
}
