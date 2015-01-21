occa_github = "https://github.com/tcew/OCCA2.git";

occapkgdir = Pkg.dir() * "/OCCA";

if !isfile(occapkgdir * "/src/occabuiltwith.jl")
    f=open(occapkgdir * "/src/occabuiltwith.jl","w");
    write(f,"OCCA_USE_OPENMP   = false;\n");
    write(f,"OCCA_USE_PTHREADS = false;\n");
    write(f,"OCCA_USE_OPENCL   = false;\n");
    write(f,"OCCA_USE_CUDA     = false;\n");
    close(f);
end


f = open(occapkgdir * "/src/occapaths.jl","w");
write(f, "const libocca=\"" * occapkgdir * "/deps/OCCA2/lib/libocca.so\"");
close(f);

using OCCA;


currentdir = pwd();
cd(occapkgdir);

occadir = occapkgdir * "/deps/OCCA2";

# If OCCA2 doesn't exist, download source from git.
if !isdir(occadir);
    run(`git submodule add $occa_github deps/OCCA2`);
else
    run(`git submodule foreach git pull`);
end

cd(currentdir);

# Set necessary environment variables
ENV["OCCA_DIR"] = occadir;

if OCCA.USE_OPENMP
    ENV["OCCA_OPENMP_ENABLED"] = 1;
end
if OCCA.USE_PTHREADS
    ENV["OCCA_PTHREADS_ENABLED"] = 1;
end
if OCCA.USE_CUDA
    ENV["OCCA_CUDA_ENABLED"] = 1;
end
if OCCA.USE_OPENCL
    ENV["OCCA_OPENCL_ENABLED"] = 1;
end


# Run the main build command.
run(`make -f $occadir/makefile clean`);
run(`make -j -f $occadir/makefile COMPILING_WITH_JULIA=1`);
