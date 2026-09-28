#!/usr/bin/env python3
# GNU-as oracle for compiler/asm_x86: `gen OUT.s` writes the every-register x every-form sweep; `cmp SRC.s DIR` diffs DIR/my.{text,rel,lst} against as.
import sys, struct, subprocess, re, bisect
import struct
# Minimal ELF64 relocatable reader: returns {secname: (bytes, [(off,type,sym,addend)])}
def read_o(path):
    d = open(path,'rb').read()
    assert d[:4]==b'\x7fELF'
    e_shoff, = struct.unpack_from('<Q', d, 0x28)
    e_shentsize, e_shnum, e_shstrndx = struct.unpack_from('<HHH', d, 0x3a)
    secs=[]
    for i in range(e_shnum):
        off=e_shoff+i*e_shentsize
        name,typ,flags,addr,offset,size,link,info,align,entsize = struct.unpack_from('<IIQQQQIIQQ', d, off)
        secs.append(dict(name=name,typ=typ,flags=flags,offset=offset,size=size,link=link,info=info,entsize=entsize))
    shstr=secs[e_shstrndx]
    def nm(o,s):
        base=s['offset']; e=d.index(b'\0',base+o); return d[base+o:e].decode()
    for s in secs: s['n']=nm(s['name'],shstr)
    byname={s['n']:s for s in secs}
    # symbol table
    symtab=byname['.symtab']; strtab=secs[symtab['link']]
    syms=[]
    for o in range(symtab['offset'], symtab['offset']+symtab['size'], 24):
        st_name,st_info,st_other,st_shndx,st_value,st_size=struct.unpack_from('<IBBHQQ',d,o)
        syms.append(dict(name=nm(st_name,strtab), shndx=st_shndx, value=st_value, info=st_info))
    out={}
    for s in secs:
        if s['typ']==1: # PROGBITS
            b=d[s['offset']:s['offset']+s['size']]
            out[s['n']]=(bytearray(b),[])
        if s['typ']==8: # NOBITS (.bss/.tbss)
            out[s['n']]=(None, s['size'])
    for s in secs:
        if s['typ']==4: # RELA
            target=secs[s['info']]['n']
            rl=[]
            for o in range(s['offset'], s['offset']+s['size'], 24):
                r_offset,r_info,r_addend=struct.unpack_from('<QQq',d,o)
                typ=r_info&0xffffffff; sym=r_info>>32
                rl.append((r_offset,typ,syms[sym]['name'],r_addend))
            if target in out: out[target]=(out[target][0], rl)
    return out

