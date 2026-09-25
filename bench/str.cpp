#include <cstdio>
#include <string>
int main(){ long acc=0; for(long i=0;i<5000000;i++) acc+=( std::string("item-")+std::to_string(i) ).size(); std::printf("%ld\n",acc); }
