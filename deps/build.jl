occa_github = "https://github.com/tcew/OCCA2.git";

#Save current directory.
olddir=pwd();

#Get directory of build file.
thisfile = @__FILE__();
thisdir  = dirname(thisfile);

#Change to dependencies directory.
run(`cd $thisdir`);

#If OCCA2 doesn't exist, download source from git.
occadir = thisdir * "/OCCA2";
if !isdir(occadir);
    run(`git clone $occa_github`);
end

run(`cd $occadir`);
run(`make`);
run(`cd $thisdir`);

#Return to previous directory.
run(`cd $olddir`);