def gen(path):
    R64="rax rcx rdx rbx rsp rbp rsi rdi r8 r9 r10 r11 r12 r13 r14 r15".split()
    R32="eax ecx edx ebx esp ebp esi edi r8d r9d r10d r11d r12d r13d r14d r15d".split()
    R16="ax cx dx bx sp bp si di r8w r9w r10w r11w r12w r13w r14w r15w".split()
    R8="al cl dl bl spl bpl sil dil r8b r9b r10b r11b r12b r13b r14b r15b".split()
    X=["xmm%d"%i for i in range(16)]; Y=["ymm%d"%i for i in range(16)]
    MEM=["[rax]","[rsp]","[rbp]","[r12]","[r13]","[r15]","[rax+8]","[rbp-48]","[rsp+200]","[r13+1000]",
         "[rax+rbx*4]","[rcx+r9*8+16]","[r12+rbp*2-8]","[rdx+rax]","[r8+r15*1-300]","[rip+ext]"]
    IMMS=["0","1","127","128","-128","-129","65535","-2147483648","2147483647"]
    CC="o no b c nae ae nb nc e z ne nz be na a nbe s ns p pe np po l nge ge nl le ng g nle".split()
    L=[]
    def a(x): L.append("    "+x)
    for op in "add or and sub xor cmp sbb".split():
        for d in R64:
            for s in R64: a(f"{op} {d}, {s}")
        for d,s in zip(R32,R32[::-1]): a(f"{op} {d}, {s}")
        for d in R8:
            for s in R8: a(f"{op} {d}, {s}")
        for d in R64+R32:
            for i in IMMS: a(f"{op} {d}, {i}")
        for d in R8:
            for i in ["0","1","127","-128","255"]: a(f"{op} {d}, {i}")
        for m in MEM:
            a(f"{op} rcx, {m}"); a(f"{op} r11, qword ptr {m}"); a(f"{op} {m}, r9"); a(f"{op} qword ptr {m}, 5"); a(f"{op} qword ptr {m}, 1000")
            a(f"{op} byte ptr {m}, sil"); a(f"{op} byte ptr {m}, 7"); a(f"{op} dword ptr {m}, r10d")
    for d in R64:
        for s in R64: a(f"mov {d}, {s}")
        for i in IMMS+["4294967295","7378697629483820647","-1"]: a(f"mov {d}, {i}")
        a(f"movabs {d}, 7378697629483820647"); a(f"movabs {d}, 5")
        for m in MEM: a(f"mov {d}, {m}"); a(f"mov {m}, {d}"); a(f"lea {d}, {m}")
    for d,s in zip(R32,R32[::-1]): a(f"mov {d}, {s}"); a(f"mov {d}, 13")
    for r in R8:
        for m in MEM: a(f"mov byte ptr {m}, {r}")
        a(f"mov {r}, 5")
    for r in R16: a(f"mov word ptr [rdx], {r}"); a(f"mov word ptr [r13+4], {r}")
    for r in R32: a(f"mov dword ptr [rdx], {r}"); a(f"mov {r}, dword ptr [r12+4]")
    for m in MEM: a(f"mov qword ptr {m}, 3"); a(f"mov qword ptr {m}, -1"); a(f"mov byte ptr {m}, 9"); a(f"mov dword ptr {m}, 70000")
    for d in R64:
        for s in R64[::5]: a(f"test {d}, {s}")
        for i in ["7","255","-1","65536"]: a(f"test {d}, {i}")
    for r in R8: a(f"test {r}, {r}"); a(f"test {r}, 1")
    for m in MEM: a(f"test byte ptr {m}, 1"); a(f"test qword ptr {m}, rax"); a(f"test {m}, r12")
    for d in R64+R32:
        for s in R8: a(f"movzx {d}, {s}")
        for m in MEM: a(f"movzx {d}, byte ptr {m}"); a(f"movzx {d}, word ptr {m}")
    for d in R64:
        for s in R8: a(f"movsx {d}, {s}")
        for m in MEM: a(f"movsx {d}, byte ptr {m}")
    for d in R64:
        a(f"imul {d}")
        for s in R64[::3]: a(f"imul {d}, {s}"); a(f"imul {d}, {s}, 10"); a(f"imul {d}, {s}, 300")
        for i in ["10","-3","1000"]: a(f"imul {d}, {i}")
        for m in MEM: a(f"imul {d}, qword ptr {m}")
        for op in "div idiv mul neg not".split(): a(f"{op} {d}")
        for op in "shl shr sar rol ror sal".split(): a(f"{op} {d}, 1"); a(f"{op} {d}, 5"); a(f"{op} {d}, cl")
        a(f"push {d}"); a(f"pop {d}"); a(f"bswap {d}"); a(f"call {d}"); a(f"jmp {d}")
        for s in R64[::3]: a(f"bsf {d}, {s}"); a(f"bsr {d}, {s}")
        for m in MEM: a(f"bsf {d}, {m}"); a(f"xchg qword ptr {m}, {d}"); a(f"lock cmpxchg qword ptr {m}, {d}"); a(f"lock xadd qword ptr {m}, {d}")
    for d in R32:
        for op in "shl shr sar".split(): a(f"{op} {d}, 3"); a(f"{op} {d}, cl")
        a(f"bswap {d}")
        for s in R8: a(f"crc32 {d}, {s}")
        a(f"xor {d}, {d}")
    for d in R64:
        for s in R64[::3]: a(f"crc32 {d}, {s}")
    for m in MEM: a(f"jmp qword ptr {m}"); a(f"call qword ptr {m}")
    for c in CC:
        a(f"j{c} ext")
        for r in R8: a(f"set{c} {r}")
        for d in R64[::3]:
            for s in R64[::5]: a(f"cmov{c} {d}, {s}")
            a(f"cmov{c} {d}, qword ptr [rbp-8]")
    a("jmp ext"); a("call ext")
    for op,pairs in [("addsd",1),("subsd",1),("mulsd",1),("divsd",1),("ucomisd",1),("pxor",1),("pcmpeqb",1),("movdqa",1),("punpcklbw",1),("punpcklwd",1),("aesenc",1),("aesenclast",1)]:
        for d in X:
            for s in X[::5]: a(f"{op} {d}, {s}")
        for m in MEM: a(f"{op} xmm3, {m}"); a(f"{op} xmm12, {m}")
    for d in X:
        for s in R64[::3]: a(f"movq {d}, {s}"); a(f"movq {s}, {d}"); a(f"cvtsi2sd {d}, {s}"); a(f"cvttsd2si {s}, {d}")
        for s in R32[::3]: a(f"movd {d}, {s}"); a(f"pmovmskb {s}, {d}")
        a(f"pshufd {d}, xmm1, 0"); a(f"pshufd xmm2, {d}, 27"); a(f"pslldq {d}, 4"); a(f"aeskeygenassist {d}, xmm9, 1")
        for m in MEM: a(f"movsd {d}, {m}"); a(f"movdqu {d}, {m}"); a(f"movdqu {m}, {d}")
    for d in Y:
        for m in MEM: a(f"vmovdqu {d}, {m}"); a(f"vmovdqu {m}, {d}")
        for s in Y[::5]:
            a(f"vpcmpeqb {d}, {s}, ymm1"); a(f"vpcmpeqb {d}, ymm2, {s}")
        for s in R32[::3]: a(f"vpmovmskb {s}, {d}")
    for d in X:
        for s in X[::5]: a(f"vpxor {d}, {s}, xmm1"); a(f"vpxor {d}, xmm2, {s}")
    for x in "ret nop ud2 syscall cpuid xgetbv mfence vzeroupper cqo".split(): a(x)
    a("rep stosb"); a("rep stosq")
    for m in ["QWORD PTR fs:0","QWORD PTR fs:zyl_cur_region@tpoff"]:
        a(f"mov rax, {m}"); a(f"mov r13, {m}"); a(f"mov {m}, r9"); a(f"mov {m}, 0"); a(f"cmp {m}, r11")
    a("lea rax, [rax+zyl_cur_region@tpoff]"); a("lea r12, [r12+zyl_cur_region@tpoff]")
    a("mov rax, QWORD PTR [rip+main@GOTPCREL]"); a("mov r10, QWORD PTR [rip+main@GOTPCREL]")
    OUT=(".intel_syntax noprefix\n.text\n.globl t\nt:\n"+"\n".join(L))+"\n"
    OUT+=(".section .tbss,\"awT\",@nobits\n.p2align 3\nzyl_cur_region:\n    .zero 8")
    
    open(path,"w").write(OUT+"\n")

