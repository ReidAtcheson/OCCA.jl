function test_okl_reduction(backend::TestBackend)
    OpenMP_Info   = "mode = OpenMP  , schedule = compact, chunk = 10";
    OpenCL_Info   = "mode = OpenCL  , platformID = 0, deviceID = 0";
    CUDA_Info     = "mode = CUDA    , deviceID = 0";
    Pthreads_Info = "mode = Pthreads, threadCount = 4, schedule = compact, pinnedCores = [0, 0, 1, 1]";
 

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

    entries=1024;
    nred   =256;

    reducedentries = entries/nred;
    a=Array(Float32,(entries,)); a[:]=1.0;
    ared=Array(Float32,(nred,)); ared[:]=0.0;

    kernelinfo = OCCA.KernelInfo();
    OCCA.adddefine!(kernelinfo,"p_Nred",nred);



    device  = OCCA.Device(linfo);
    o_a     = OCCA.malloc(device, a);
    o_ared  = OCCA.malloc(device, ared);

    reduction = OCCA.buildkernelfromsource(device,"reduction.okl","reduction",kernelinfo);



    OCCA.runkernel!(reduction,entries,o_a,o_ared);

    OCCA.memcpy!(ared,o_ared);


    val=sum(ared);

    

    relerr= abs(sum(a)-val)/sum(a);

    return relerr<1e-5;


end
