module TESTOCCA
using OCCA
using Base.Test

include("testtypes.jl");



#Test vector add kernel.
include("test_okl_ofl_vectoradd.jl");
@test test_okl_ofl_vectoradd(TestBackend(testserial)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testopenmp)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testopencl)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testpthreads)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testcuda)) == true;

@test test_okl_ofl_vectoradd(TestBackend(testserial)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testopencl)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testpthreads)) == true;
@test test_okl_ofl_vectoradd(TestBackend(testcuda)) == true;


#Test reduction kernel.
include("test_okl_reduction.jl");
@test test_okl_reduction(TestBackend(testserial)) == true;
@test test_okl_reduction(TestBackend(testopenmp)) == true;
@test test_okl_reduction(TestBackend(testopencl)) == true;
@test test_okl_reduction(TestBackend(testpthreads)) == true;
@test test_okl_reduction(TestBackend(testcuda)) == true;



end
