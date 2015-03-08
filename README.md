# OCCA.jl

OCCA is a cross platform single-instruction-multiple-data ([SIMD](http://en.wikipedia.org/wiki/SIMD)) 
threading library that is 
retargetable to multiple backends such as pthreads, openmp, opencl, and cuda. OCCA.jl is a Julia interface into OCCA.
The main OCCA repository can be found
[here](https://github.com/tcew/OCCA2).

#Installation and testing.

```julia
Pkg.add("OCCA");
#This takes a minute because no precompiled OCCA binaries exist.
#OCCA will build with no parallel backends by default because 
#reliable backend detection is under development.
#To rebuild with e.g. opencl and cuda you would run
using OCCA;
OCCA.rebuildwith!(opencl=true,cuda=true);

#To run tests for all compiled backends, run:
Pkg.test("OCCA");

#If a backend is not compiled, that test will simply pass without doing anything.
#OCCA will default to serial mode if no backend is installed, so the tests
#still provide some information about correctness of the test kernels (ignoring
#parallel issues such as race conditions and deadlocks)


```


#An example script.

## addVectors.okl
```c
kernel void addVectors(const int entries,
                       const float *a,
                       const float *b,
                       float *ab){
  for(int group = 0; group < ((entries + 15) / 16); ++group; outer0){
    for(int item = 0; item < 16; ++item; inner0){
      const int N = (item + (16 * group));

      if(N < entries)
        ab[N] = a[N] + b[N];
    }
  }
}
```

##advectors.jl

```julia

    
    infostring   = "mode = OpenMP  , schedule = compact, chunk = 10";

    entries = 5

    device = OCCA.Device(infostring);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Array(Float32,(length(a),));

    correctvals = [1.0 for i in 1:entries];

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addvectors = OCCA.buildkernel(device,"addVectors.okl","addVectors")

    OCCA.runkernel!(addvectors,entries,o_a,o_b,o_ab)

    OCCA.memcpy!(ab, o_ab)




```



#Known issues
=======
-The build script does not work for Windows, this is under development.
-If OCCA kernel file uses shared memory and you target OpenCL+CPU, it will crash. This appears to be an OpenCL problem and not an OCCA problem.







#Contributing

##Contributing code
Fork this repository on Github, make desired changes, and submit pull request.

##Helping with tests and builds
It would be enormously helpful if issues could be opened
with any build or test failures, along with the specs of the machines
on which the builds or tests failed.



#Editor Issues
.OKL files have a nearly-C grammar, and so most syntax highlighting modules designed for vanilla C will also
do a decent job highlighting .OKL files.

