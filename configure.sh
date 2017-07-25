#!/bin/bash

INSTALLPATH='/usr/share/ssdsPipeline/'
GENOMESPATH='/usr/share/ssdsPipeline/genomes/'
	
while [[ $# -gt 1 ]]
	do
	key="$1"

	case $key in
		-g|--genomes)
		GENOMESPATH="$2"
		shift # past argument
		;;
		-i|--install_dir)
		INSTALLPATH="$2"
		shift # past argument
		;;
		*)
		# unknown option
		;;
	esac
	
	shift # past argument or value
	
done

echo INSTALL PATH    = "${INSTALLPATH}"
echo GENOMES FOLDER  = "${GENOMESPATH}"

######################## DONE ARGS ######################

## Create Genomes Folder
mkdir -p $GENOMESPATH || exit 1
chmod a+rw $GENOMESPATH || exit 1

## Copy git folder to install location
RUNDIR=`pwd`
FLDNAME=`basename $RUNDIR`

TSTFILE=$RUNDIR'/run_ssDNAPipeline'

if [ -f $TSTFILE ]; then
   echo "OK ... configuring SSDS alignment pipeline ..."
else
   echo "** ERROR **"
   echo "Cannot execute config script from $RUNDIR"
   echo "Please run configure.sh from the call hotspots pipeline folder."
   echo "This folder contains the run_ssDNAPipeline script."
   exit
fi

cp -r $RUNDIR/* $SSDSPATH || exit 1

RUNDIR=$INSTALLPATH

## Get packages
apt-get install -y default-jre zlibg-dev bioperl || exit 1
 
## Get perl modules
export PERL_MM_USE_DEFAULT=1
cpan File::Temp || exit 1
cpan Getopt::Long || exit 1
cpan Math::Round || exit 1
cpan Statistics::Descriptive || exit 1
cpan Switch || exit 1

perl $RUNDIR/Bio-SamTools-1.43/INSTALL.pl

## Add environment vars to .bashrc
for thisBASHRC in `find /home -maxdepth 2 -name '.bashrc'` '/root/.bashrc'; do
	echo ' ' >>$thisBASHRC || exit 1
	echo 'export SSDSPIPELINEPATH='$RUNDIR >>$thisBASHRC || exit 1
	echo 'export SSDSPICARDPATH='$RUNDIR'/picard-tools-2.3.0' >>$thisBASHRC || exit 1
	echo 'export SSDSFASTXPATH='$RUNDIR >>$thisBASHRC || exit 1
	echo 'export SSDSSAMTOOLSPATH='$RUNDIR >>$thisBASHRC || exit 1
	echo 'export SSDSGENOMESPATH='$GENOMESPATH >>$thisBASHRC || exit 1
	echo 'export SSDSTMPPATH=/tmp' >>$thisBASHRC || exit 1
	echo 'export PERL5LIB=$PERL5LIB:'$RUNDIR >>$thisBASHRC || exit 1
done

## Export environment vars for current session
export SSDSPIPELINEPATH=$RUNDIR >>$thisBASHRC || exit 1
export SSDSPICARDPATH=$RUNDIR'/picard-tools-2.3.0' >>$thisBASHRC || exit 1
export SSDSFASTXPATH=$RUNDIR >>$thisBASHRC || exit 1
export SSDSSAMTOOLSPATH=$RUNDIR >>$thisBASHRC || exit 1
export SSDSGENOMESPATH=$RUNDIR'/genomes' >>$thisBASHRC || exit 1
export SSDSTMPPATH=/tmp >>$thisBASHRC || exit 1
export PERL5LIB=$PERL5LIB':'$RUNDIR >>$thisBASHRC || exit 1

## Output some info
echo ''
echo $SSDSPIPELINEPATH' ... OK SSDS PIPELINE PATH?'
echo $SSDSGENOMESPATH' ... OK GENOMES PATH?'
echo ''
echo '-------------------------------------------------'
echo "Configuration complete ... running unit tests ..."
echo '-------------------------------------------------'

## Run tests
sh $RUNDIR\/unitTest/runTest.sh || exit 1

## Give the ALL OK !!
echo "Tests complete ..."
echo "SSDS alignment pipeline installed to "$SSDSPIPELINEPATH
echo 'Restart computer or logout/login to use ..'
