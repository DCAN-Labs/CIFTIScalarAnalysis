#!/bin/sh
a=1
prefix=$1
nreps=`expr $2 - 1`
while [ $a -le $nreps ] 
	do b=`expr $a + 1`
	sed 's|_1|_'${b}'|' <${prefix}_1.params > ${prefix}_${b}.params
	a=${b}
done

