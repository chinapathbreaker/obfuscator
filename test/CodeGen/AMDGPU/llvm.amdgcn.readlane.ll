; RUN: llc -mtriple=amdgcn--amdhsa -mcpu=fiji -mattr=-flat-for-global -verify-machineinstrs < %s | FileCheck %s

declare i32 @llvm.amdgcn.readlane(i32, i32) #0

; CHECK-LABEL: {{^}}test_readlane_sreg:
; CHECK: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, s{{[0-9]+}}
define void @test_readlane_sreg(i32 addrspace(1)* %out, i32 %src0, i32 %src1) #1 {
  %readlane = call i32 @llvm.amdgcn.readlane(i32 %src0, i32 %src1)
  store i32 %readlane, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL: {{^}}test_readlane_imm_sreg:
; CHECK: v_mov_b32_e32 [[VVAL:v[0-9]]], 32
; CHECK: v_readlane_b32 s{{[0-9]+}}, [[VVAL]], s{{[0-9]+}}
define void @test_readlane_imm_sreg(i32 addrspace(1)* %out, i32 %src1) #1 {
  %readlane = call i32 @llvm.amdgcn.readlane(i32 32, i32 %src1)
  store i32 %readlane, i32 addrspace(1)* %out, align 4
  ret void
}

; TODO: m0 should be folded.
; CHECK-LABEL: {{^}}test_readlane_m0_sreg:
; CHECK: s_mov_b32 m0, -1
; CHECK: s_mov_b32 [[COPY_M0:s[0-9]+]], m0
; CHECK: v_mov_b32_e32 [[VVAL:v[0-9]]], [[COPY_M0]]
; CHECK: v_readlane_b32 s{{[0-9]+}}, [[VVAL]], s{{[0-9]+}}
define void @test_readlane_m0_sreg(i32 addrspace(1)* %out, i32 %src1) #1 {
  %m0 = call i32 asm "s_mov_b32 m0, -1", "={M0}"()
  %readlane = call i32 @llvm.amdgcn.readlane(i32 %m0, i32 %src1)
  store i32 %readlane, i32 addrspace(1)* %out, align 4
  ret void
}

; CHECK-LABEL: {{^}}test_readlane_imm:
; CHECK: v_readlane_b32 s{{[0-9]+}}, v{{[0-9]+}}, 32
define void @test_readlane_imm(i32 addrspace(1)* %out, i32 %src0) #1 {
  %readlane = call i32 @llvm.amdgcn.readlane(i32 %src0, i32 32) #0
  store i32 %readlane, i32 addrspace(1)* %out, align 4
  ret void
}

attributes #0 = { nounwind readnone convergent }
attributes #1 = { nounwind }
