# CIALUG December 2023 - Mojo and C/Linux intro

```bash
mojo build hello.mojo
./hello
```
* JIT compilation with [LLVM ORC](https://releases.llvm.org/9.0.1/docs/ORCv2.html)
* Multi-Level Intermediate Representation [MLIR](https://mlir.llvm.org) - single static assignment for all the things.
* Mojo simd - [n-body demo](https://github.com/modularml/mojo/blob/cbba184e159f297f0f24f9299616015cf8bdd0f3/examples/nbody.mojo#L29)
* Mojo autotune - [memset demo](https://github.com/modularml/mojo/blob/cbba184e159f297f0f24f9299616015cf8bdd0f3/examples/memset.mojo#L200)
  


## Performance beyond mojo
* const/enum linting
* GPU pin of hot cache - [PowerInfer: Fast Large Language Model Serving with a Consumer-grade GPU](https://ipads.se.sjtu.edu.cn/_media/publications/powerinfer-20231219.pdf) - [PowerInfer Github](https://github.com/SJTU-IPADS/PowerInfer)
* tensor compression
* More MILR for IO/cache levels
* [Equality saturation](https://digital.lib.washington.edu/researchworks/bitstream/handle/1773/47423/Willsey_washington_0250E_22746.pdf?sequence=1) 



[2023 LLVM Dev Mtg - Mojo 🔥: A system programming language for heterogenous computing](https://www.youtube.com/watch?v=SEwTjZvy8vw)




