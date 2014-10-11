#!/bin/bash

WORKDIR=$(dirname $(readlink -f $0))

CMSSW_BASE=$1
[[ $CMSSW_BASE =~ ^/ ]] || CMSSW_BASE=$PWD/$CMSSW_BASE

if [ -z "$CMSSW_BASE" ]; then
    echo "CMSSW_BASE not set"
    exit 1
fi

echo "Checking $CMSSW_BASE"

TAG=$(basename $CMSSW_BASE)

if [ -d $WORKDIR/tests/$TAG ]; then
    echo "Test results for $TAG already exists. Overwrite? [y/n]:"
    while read RESPONSE; do
        if [ $RESPONSE = "y" ]; then
            break
        elif [ $RESPONSE = "n" ]; then
            echo "Quitting."
            exit 0
        else
            echo "y/n:"
        fi
    done
else
    mkdir -p $WORKDIR/tests/$TAG
fi

[ -d $WORKDIR/plots ] || mkdir -p $WORKDIR/plots

TESTDIR=$CMSSW_BASE/src/DQMServices/Components/test

RESULTS=

for DIR in $(ls $TESTDIR); do
    [[ $DIR =~ ^[0-9]+$ ]] || continue

    for SUBDIR in $(ls $TESTDIR/$DIR); do
        [[ $SUBDIR =~ ^[0-9]+$ ]] || continue

        rm -rf $WORKDIR/tests/$TAG/$SUBDIR 2> /dev/null
        mv $TESTDIR/$DIR/$SUBDIR $WORKDIR/tests/$TAG/

        stat $TESTDIR/$DIR/${SUBDIR}_OK.log > /dev/null 2>&1

        if [ $? -eq 0 ]; then
            LSRES=$(ls $WORKDIR/tests/$TAG/$SUBDIR/DQM_V*_R*__Global__CMSSW_X_Y_Z__RECO*.root 2> /dev/null)
            NRES=$(wc -w <<< $LSRES)

            THEFILE=
            if [ $NRES -eq 1 ]; then
                THEFILE=$LSRES
            elif [ $NRES -gt 1 ]; then
                THEFILE=$(cut -f 1 -d " " <<< $LSRES)
                IFILE=$(sed 's/.*RECO_\([0-9]*\)[.]root/\1/' <<< $THEFILE)
                for FILE in $(cut -f 2- -d " " <<< $LSRES); do
                    I=$(sed 's/.*RECO_\([0-9]*\)[.]root/\1/' <<< $FILE)
                    if [ $I -gt $IFILE ]; then
                        IFILE=$I
                        THEFILE=$FILE
                    fi
                done
            fi
              
            if [ -n "$THEFILE" ]; then
                NEWNAME=$(sed -e "s/Global/Test$SUBDIR/" -e "s/CMSSW_X_Y_Z/$TAG/" <<< $(basename $THEFILE))
                mv $THEFILE $WORKDIR/plots/$NEWNAME
            fi

            RESULTS="${SUBDIR}_OK $RESULTS"
            touch "$WORKDIR/tests/$TAG/@${SUBDIR}_OK"
        else
            RESULTS="${SUBDIR}_Failed $RESULTS"
            touch "$WORKDIR/tests/$TAG/@${SUBDIR}_Failed"
        fi
    done
    
    rm -r $TESTDIR/$DIR
done

echo $RESULTS
