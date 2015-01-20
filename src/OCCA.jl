module OCCA
include("occapaths.jl");
include("occabuiltwith.jl");

#Flags for which threading libraries to build into OCCA.
USE_OPENMP = OCCA_USE_OPENMP;
USE_PTHREADS = OCCA_USE_PTHREADS;
USE_CUDA = OCCA_USE_CUDA;
USE_OPENCL = OCCA_USE_OPENCL;



thisfile= @__FILE__();
thisdir = dirname(thisfile);
tmpdir  = pwd();

cd(thisdir);
cd("../deps");

#Point to OCCA shared library.
ENV["OCCA_DIR"]=pwd() * "/OCCA2"


cd(tmpdir);



#---[ Types ]-----------------
type Device
    cDevice::Ptr{Void}
end

function Device(infos::String)
    cDevice = ccall((:occaGetDevice, libocca),
                    Ptr{Void},
                    (Ptr{Uint8},),
                    bytestring(infos));
   return Device(cDevice);
end


type Stream
    cStream::Ptr{Void}
end

type Kernel
    cKernel::Ptr{Void}
end


type KernelInfo
    cKernelInfo::Ptr{Void}
end


type Memory
    cMemory::Ptr{Void}
    cTypes
end


#---[ Device ]----------------
function finalizer(d::Device)
    ccall((:occaDeviceFree, libocca),
          Void,
          (Ptr{Void},),
          d.cDevice)
end

function mode(d::Device)
    cMode = ccall((:occaDeviceMode, libocca),
                  Ptr{Uint8},
                  (Ptr{Void},), d.cDevice)

    return bytestring(cMode)
end

function setcompiler(d::Device,
                     compiler::String)
    ccall((:occaDeviceSetCompiler, libocca),
          Void,
          (Ptr{Void}, Ptr{Uint8},),
          d.cDevice, bytestring(compiler))
end

function setcompilerflags(d::Device,
                          compilerFlags::String)
    ccall((:occaDeviceSetCompilerFlags, libocca),
          Void,
          (Ptr{Void}, Ptr{Uint8},),
          d.cDevice, bytestring(compilerFlags))
end

function buildkernelfromsource(d::Device,
                               filename::String,
                               functionName::String;
                               info = C_NULL)
    if info == C_NULL
        cKernel = ccall((:occaBuildKernelFromSource, libocca),
                        Ptr{Void},
                        (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Void},),
                        d.cDevice,
                        bytestring(filename),
                        bytestring(functionName),
                        C_NULL)
    else
        cKernel = ccall((:occaBuildKernelFromSource, libocca),
                        Ptr{Void},
                        (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8}, Ptr{Void},),
                        d.cDevice,
                        bytestring(filename),
                        bytestring(functionName),
                        info.cKernelInfo)
    end

    return Kernel(cKernel)
end

function buildkernelfrombinary(d::Device,
                               filename::String,
                               functionName::String)
    cKernel = ccall((:occaBuildKernelFromBinary, libocca),
                    Ptr{Void},
                    (Ptr{Void}, Ptr{Uint8}, Ptr{Uint8},),
                    d.cDevice,
                    bytestring(filename),
                    bytestring(functionName))

    return Kernel(cKernel)
end

function malloc(d::Device, source::Array)
    cTypes = typeof(source[1])
    bytes  = length(source) * sizeof(cTypes)

    convert(Uint, bytes)

    cMemory = ccall((:occaDeviceMalloc, libocca),
                    Ptr{Void},
                    (Ptr{Void}, Uint, Ptr{Void},),
                    d.cDevice, bytes, pointer(source))

    return Memory(cMemory, cTypes)
end

function malloc(d::Device, entriesAndType)
    if length(entriesAndType) != 2
        error("malloc second argument must be a tuple of (bytes, type) or Array")
    end

    cTypes = entriesAndType[2]

    bytes  = entriesAndType[1] * sizeof(cTypes)

    convert(Uint, bytes)

    cMemory = ccall((:occaDeviceMalloc, libocca),
                    Ptr{Void},
                    (Ptr{Void}, Uint, Ptr{Void},),
                    d.cDevice, bytes, C_NULL)

    return Memory(cMemory, cTypes)
end

