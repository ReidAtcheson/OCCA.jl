global OCCA_USE_OPENMP = false;
global OCCA_USE_PTHREADS = false;
global OCCA_USE_CUDA = false;
global OCCA_USE_OPENCL = false;


function openmp_exists()
    return OCCA_USE_OPENMP;
end

function pthreads_exists()
    return OCCA_USE_PTHREADS;
end

function cuda_exists()
    return OCCA_USE_CUDA;
end

function opencl_exists()
    return OCCA_USE_OPENCL;
end
