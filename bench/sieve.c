#include <stdio.h>
#include <stdlib.h>
int main(){ long n=50000000; unsigned char* b=calloc(n,1); long c=0; for(long i=2;i<n;i++) if(!b[i]){ c++; for(long j=i*i;j<n;j+=i) b[j]=1; } printf("%ld\n",c); return 0; }
