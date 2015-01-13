#Functions for testing the existence of different parallel libraries.
include("check_libraries.jl");

occa_github = "https://github.com/tcew/OCCA2.git";

#Save current directory.
olddir=pwd();

#Get directory of build file.
thisfile = @__FILE__();
thisdir  = dirname(thisfile);

#Change to dependencies directory.
cd(thisdir);

#If OCCA2 doesn't exist, download source from git.
occadir = thisdir * "/OCCA2";
if !isdir(occadir);
    run(`git clone $occa_github`);
end


#Set necessary environment variables
ENV["OCCA_DIR"]=occadir;

if openmp_exists()
    ENV["OCCA_OPENMP_ENABLED"]=1;
end
if pthreads_exists()
    ENV["OCCA_PTHREADS_ENABLED"]=1;
end
if cuda_exists()
    ENV["OCCA_CUDA_ENABLED"]=1;
end
if opencl_exists()
    ENV["OCCA_OPENCL_ENABLED"]=1;
end

#Run the main build command.
cd(occadir);
print(pwd());print("\n");
run(`make`);


#Return to previous directory.
cd(olddir);



