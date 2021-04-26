# eic-calib-scripts
Scripts for DR-EIC Calibration

## How-to
After fetching the repository, do

    cd eic-calib-scripts
    cp * ../
    cd ..
    chmod +x Auto_running.sh
    ./Auto_running.sh

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