function createstream(d::Device)
    cStream = ccall((:occaGenStream, libocca),
                    Ptr{Void},
                    (Ptr{Void},),
                    d.cDevice)

    return Stream(cStream)
end

function getstream(d::Device)
    cStream = ccall((:occaGetStream, libocca),
                    Ptr{Void},
                    (Ptr{Void},),
                    d.cDevice)

    return Stream(cStream)
end

function setstream(d::Device, s::Stream)
    ccall((:occaSetStream, libocca),
          Void,
          (Ptr{Void}, Ptr{Void},),
          d.cDevice, s.cStream)
end

#---[ Kernel ]----------------
function finalizer(k::Kernel)
    ccall((:occaKernelFree, libocca),
          Void,
          (Ptr{Void},),
          k.cKernel)
end

function mode(k::Kernel)
    cMode = ccall((:occaKernelMode, libocca),
                  Ptr{Uint8},
                  (Ptr{Void},),
                  k.cKernel)

    return bytestring(cMode)
end

function getpreferreddimsize(k::Kernel)
    return ccall((:occaKernelPreferredDimSize, libocca),
                 Int32,
                 (Ptr{Void},),
                 k.cKernel)
end

function setworkingdims(k::Kernel,
                        dims, items, groups)
    convert(Int32, dims)

    items_  = ones(Uint, 3)
    groups_ = ones(Uint, 3)

    for i = 1:dims
        items_[i]  = items[i]
        groups_[i] = groups[i]
    end

    ccall((:occaKernelSetAllWorkingDims, libocca),
          Void,
          (Ptr{Void},
           Int32,
           Uint, Uint, Uint,
           Uint, Uint, Uint,),
          k.cKernel,
          dims,
          items_[1] , items_[2] , items_[3],
          groups_[1], groups_[2], groups_[3])
end

argType(arg::Int8)  = ccall((:occaChar, libocca), Ptr{Void}, (Int8,) , arg)
argType(arg::Uint8) = ccall((:occaUChar, libocca), Ptr{Void}, (Uint8,), arg)

argType(arg::Int16)  = ccall((:occaShort, libocca), Ptr{Void}, (Int16,) , arg)
argType(arg::Uint16) = ccall((:occaUShort, libocca), Ptr{Void}, (Uint16,), arg)

argType(arg::Int32)  = ccall((:occaInt, libocca), Ptr{Void}, (Int32,) , arg)
argType(arg::Uint32) = ccall((:occaUInt, libocca), Ptr{Void}, (Uint32,), arg)

argType(arg::Int64)  = ccall((:occaLong, libocca), Ptr{Void}, (Int64,) , arg)
argType(arg::Uint64) = ccall((:occaULong, libocca), Ptr{Void}, (Uint64,), arg)

argType(arg::Float32) = ccall((:occaFloat, libocca), Ptr{Void}, (Float32,) , arg)
argType(arg::Float64) = ccall((:occaDouble, libocca), Ptr{Void}, (Float64,) , arg)

function runkernel(k::Kernel, args...)
    argList = ccall((:occaGenArgumentList, libocca),
                    Ptr{Void}, ())

    pos = convert(Int32, 0)
    for arg in args
        if isa(arg, Memory)
            ccall((:occaArgumentListAddArg, libocca),
                  Void,
                  (Ptr{Void}, Int32, Ptr{Void},),
                  argList, pos, arg.cMemory)
        else
            if length(arg) != 2
                error("Kernel argument should be in the form of (value, type)")
            end

            arg_ = arg[1]
            convert(arg[2], arg_)

            cArg = argType(arg_)

            ccall((:occaArgumentListAddArg, libocca),
                  Void,
                  (Ptr{Void}, Int32, Ptr{Void},),
                  argList, pos, cArg)
        end

        pos += 1
    end

    ccall((:occaKernelRun_, libocca),
          Void,
          (Ptr{Void}, Ptr{Void},),
          k.cKernel, argList)

    ccall((:occaArgumentListFree, libocca),
          Void,
          (Ptr{Void},),
          argList)
end

function timetaken(k::Kernel)
    return ccall((:occaKernelTimeTaken, libocca),
                 Float64,
                 (Ptr{Void},),
                 k.cKernel)
end

