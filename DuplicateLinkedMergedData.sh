#!/bin/sh
a=1
prefix=$1
nreps=`expr $2 - 1`
while [ $a -le $nreps ] 
	do b=`expr $a + 1`
	mkdir ${PWD}/${prefix}_${b}
    ln -s ${PWD}/${prefix}_${a}/merged_data ${prefix}_${b}/merged_data 
	a=${b}
done

