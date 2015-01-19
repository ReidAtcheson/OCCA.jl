module TESTOCCA
using OCCA
using Base.Test

include("testtypes.jl");



include("test_okl_ofl_vectoradd.jl");
@test test_openmp_okl_ofl_vectoradd("addVectors.ofl",TestBackend(testserial)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.ofl",TestBackend(testopencl)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.ofl",TestBackend(testpthreads)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.ofl",TestBackend(testcuda)) == true;

@test test_openmp_okl_ofl_vectoradd("addVectors.okl",TestBackend(testserial)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.okl",TestBackend(testopencl)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.okl",TestBackend(testpthreads)) == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.okl",TestBackend(testcuda)) == true;



end
