#!/bin/bash
set -e

###PACK THE BOX USING BOXMAKER 
echo " "
echo "checking for setup files"
cd $SETUP
currentTemp=298.15
if [ ! -f $SETUP/conf.gro ] ; then
  cp $SCRIPTS/acpype.py $SETUP/
  cp $INPUTS/packmol.inp $SETUP/
  cp $SCRIPTS/boxmaker.bash $SETUP/
  cp $STRUCTURES/${IL_CAT}* $SETUP/
  cp $STRUCTURES/${IL_AN}* $SETUP/
  cp $SCRIPTS/boxmaker.slurm $SETUP/
  cp $INPUTS/${name}.inp $SETUP/
  cp $INPUTS/directory.inp $SETUP/
  sed -i "8s/.*/source ${name}.inp/" $SETUP/boxmaker.bash
  cd $SETUP/
  sed -i "33s/.*/source boxmaker.bash/" boxmaker.slurm
  sbatch boxmaker.slurm
fi
while true ; do
  if [ ! -f $SETUP/conf.gro ] ; then
    sleep 60
  else
    echo "boxmaker complete... moving forward"
    sleep 1
    break
  fi
done
###ENERGY MINIMIZE THE BOXMAKER STRUCTURE
echo " "
echo "beginning energy minimization"
cd $ILhome
if [ ! -d $ILhome/min ] ; then
  mkdir min
  echo "made mini directory"
fi
if [ ! -f min/confout.gro ] && [ ! -f min/md.log ] ; then
  echo "initiating energy minimization" 
  cp $INPUTS/min.mdp min/
  cp $SCRIPTS/GROMACS.slurm min/GROMACS.slurm
  #cp $SCRIPTS/nodeseaker.sh min/nodeseaker.sh
  cp $SETUP/conf.gro min/
  cp $SETUP/topol.top min/
  cd min/
  gmx_8c grompp -f min.mdp
  #source nodeseaker.sh
  wait
  sbatch GROMACS.slurm
  cd -
fi
while true ; do
  if [ ! -f $ILhome/min/confout.gro ] ; then
    sleep 60
  else
    echo "minimization complete... moving forward"
    sleep 1
    break
  fi
done
###RUN BERENDSEN EQUILIBRATION
echo " "
if [ -f $ILhome/min/confout.gro ] ; then  
  if [ ! -d $ILhome/equilibrate ] ; then
    mkdir $ILhome/equilibrate
    echo "made equilibrate directory"
  fi
  cd $ILhome
  if [ -f equilibrate/confout.gro ] ; then    
    echo "equilibrate files present..."
  elif [ ! -f equilibrate/md.log ] ; then
    echo "creating new files: equilibrate/"
    cd $ILhome/min/
    cp confout.gro ../equilibrate/conf.gro
    cd -
    cp $SCRIPTS/GROMACS.slurm equilibrate/GROMACS.slurm
    cp $INPUTS/npt.mdp equilibrate/npt.mdp
    #cp $SCRIPTS/nodeseaker.sh equilibrate/nodeseaker.sh
    cp min/topol.top equilibrate/
    cd equilibrate/
    sed -i "51s/.*/ref_t			= ${currentTemp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${currentTemp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 1
    #source nodeseaker.sh
    wait
    sbatch GROMACS.slurm
    sleep 5
    cd -
    echo "equilibration setup complete"
  fi 
  bad_files=`ls $ILhome/equilibrate/step* | wc -l`  
  if [ $bad_files -gt 0 ] ; then
    echo "did not properly minimize, exiting"
    #echo "equilibration error for ${name} in ${ROOT}" | mail -s "sad message from hyak" wesleybeckner@gmail.com
    return 1
  fi
fi
cd $ILhome/
while true ; do
  if [ ! -f $ILhome/equilibrate/confout.gro ] ; then
    sleep 600
    bad_files=`ls $ILhome/equilibrate/step* | wc -l`  
    if [ $bad_files -gt 0 ] ; then
      echo "did not properly minimize, exiting"
      #echo "equilibration error for ${name} in ${ROOT}" | mail -s "message from hyak" wesleybeckner@gmail.com
      return 1
    fi
    if [ -f $ILhome/equilibrate/md.log ] ; then 
      tail -11 $ILhome/equilibrate/md.log
    fi
  else
    echo "equilibration complete... moving forward"
    sleep 1
    break
  fi
done
####RUN PARRINELLO-RAHMAN
if [ -f $ILhome/equilibrate/confout.gro ] ; then
  if [ ! -d $ILhome/npt ] ; then
    mkdir $ILhome/npt
    echo "made npt directory"
  fi
  cd $ILhome
  if [ -f npt/confout.gro ] ; then    
    echo "npt files present..." 
  elif [ ! -f npt/conf.gro ] ; then  	
    echo "creating new files: npt/"   
    cp $ILhome/equilibrate/confout.gro npt/conf.gro
    cp $SCRIPTS/GROMACS.slurm npt/GROMACS.slurm
    cp $INPUTS/npt.mdp npt/npt.mdp
    cp $ILhome/equilibrate/topol.top npt/
    cd npt/
    sed -i "61s/.*/gen_vel                 = no/" npt.mdp
    sed -i "54s/.*/Pcoupl                  =  Parrinello-Rahman/" npt.mdp
    sed -i "51s/.*/ref_t			= ${currentTemp}/" npt.mdp 
    sed -i "62s/.*/gen_temp		= ${currentTemp}/" npt.mdp 
    gmx_8c grompp -f npt.mdp -maxwarn 2
    sbatch GROMACS.slurm
    echo "npt setup complete" 
  elif [ ! -f npt/confout.gro ] && [ -f npt/${i}/md.log ] ; then  	
    cd npt/
    sbatch GROMACS.slurm
    cd -
  fi
fi
cd $ILhome
while true ; do
  if [ ! -f $ILhome/npt/confout.gro ] ; then
    sleep 600
    if [ -f $ILhome/npt/md.log ] ; then 
      tail -11 $ILhome/npt/md.log
    fi
  else
    echo "npt complete... moving forward"
    sleep 1
    break
  fi
done
echo " "
echo "production runs complete"
cd $SCRIPTS

