/* A native fast path for the package-system test: the point is the
   declarative build, not the arithmetic. The float half is the FFI's
   SSE half (§16): a Float argument arrives in an xmm register, a Float
   result comes back from xmm0, and the two classes share the argument
   sequence. */
#include "fast.h"

long long zyl_native_double(long long n) {
#ifdef ZYL_NATIVE_TEST
    return n * 2;
#else
    return 0;
#endif
}

double zyl_native_fsum(double a, double b) {
#ifdef ZYL_NATIVE_TEST
    return a + b;
#else
    return 0.0;
#endif
}

/* Alternating classes, and past the six integer registers and the eight
   SSE ones, so the stack half of the sequence is exercised too. */
double zyl_native_fmix(long long a, double b, long long c, double d,
                       long long e, double f, long long g, double h,
                       long long i, double j) {
#ifdef ZYL_NATIVE_TEST
    return a + b + c + d + e + f + g + h + i + j;
#else
    return 0.0;
#endif
}

/* A float in, an integer out: the two classes do not have to agree. */
long long zyl_native_ftrunc(double a) {
#ifdef ZYL_NATIVE_TEST
    return (long long)a;
#else
    return 0;
#endif
}