def cmp():
    src=sys.argv[2]; A=sys.argv[3]+'/'
    subprocess.check_call(['as',src,'-o',A+'sw.o'])
    secs=read_o(A+'sw.o'); ast=bytearray(secs['.text'][0]); arel=secs['.text'][1]
    dump=subprocess.check_output(['objdump','-d','-M','intel',A+'sw.o']).decode()
    aoff=[]
    for l in dump.split('\n'):
        m=re.match(r'\s+([0-9a-f]+):\t([0-9a-f ]+)\t',l)
        if m: aoff.append(int(m.group(1),16))
    aoff.append(len(ast))
    my=bytearray(open(A+'my.text','rb').read())
    mrel=[int(x.split()[0]) for x in open(A+'my.rel') if x.strip()]
    lst=[l.split(' ',1) for l in open(A+'my.lst').read().split('\n') if l]
    moff=[int(x[0]) for x in lst]+[len(my)]
    def mask(b,offs):
        for o in offs:
            for k in range(4):
                if o+k<len(b): b[o+k]=0
    mask(ast,[r[0] for r in arel]); mask(my,mrel)
    print('lines mine',len(lst),'as',len(aoff)-1)
    bad=0; seen=set()
    for k in range(min(len(lst),len(aoff)-1)):
        a=ast[aoff[k]:aoff[k+1]]; b=my[moff[k]:moff[k+1]]
        if a!=b:
            bad+=1
            key=re.sub(r'\b(r\d+[dwb]?|[re]?[a-d]x|[re]?[sd]il?|[re]?[sb]pl?|[a-d]l|xmm\d+|ymm\d+)\b','R',lst[k][1])
            if bad<=40 or key not in seen:
                if len(seen)<80: print('%-40s as=%-24s me=%s'%(lst[k][1],a.hex(),b.hex()))
            seen.add(key)
    print('bad',bad,'distinct',len(seen))
    ok=bad==0
    def rel_lines(offs, rels):
        out=set()
        for r in rels:
            k=bisect.bisect_right(offs,r)-1; out.add((k,r-offs[k]))
        return out
    ra=rel_lines(aoff[:-1],[r[0] for r in arel]); rm=rel_lines(moff[:-1],mrel)
    print('reloc positions equal:', ra==rm, len(ra), len(rm))
    for k,o in sorted(ra^rm)[:10]: print('  reloc diff line',lst[k][1],o, (k,o) in ra)
    mk={int(x.split()[0]):int(x.split()[1]) for x in open(A+'my.rel') if x.strip()}
    amap={2:1,4:1,23:2,9:3,41:3,42:3}
    print('reloc kinds equal:', all(amap.get(t)==mk.get(o) for o,t,_,_ in arel))
    
    ok = ok and ra==rm and all(amap.get(t)==mk.get(o) for o,t,_,_ in arel)
    sys.exit(0 if ok else 1)
    

if sys.argv[1]=="gen": gen(sys.argv[2])
else: cmp()
