#! /bin/sh

tower_num=$1
at_once=$2

function count()
{
    if [ $running -lt $((500*$(($at_once-1))+5)) ]; then
       ./submit.sh $tower_num
        ((tower_num++))
        echo "$tower_num tower is in the queue"
        sleep 10s
    else
        sleep 1m
    fi
}

while [ $tower_num -le 91 ]
do
    if [ $BATCH_SYS = "lxplus" ]; then
        running=`condor_q -nobatch | grep $USER | wc -l`
        count

    elif [ $BATCH_SYS = "UoS" ]; then
        running=`condor_q -nobatch | grep $USER | wc -l`
        count

    elif [ $BATCH_SYS = "SNU(Tamsa2)" ]; then
        running=`condor_q -nobatch | grep $USER | wc -l`
        count

    elif [ $BATCH_SYS = "KNU(especially cms and cms01)" ]; then
        running=`qstat -u $USER | grep $USER | wc -l`
        count

    else
        echo "Inappropriate system"
        exit
    fi
done
