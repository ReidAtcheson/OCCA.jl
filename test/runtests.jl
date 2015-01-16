module TESTOCCA
using OCCA
using Base.Test


function test_vectoradd(kernelfile)
    entries = 5
    device = OCCA.Device("OpenMP", 0, 0);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Float32[0     for i in 1:entries]

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addVectors = OCCA.buildKernelFromSource(device,
                                            kernelfile,
                                            "addVectors")

    dims = 1;
    itemsPerGroup = 2;
    groups = (entries + itemsPerGroup - 1)/itemsPerGroup;

    OCCA.setWorkingDims(addVectors,
                        dims, itemsPerGroup, groups);

    OCCA.runKernel(addVectors,
                   (entries, Int32),
                   o_a, o_b, o_ab)

    OCCA.memcpy(ab, o_ab)

    println(ab)

    return true;
end



@test test_vectoradd("addVectors.ofl") == true;
@test test_vectoradd("addVectors.okl") == true;
@test test_vectoradd("addVectors.occa") == true;


end
