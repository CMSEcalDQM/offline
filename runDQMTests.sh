#!/bin/bash

THIS=$(readlink -f $0)

if [ "$1" = -b ]; then
    BATCH=1
    shift
else
    BATCH=0
fi

CMSSW_BASE=$1
[[ $CMSSW_BASE =~ ^/ ]] || CMSSW_BASE=$PWD/$CMSSW_BASE
shift

JOBS=$@

if [ $BATCH -eq 1 ]; then
    cd $CMSSW_BASE
    eval `scram runtime -sh`
    cd src/DQMServices/Components/test
    python whiteRabbit.py -j 2 -n $JOBS
else
    if [ ! -d $CMSSW_BASE ]; then
        echo "CMSSW_BASE not valid"
        exit 1
    fi
    [ "$JOBS" = "" ] && JOBS="1 2 3 4 5 6 7 8 9 11 12"
    for job in $JOBS; do
        bsub -q 8nh -J DQM${job}_$(basename $CMSSW_BASE) "$THIS -b $CMSSW_BASE $job"
    done
fi
