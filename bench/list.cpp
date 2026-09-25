#include <cstdio>
#include <memory>
struct L { long h; L* t; };
int main(){ long tot=0; for(int k=0;k<30;k++){ L* acc=nullptr; for(long n=1000000;n>0;n--) acc=new L{n,acc};
  long s=0; for(L* p=acc;p;p=p->t) s+=p->h; tot+=s; while(acc){ L* nx=acc->t; delete acc; acc=nx; } } std::printf("%ld\n",tot); }
