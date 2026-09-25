#include <stdio.h>
#include <stdlib.h>
typedef struct T { struct T *l, *r; } T;
static T* mk(int d){ T* t=malloc(sizeof(T)); if(d==0){t->l=t->r=NULL;} else {t->l=mk(d-1); t->r=mk(d-1);} return t; }
static long check(T* t){ return t->l ? 1+check(t->l)+check(t->r) : 1; }
static void fr(T* t){ if(t->l){fr(t->l);fr(t->r);} free(t); }
int main(){ T* t=mk(21); printf("%ld\n",check(t)); fr(t); long acc=0;
  for(int d=4; d<=20; d+=2){ int n=16*(20+4-d); for(int i=0;i<n;i++){ T* x=mk(d); acc+=check(x); fr(x);} } printf("%ld\n",acc); return 0; }
