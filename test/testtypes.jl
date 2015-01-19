#Empty types for existing backends.
type TestOpenCL
end
type TestCUDA
end
type TestOpenMP
end
type TestPthreads
end
type TestSerial
end


testopencl = TestOpenCL();
testopenmp = TestOpenMP();
testpthreads = TestPthreads();
testcuda = TestCuda();
testserial = TestSerial();

immutable TestBackend
    flag::Uint8;

    function TestBackend()
        return new(convert(Uint8,0));
    end
    function TestBackend(serial::TestSerial)
        return new(convert(Uint8,0));
    end
    function TestBackend(opencl::TestOpenCL)
        return new(convert(Uint8,1));
    end

    function TestBackend(cuda::TestCUDA)
        return new(convert(Uint8,2));
    end

    function TestBackend(openmp::TestOpenMP)
        return new(convert(Uint8,3));
    end

    function TestBackend(pthreads::TestPthreads)
        return new(convert(Uint8,4));
    end
end


function (==)(rhs::TestBackend,lhs::TestBackend)
    return (rhs.flag==lhs.flag);
end
