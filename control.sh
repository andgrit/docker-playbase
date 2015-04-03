#!/bin/bash
set -x
set -e

# This shell script is used both to create the docker image and as the entrypoint for the docker image.
# The current working directory, WORKDIR in the Dockerfile, should be set before theis assumed to be the same when the docker image is created and when
# the entry point is executed.  

# openjdk is the latest tested but I think oracle will work as well
#java=oracle

# for openjdk the jdk will be installed to compile the play program and create the package
# then the jdk will be uninstalled and the jre installed for use to run the program
java=openjdk


# if no parameters this is the default entry point.  The dist command (see below)
# put the name of the play executable into playexe
if [[ $# == 0 ]]; then
    # export JAVA_HOME=/usr/lib/jvm/java-8-oracle
    x=$( cat playexe )
    exec ./$x
fi

# the entry point can be -- whatever to debug.  Try: -- bash
if [ "$1" == "--" ]; then
    echo $*
    shift
    exec "$*"
fi

# install all the pre-requisites to run a play program, git the play program,
# dist the play program and unzip the results so it is ready to run.
# then clean up everything else.
cleanup="false"
if [ "$1" == "dist" ]; then
    cleanup="true"
fi

apt-get update
#apt-get install -y git build-essential wget zip unzip software-properties-common
apt-get install -y git wget unzip

# set up the temp dir to be deleted during clean up
tmpDir=/tmp/tmp
mkdir $tmpDir
pushd $tmpDir

# Install play
wget http://downloads.typesafe.com/typesafe-activator/$ACTIVATOR_VERSION/typesafe-activator-$ACTIVATOR_VERSION.zip
unzip typesafe-activator-$ACTIVATOR_VERSION.zip
activatorBin=$tmpDir/activator-$ACTIVATOR_VERSION/activator

case $java in
oracle)
    # Install Java and dependencies
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections
    add-apt-repository -y ppa:webupd8team/java
    apt-get install -y oracle-java8-installer
    ;;
openjdk)
    apt-get install -y openjdk-7-jdk
    ;;
esac


# git the code and cd into the play directory
playDir="playprojectdir"
git clone $PLAY_REPOSITORY $playDir
cd $playDir

# tell activator to store ivy and sbt caches in the tmpDir
export _JAVA_OPTIONS=-Duser.home=$tmpDir

# build the tar ball
$activatorBin universal:packageZipTarball

# the distribution was all done in tmp/tmp so come home and finish up
# The output of activator are some funny escaped character sequences so after getting to the last word
# strip off the first and last 4 characters
x=$( $activatorBin universal:normalizedName )
normalizedName=${x##* }
normalizedName=${normalizedName:4:-4}
x=$( $activatorBin universal:name )
name=${x##* }
name=${name:4:-4}

popd

tar xvf $tmpDir/$playDir/target/universal/$name.tgz
echo $name/bin/$normalizedName > playexe


if [ $cleanup == "true" ]; then
    apt-get remove --purge --auto-remove -y git wget unzip
    case $java in
    openjdk)
        apt-get remove --purge --auto-remove -y openjdk-7-jdk
        apt-get install -y openjdk-7-jre-headless
        ;;
    oracle)
        rm -rf /var/cache/oracle-jdk8-installer
        ;;
    esac
    rm -rf $tmpDir
    rm -rf /var/lib/apt/lists/*
fi
