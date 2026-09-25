#include <cstdio>
int main(){ long acc=0; for(long i=0;i<200000000;i++) acc=(acc+i*i)%1000000007; std::printf("%ld\n",acc); }
