module TESTOCCA
using OCCA
using Base.Test

function test_okl_ofl_vectoradd(kernelfile::String)
    entries = 5

    OpenMP_Info   = "mode = OpenMP  , schedule = compact, chunk = 10";
    OpenCL_Info   = "mode = OpenCL  , platformID = 0, deviceID = 0";
    CUDA_Info     = "mode = CUDA    , deviceID = 0";
    Pthreads_Info = "mode = Pthreads, threadCount = 4, schedule = compact, pinnedCores = [0, 0, 1, 1]";
    COI_Info      = "mode = COI     , deviceID = 0";

    device = OCCA.Device(OpenMP_Info);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Array(Float32,(length(a),));

    correctvals = [1.0 for i in 1:entries];

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addVectors = OCCA.buildKernelFromSource(device,
                                            kernelfile,
                                            "addVectors")

    OCCA.runKernel(addVectors,
                   (entries, Int32),
                   o_a, o_b, o_ab)

    OCCA.memcpy(ab, o_ab)


    return (norm(correctvals-ab)/norm(correctvals))<1e-5
end


@test test_vectoradd("addVectors.ofl") == true;
@test test_vectoradd("addVectors.okl") == true;


end
