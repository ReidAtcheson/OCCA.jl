thisdir = dirname(@__FILE__());
addvectorfile = thisdir * "/addVectors.okl";
function test_okl_ofl_vectoradd(backend::TestBackend)
    linfo=get_info_string(backend);
    entries = 5

    device = OCCA.Device(linfo);

    a  = Float32[1 - i for i in 1:entries]
    b  = Float32[i     for i in 1:entries]
    ab = Array(Float32,(length(a),));

    correctvals = [1.0 for i in 1:entries];

    o_a  = OCCA.malloc(device, a);
    o_b  = OCCA.malloc(device, b);
    o_ab = OCCA.malloc(device, ab);

    addvectors = OCCA.buildkernel(device,
                                            addvectorfile,
                                            "addVectors")

    OCCA.runkernel!(addvectors,
                   entries,
                   o_a, o_b, o_ab)

    OCCA.memcpy!(ab, o_ab)


    return (norm(correctvals-ab)/norm(correctvals))<1e-5
end


