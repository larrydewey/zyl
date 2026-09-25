#include <cstdio>
#include <memory>
struct T { std::unique_ptr<T> l, r; };
static std::unique_ptr<T> mk(int d){ auto t=std::make_unique<T>(); if(d>0){ t->l=mk(d-1); t->r=mk(d-1);} return t; }
static long check(const T& t){ return t.l ? 1+check(*t.l)+check(*t.r) : 1; }
int main(){ std::printf("%ld\n",check(*mk(21))); long acc=0;
  for(int d=4; d<=20; d+=2){ int n=16*(20+4-d); for(int i=0;i<n;i++) acc+=check(*mk(d)); } std::printf("%ld\n",acc); }
