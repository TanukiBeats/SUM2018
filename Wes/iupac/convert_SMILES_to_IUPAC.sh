#!/bin/bash

SMILES_LIST="$@"
COUNT=11

for SMILES in $SMILES_LIST
do
   #echo https://cactus.nci.nih.gov/chemical/structure/${SMILES}/iupac_name
    IUPAC=`curl -s --globoff "https://cactus.nci.nih.gov/chemical/structure/${SMILES}/iupac_name"`
    if IUPAC=="<!DOCTYPE html>*"
	IUPAC="BAD STRUCTURE"
    fi
    echo MOLECULE ${COUNT} HERE ${IUPAC}
    COUNT=$(($COUNT + 1))
done