function adddefine(info::KernelInfo, macro_::String, value::String)
    occaValue = ccall((:occaString, libocca),
                      Ptr{Void},
                      (Ptr{Uint8},),
                      bytestring(value))

    ccall((:occaKernelInfoAddDefine, libocca),
          Void,
          (Ptr{Void}, Ptr{Uint8}, Ptr{Void},),
          info.cKernelInfo, bytestring(macro_), occaValue)
end

function finalizer(info::KernelInfo)
    ccall((:occaKernelInfoFree, libocca),
          Void,
          (Ptr{Void},),
          info.cKernelInfo)
end

#---[ Memory ]----------------
function finalizer(m::Memory)
    ccall((:occaMemoryFree, libocca),
          Void,
          (Ptr{Void},),
          m.cMemory)
end

function mode(m::Memory)
    cMode = ccall((:occaMemoryMode, libocca),
                  Ptr{Uint8},
                  (Ptr{Void},),
                  m.cMemory)

    return bytestring(cMode)
end

function memcpy(destTuple, srcTuple, bytes::Number = 0)
    if isa(destTuple, Memory)
        dest = destTuple.cMemory

        destOffset = 0
        convert(Uint, destOffset)

        destIsAMemory = true
    elseif isa(destTuple, Array)
        dest = pointer(destTuple)

        destOffset = 0
        convert(Uint, destOffset)

        destIsAMemory = false
    else
        dest = destTuple[1]

        if isa(dest, Memory)
            dest = dest.cMemory
            destIsAMemory = true
        else
            dest = pointer(destTuple[1])
            destIsAMemory = false
        end

        destOffset = destTuple[2]
        convert(Uint, destOffset)
    end

    if isa(srcTuple, Memory)
        src = srcTuple.cMemory

        srcOffset = 0
        convert(Uint, srcOffset)

        srcIsAMemory = true
    elseif isa(srcTuple, Array)
        src = pointer(srcTuple)

        srcOffset = 0
        convert(Uint, srcOffset)

        srcIsAMemory = false
    else
        src = srcTuple[1]

        if isa(src, Memory)
            src = src.cMemory
            srcIsAMemory = true
        else
            src = pointer(srcTuple[1])
            srcIsAMemory = false
        end

        srcOffset = srcTuple[2]
        convert(Uint, srcOffset)
    end

    convert(Uint, bytes)

    if destIsAMemory
        if srcIsAMemory
            ccall((:occaCopyMemToMem, libocca),
                  Void,
                  (Ptr{Void}, Ptr{Void}, Uint, Uint, Uint,),
                  dest, src, bytes, destOffset, srcOffset)
        else
            ccall((:occaCopyPtrToMem, libocca),
                  Void,
                  (Ptr{Void}, Ptr{Void}, Uint, Uint,),
                  dest, src, bytes, destOffset)
        end
    else
        if srcIsAMemory
            ccall((:occaCopyMemToPtr, libocca),
                  Void,
                  (Ptr{Void}, Ptr{Void}, Uint, Uint,),
                  dest, src, bytes, srcOffset)
        else
            error("One of the arguments should be an OCCA nemory type")
        end
    end
end

function swap(a::Memory, b::Memory)
    tmp       = a.cMemory
    a.cMemory = b.cMemory
    b.cMemory = tmp
end


function rebuildwith(;pthreads=false,opencl=false,cuda=false,openmp=false)
    f=open(thisdir * "/occabuiltwith.jl","w");

    if openmp
        write(f,"OCCA_USE_OPENMP = true;\n");
    else
        write(f,"OCCA_USE_OPENMP = false;\n");
    end
    if pthreads
        write(f,"OCCA_USE_PTHREADS = true;\n");
    else
        write(f,"OCCA_USE_PTHREADS = false;\n");
    end
    if opencl
        write(f,"OCCA_USE_OPENCL = true;\n");
    else
        write(f,"OCCA_USE_OPENCL = false;\n");
    end
    if openmp
        write(f,"OCCA_USE_CUDA = true;\n");
    else
        write(f,"OCCA_USE_CUDA = false;\n");
    end
    close(f);
    reload("OCCA");
 


    USE_OPENMP = openmp;
    USE_PTHREADS = pthreads;
    USE_CUDA = cuda;
    USE_OPENCL = opencl;

    Pkg.build("OCCA");
end


end
