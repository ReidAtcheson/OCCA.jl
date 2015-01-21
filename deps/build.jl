occa_github = "https://github.com/tcew/OCCA2.git";

#Save current directory.
olddir=pwd();

#Get directory of build file.
thisfile = @__FILE__();
thisdir  = dirname(thisfile);

#Change to dependencies directory.
cd(thisdir);


if !isfile("../src/occabuiltwith.jl")
    f=open("../src/occabuiltwith.jl","w");
    write(f,"OCCA_USE_OPENMP = false;\n");
    write(f,"OCCA_USE_PTHREADS = false;\n");
    write(f,"OCCA_USE_OPENCL = false;\n");
    write(f,"OCCA_USE_CUDA = false;\n");
    close(f);
end


f=open("../src/occapaths.jl","w");
write(f,"const libocca=\"$(thisdir)/OCCA2/lib/libocca.so\"");
close(f);

using OCCA;


#If OCCA2 doesn't exist, download source from git.
occadir = thisdir * "/OCCA2";
if !isdir(occadir);
    run(`git clone $occa_github`);
end


#Set necessary environment variables
ENV["OCCA_DIR"]=occadir;

if OCCA.USE_OPENMP
    ENV["OCCA_OPENMP_ENABLED"]=1;
end
if OCCA.USE_PTHREADS
    ENV["OCCA_PTHREADS_ENABLED"]=1;
end
if OCCA.USE_CUDA
    ENV["OCCA_CUDA_ENABLED"]=1;
end
if OCCA.USE_OPENCL
    ENV["OCCA_OPENCL_ENABLED"]=1;
end



#Run the main build command.
cd(occadir);
run(`make clean`);
run(`make OCCA_COMPILING_WITH_JULIA=1`);


#Return to previous directory.
cd(olddir);
