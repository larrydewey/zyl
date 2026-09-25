#include <cstdio>
#include <vector>
int main(){ long n=50000000; std::vector<unsigned char> b(n); long c=0; for(long i=2;i<n;i++) if(!b[i]){ c++; for(long j=i*i;j<n;j+=i) b[j]=1; } std::printf("%ld\n",c); }
