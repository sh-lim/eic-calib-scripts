#! /bin/sh

set -e

# counts the total number of rows
TOT_ROWS=`awk 'END{print NR}' calibtheta.txt`
TOWER_NUM=$1
ROW_NUM=$(($1+1))

function submit()
{
    mkdir -p $TOWER_NUM/log
    condor_submit calibration.sub
}

function set_vars()
{
    if [ $ROW_NUM -le ${TOT_ROWS} ]; then

        theta[ROW_NUM]=`awk 'NR=='$ROW_NUM'{print $3}' calibtheta.txt`
        z0[ROW_NUM]=`awk 'NR=='$ROW_NUM'{print $4}' calibtheta.txt`
        y0[ROW_NUM]=`awk 'NR=='$ROW_NUM'{print $5}' calibtheta.txt`

        MACRO_THETA_ROW=`awk '/\/DRsim\/generator\/theta/{ print NR; exit }' ${MACRO}`
        MACRO_Z0_ROW=`awk '/\/DRsim\/generator\/z0/{ print NR; exit }' ${MACRO}`
        MACRO_Y0_ROW=`awk '/\/DRsim\/generator\/y0/{ print NR; exit }' ${MACRO}`

        sed -i "${MACRO_THETA_ROW}s/-.*/-${theta[ROW_NUM]}/" ${MACRO}
        sed -i "${MACRO_Z0_ROW}s/-.*/-${z0[ROW_NUM]}/" ${MACRO}
        sed -i "${MACRO_Y0_ROW}s/-.*/-${y0[ROW_NUM]}/" ${MACRO}

        INITIAL_DIR_ROW=`awk '/initialdir/{ print NR; exit }' calibration.sub`
        sed -i "${INITIAL_DIR_ROW}s/=.*/= $TOWER_NUM/" calibration.sub
        TRANSFER_INPUT_ROW=`awk '/transfer_input_files/{ print NR; exit }' calibration.sub`
        sed -i "${TRANSFER_INPUT_ROW}s?=.*?= ${INSTALLED_DIR}/DRsim, ${INSTALLED_DIR}/init.mac, ${INSTALLED_DIR}/run_calib.mac?" calibration.sub
        EXECUTION_ROW=`awk '/d0/{ print NR; exit }' calibration.sh`
        sed -i "${EXECUTION_ROW}s?\/d0.*?\/${INSTALLED_DIR}\/DRsim run_calib.mac \$1 calibration_${TOWER_NUM}th?" calibration.sh

        submit

    else
        echo -e "\n-----------------------------------------------"
        echo -e "\nWrong starting tower number!\n"
        echo -e "###############################################"
        echo -e "#                                             #"
        echo -e "#           Automation script ended           #"
        echo -e "#                                             #"
        echo -e "###############################################"
        exit 1
    fi
}

MACRO="run_calib.mac"
set_vars
