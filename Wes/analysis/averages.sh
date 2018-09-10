#!/bin/bash

while IFS='' read -r line || [[ -n "$line" ]]; do
	echo "${line}"
	grep "${line}" dens_edit.csv >> dens_fluc.csv
	grep "${line}" cpt_edit.csv >> cpt_fluc.csv
	echo " " >> dens_fluc.csv
	echo " " >> dens_fluc.csv
	echo " " >> cpt_fluc.csv
	echo " " >> cpt_fluc.csv
done < "$1"
 

