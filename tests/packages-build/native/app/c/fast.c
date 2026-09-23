/* A native fast path for the package-system test: the point is the
   declarative build, not the arithmetic. */
#include "fast.h"

long long zyl_native_double(long long n) {
#ifdef ZYL_NATIVE_TEST
    return n * 2;
#else
    return 0;
#endif
}
