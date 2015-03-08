module TESTOCCA
using OCCA
using Base.Test

include("testtypes.jl");



#Test vector add kernel.
include("test_okl_ofl_vectoradd.jl");
@test test_okl_ofl_vectoradd(testserial) == true;
@test test_okl_ofl_vectoradd(testopenmp) == true;
@test test_okl_ofl_vectoradd(testopencl) == true;
@test test_okl_ofl_vectoradd(testpthreads) == true;
@test test_okl_ofl_vectoradd(testcuda) == true;

@test test_okl_ofl_vectoradd(testserial) == true;
@test test_okl_ofl_vectoradd(testopencl) == true;
@test test_okl_ofl_vectoradd(testpthreads) == true;
@test test_okl_ofl_vectoradd(testcuda) == true;


#Test reduction kernel.
include("test_okl_reduction.jl");
@test test_okl_reduction(testserial) == true;
@test test_okl_reduction(testopenmp) == true;
@test test_okl_reduction(testopencl) == true;
@test test_okl_reduction(testpthreads) == true;
@test test_okl_reduction(testcuda) == true;



end
