#!/bin/bash
set -e
all=$1
num=$2

root=/gscratch/pfaendtner/maneko/Summer2018/Wes/simulationRuns/slurm

cat=$(echo $all | cut -f1 -d-)
anio=$(echo $all | cut -f2 -d-)

name=${cat}_${anio}

cd $root

if [ ! -d $root/$name ] ; then
	cp -rf $root/blank $name
fi

cp $root/pdb_files/${cat}.pdb $root/$name/structures
cp $root/pdb_files/${anio}.pdb $root/$name/structures

cd $root/$name/inputs
sed -i "1s/cat/$cat/" salt.inp
sed -i "1s/anio/$anio/" salt.inp

sed -i "2s/cat/$cat/" directory.inp
sed -i "2s/anio/$anio/" directory.inp

source salt.sh salt.inp

cd $root/$name/scripts
sed -i "4s/num/$num/" GROMACS.slurm
sed -i "4s/num/$num/" boxmaker.slurm

cd $root

