# Run every benchmark in bench/out/ (bench/build.sh) three times; print
# best wall time and peak RSS per language, and flag a benchmark whose
# output differs between languages with (!).
import os, time, sys
d = os.path.join(os.path.dirname(os.path.abspath(__file__)), "out")
names = ["fib","loop","list","trees","str","sieve","vec"]
langs = [("Zyl","z"),("C","c.bin"),("C++","cpp.bin"),("Rust","rs.bin"),("Go","g")]
def run(exe):
    best=None; rss=0; out=None
    for _ in range(3):
        t=time.time(); pid=os.fork()
        if pid==0:
            fd=os.open(os.path.join(d,"m.out"),os.O_WRONLY|os.O_CREAT|os.O_TRUNC); os.dup2(fd,1); os.dup2(fd,2); os.execv(exe,[exe])
        _,st,ru=os.wait4(pid,0); el=time.time()-t
        best=el if best is None or el<best else best; rss=max(rss,ru.ru_maxrss/1024)
        out=open(os.path.join(d,"m.out"),'rb').read()
    return best, rss, out
res={}
for n in names:
    for L,ext in langs:
        res[(n,L)]=run(os.path.join(d,f"{n}.{ext}"))
    outs={res[(n,L)][2] for L,_ in langs}
    res[(n,'same')]=len(outs)==1
def table(idx, title, fmt):
    print(f"\n{title}")
    print("| benchmark | " + " | ".join(L for L,_ in langs) + " | Zyl vs C | Zyl vs Go |")
    print("|---|" + "---|"*(len(langs)+2))
    for n in names:
        row=[fmt(res[(n,L)][idx]) for L,_ in langs]
        z=res[(n,"Zyl")][idx]; c=res[(n,"C")][idx]; g=res[(n,"Go")][idx]
        print(f"| {n}{'' if res[(n,'same')] else ' (!)'} | " + " | ".join(row) + f" | {z/c:.1f}x | {z/g:.1f}x |")
table(0,"Wall time, best of 3 (s)",lambda v:f"{v:.2f}")
table(1,"Peak memory (MB)",lambda v:f"{v:.0f}")
