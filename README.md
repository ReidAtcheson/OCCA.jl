# OCCA.jl

OCCA is a cross platform shared memory threading library that is 
retargetable to multiple backends such as pthreads, openmp, opencl, and cuda. OCCA.jl is a Julia interface into OCCA.
Julia interface into OCCA. The main OCCA repository can be found
[here](https://github.com/tcew/OCCA2).

#Known issues
The build script does not work for Windows, this is under development.

#Usage

```
Pkg.add("OCCA");
#OCCA will build with no backends by default because 
#reliable backend detection is under development.
#To rebuild with e.g. opencl and cuda you would run
using OCCA;
OCCA.rebuildwith(opencl=true,cuda=true);

#To run tests for all compiled backends, run:
Pkg.test("OCCA");



```




#Contributing
