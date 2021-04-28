# eic-calib-scripts
Scripts for DR-EIC Calibration

## How-to
After fetching the repository, do

    cd eic-calib-scripts
    cp * /<path-to-/build/DRsim>
    cd <path-to-/build/DRsim>
    chmod +x Auto_running.sh
    ./Auto_running.sh
    
If usint install dir. then should add below line to calibration.sh at a line above last line.

    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HEPMC_DIR/lib64:$FASTJET_DIR/lib:$PYTHIA_DIR/lib:$PWD/lib
    
So calibration.sh from
    
    ...
    /d0/scratch/{-build/DRsim directory path-}/DRsim run_calib.mac $1 calibration_0th

to
    
    export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HEPMC_DIR/lib64:$FASTJET_DIR/lib:$PYTHIA_DIR/lib:$PWD/lib
    /d0/scratch/{-build/DRsim directory path-}/DRsim run_calib.mac $1 calibration_0th

## NOTE

    ps -aus | grep manage
    
manage_number.sh runs background to submit successive simulatio.

    condor_q -nobatch | grep $USER | wc -l
   
If above commands output is "1", it means simulation is done, then manage_number.sh submit next simulation jobs.
You must kill manage_number.sh before remove condor batch job.

## After simulation

    source setenv-cc7-gcc8.sh
    cd <0 - 91 (which you want)>
    hadd <Filename which you want>.root ./*.root
    mv <Filename>.root ../analysis
    ./calib <Filename> <0 - 91>


