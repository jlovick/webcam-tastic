#!/bin/bash
# give it a count of the number of tasks you want it to spawn then off it goes, spaing them 5 mins appart
for a in `seq 0 $1`
do
if [ $a -lt $1 ]
then
nice ./prototype.sh $1 $a &
echo "$1 $a started"
sleep 2s
fi
done
