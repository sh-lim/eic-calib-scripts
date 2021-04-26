#! /bin/sh

tower_num=$1

function count()
{
    if [ $running -le 1 ]; then
       ./submit.sh $tower_num
        ((tower_num++))
        echo "$tower_num tower is in the queue"
        sleep 10s
    else
        sleep 10m
    fi
}

while [ $tower_num -le 91 ]
do
    running=`condor_q -nobatch | grep $USER | wc -l`
    count
done
