module TESTOCCA
using OCCA
using Base.Test




@test test_openmp_okl_ofl_vectoradd("addVectors.ofl") == true;
@test test_openmp_okl_ofl_vectoradd("addVectors.okl") == true;
@test test_opencl_okl_ofl_vectoradd("addVectors.ofl") == true;


end
