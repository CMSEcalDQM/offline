#!/bin/bash

if [ ! $MONITOR_ROOT ]; then
    echo "GUI environment not set up"
    echo 'source $YourInstallation/current/apps/dqmgui/etc/profile.d/env.sh'
    exit 1
fi

PARENT=$(dirname $MONITOR_ROOT)
while [ $PARENT != "MYDEV" ]; do
    PARENT=$(dirname $PARENT)
done
GUIDIR=$(dirname $PARENT)

IX=$GUIDIR/state/dqmgui/dev/ix

echo $@

source $GUIDIR/current/apps/dqmgui/etc/profile.d/env.sh

[ -e $IX ] || visDQMIndex create $IX

visDQMIndex add --dataset /Global/Online/ALL $IX $@
