#include <stdio.h>
#include <stdlib.h>
typedef struct L { long h; struct L* t; } L;
int main(){ long tot=0; for(int k=0;k<30;k++){ L* acc=NULL; for(long n=1000000;n>0;n--){ L* c=malloc(sizeof(L)); c->h=n; c->t=acc; acc=c; }
  long s=0; for(L* p=acc;p;p=p->t) s+=p->h; tot+=s; while(acc){ L* nx=acc->t; free(acc); acc=nx; } } printf("%ld\n",tot); return 0; }
