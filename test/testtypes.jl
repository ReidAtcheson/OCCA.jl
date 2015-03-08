immutable TestBackend
    flag::Int64;
    function TestBackend(n::Int64)
        @assert n>=1 && n<=5;
        return new(n);
    end
end

const testopencl  =TestBackend(1);
const testopenmp  =TestBackend(2);
const testpthreads=TestBackend(3);
const testcuda    =TestBackend(4);
const testserial  =TestBackend(5);


function (==)(rhs::TestBackend,lhs::TestBackend)
    return (rhs.flag==lhs.flag);
end



function get_info_string(backend::TestBackend)

    pinnedCores = [0,0,1,1];

    Serial_Info   ="mode = Serial";
    OpenMP_Info   = "mode = OpenMP  , schedule = compact, chunk = 10";
    OpenCL_Info   = "mode = OpenCL  , platformID = 0, deviceID = 0";
    CUDA_Info     = "mode = CUDA    , deviceID = 0";
    Pthreads_Info = "mode = Pthreads, threadCount = 4, schedule = compact, pinnedCores = [0, 0, 1, 1]";
    #COI_Info      = "mode = COI     , deviceID = 0";

    linfo::String = "";
    if backend == testopencl
        if OCCA.USE_OPENCL
            linfo=OpenCL_Info;
        else
            print("OpenCL support not compiled in OCCA.\n");
            linfo=Serial_Info;
        end
    end
    if backend == testopenmp
        if OCCA.USE_OPENMP
            linfo=OpenMP_Info;
        else
            print("OpenMP support not compiled in OCCA.\n");
            linfo=Serial_Info;
        end
    end
    if backend == testcuda
        if OCCA.USE_CUDA
            linfo = CUDA_Info;
        else
            print("CUDA support not compiled in OCCA.\n");
            linfo = Serial_Info;
        end
    end
    if backend == testpthreads
        if OCCA.USE_PTHREADS
            linfo = Pthreads_Info;
        else
            print("Pthreads support not compiled in OCCA.\n");
            linfo = Serial_Info;
        end
    end

    #OpenMP will default to serial implementation if it is not otherwise built into OCCA.
    if backend == testserial
        linfo = Serial_Info;
    end




    return linfo;
end
