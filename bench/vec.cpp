#include <cstdio>
#include <vector>
int main(){ std::vector<long> v; for(long i=0;i<10000000;i++) v.push_back(i); long s=0; for(long x: v) s+=x; std::printf("%ld\n",s); }
