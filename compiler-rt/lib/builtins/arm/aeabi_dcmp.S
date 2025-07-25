//===-- aeabi_dcmp.S - EABI dcmp* implementation ---------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "../assembly.h"

// int __aeabi_dcmp{eq,lt,le,ge,gt}(double a, double b) {
//   int result = __{eq,lt,le,ge,gt}df2(a, b);
//   if (result {==,<,<=,>=,>} 0) {
//     return 1;
//   } else {
//     return 0;
//   }
// }

#if defined(COMPILER_RT_ARMHF_TARGET)
#  define CONVERT_DCMP_ARGS_TO_DF2_ARGS \
     VMOV_TO_DOUBLE(d0, r0, r1)         \
     VMOV_TO_DOUBLE(d1, r2, r3)
#else
#  define CONVERT_DCMP_ARGS_TO_DF2_ARGS
#endif

#if defined(__ARM_FEATURE_PAC_DEFAULT)
#  define PROLOGUE PACBTI_LANDING        SEPARATOR \
                   push      { r12, lr }
#  define EPILOGUE pop       { r12, lr } SEPARATOR \
                   PAC_RETURN
#elif defined(__ARM_FEATURE_BTI_DEFAULT)
#  define PROLOGUE PACBTI_LANDING        SEPARATOR \
                   push      { r4, lr }
#  define EPILOGUE pop       { r4, pc }
#else
#  define PROLOGUE push      { r4, lr }
#  define EPILOGUE pop       { r4, pc }
#endif

#define DEFINE_AEABI_DCMP(cond)                            \
        .syntax unified                          SEPARATOR \
        .p2align 2                               SEPARATOR \
DEFINE_COMPILERRT_FUNCTION(__aeabi_dcmp ## cond)           \
        PROLOGUE                                 SEPARATOR \
        CONVERT_DCMP_ARGS_TO_DF2_ARGS            SEPARATOR \
        bl        SYMBOL_NAME(__ ## cond ## df2) SEPARATOR \
        cmp       r0, #0                         SEPARATOR \
        b ## cond 1f                             SEPARATOR \
        movs      r0, #0                         SEPARATOR \
        EPILOGUE                                 SEPARATOR \
1:                                               SEPARATOR \
        movs      r0, #1                         SEPARATOR \
        EPILOGUE                                 SEPARATOR \
END_COMPILERRT_FUNCTION(__aeabi_dcmp ## cond)

DEFINE_AEABI_DCMP(eq)
DEFINE_AEABI_DCMP(lt)
DEFINE_AEABI_DCMP(le)
DEFINE_AEABI_DCMP(ge)
DEFINE_AEABI_DCMP(gt)

NO_EXEC_STACK_DIRECTIVE

