#include <stdio.h>
#include <stdlib.h>
int main(){ long cap=16,len=0; long* v=malloc(cap*sizeof(long)); for(long i=0;i<10000000;i++){ if(len==cap){cap*=2; v=realloc(v,cap*sizeof(long));} v[len++]=i;} long s=0; for(long i=0;i<len;i++) s+=v[i]; printf("%ld\n",s); return 0; }
