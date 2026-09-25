#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(){ long acc=0; char num[32]; for(long i=0;i<5000000;i++){ int k=snprintf(num,sizeof num,"%ld",i); char* s=malloc(5+k+1); memcpy(s,"item-",5); memcpy(s+5,num,k+1); acc+=strlen(s); free(s);} printf("%ld\n",acc); return 0; }
