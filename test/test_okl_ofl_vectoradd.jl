

function test_openmp_okl_ofl_vectoradd(kernelfile::String,backend::TestBackend)
    OpenMP_Info   = "mode = OpenMP  , schedule = compact, chunk = 10";
    OpenCL_Info   = "mode = OpenCL  , platformID = 0, deviceID = 0";
    CUDA_Info     = "mode = CUDA    , deviceID = 0";
    Pthreads_Info = "mode = Pthreads, threadCount = 4, schedule = compact, pinnedCores = [0, 0, 1, 1]";
    #COI_Info      = "mode = COI     , deviceID = 0";

    linfo::String = "";
    if backend == TestBackend(testopencl)
        if OCCA.USE_OPENCL
            linfo=OpenCL_Info;
        else
            print("OpenCL support not compiled in OCCA.\n");
            return true;
        end
    end
    if backend == TestBackend(testopenmp)
        if OCCA.USE_OPENMP
            linfo=OpenMP_Info;
        else
            print("OpenMP support not compiled in OCCA.\n");
            return true;
        end
    end
    if backend==TestBackend(testcuda)
        if OCCA.USE_CUDA
            linfo = CUDA_Info;
        else
            print("CUDA support not compiled in OCCA.\n");
            return true;
        end
    end
    if backend==TestBackend(testpthreads)
        if OCCA.USE_PTHREADS
            linfo = Pthreads_Info;
        else
            print("Pthreads support not compiled in OCCA.\n");
            return true;
        end
    end

    #OpenMP will default to serial implementation if it is not otherwise built into OCCA.
    if backend==TestBackend(testserial)
        linfo = OpenMP_Info;
    end



    entries = 5

    device = OCCA.Device(linfo);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Array(Float32,(length(a),));

    correctvals = [1.0 for i in 1:entries];

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addvectors = OCCA.buildkernelfromsource(device,
                                            kernelfile,
                                            "addVectors")

    OCCA.runkernel(addvectors,
                   (entries, Int32),
                   o_a, o_b, o_ab)

    OCCA.memcpy(ab, o_ab)


    return (norm(correctvals-ab)/norm(correctvals))<1e-5
end

function test_openmp_okl_ofl_vectoradd(kernelfile::String)
    OpenMP_Info   = "mode = OpenMP  , schedule = compact, chunk = 10";
    OpenCL_Info   = "mode = OpenCL  , platformID = 0, deviceID = 0";
    CUDA_Info     = "mode = CUDA    , deviceID = 0";
    Pthreads_Info = "mode = Pthreads, threadCount = 4, schedule = compact, pinnedCores = [0, 0, 1, 1]";
    COI_Info      = "mode = COI     , deviceID = 0";


    entries = 5

    device = OCCA.Device(OpenMP_Info);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Array(Float32,(length(a),));

    correctvals = [1.0 for i in 1:entries];

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addvectors = OCCA.buildkernelfromsource(device,
                                            kernelfile,
                                            "addVectors")

    OCCA.runkernel(addvectors,
                   (entries, Int32),
                   o_a, o_b, o_ab)

    OCCA.memcpy(ab, o_ab)


    return (norm(correctvals-ab)/norm(correctvals))<1e-5
end


