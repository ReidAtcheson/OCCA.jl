function test_okl_reduction(backend::TestBackend)
    linfo=get_info_string(backend);
    entries=10000;
    nred   =256;

    reducedentries = ceil(Int64,(entries+nred-1)/nred);
    a=Array(Float32,(entries,)); a[:]=1.0;
    ared=Array(Float32,(reducedentries,)); ared[:]=0.0;

    kernelinfo = OCCA.KernelInfo();
    OCCA.adddefine!(kernelinfo,"p_Nred",@sprintf("%d",nred));


    device  = OCCA.Device(linfo);
    o_a     = OCCA.malloc(device, a);
    o_ared  = OCCA.malloc(device, ared);

    reduction = OCCA.buildkernel(device,"reduction.okl","reduction",kernelinfo);



    OCCA.runkernel!(reduction,entries,o_a,o_ared);

    OCCA.memcpy!(ared,o_ared);


    val=sum(ared);

    

    relerr= abs(sum(a)-val)/sum(a);

    return relerr<1e-5;


end
