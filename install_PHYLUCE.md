# How to install PHYLUCE v1.5 on our linux server #
Version 0.1 (not tested - use at your own risk)

Before you can install PHYLUCE v1.5 into your home directory, you have to change the version of java and download and older version of anaconda:

## Install Java version 7 ##
Please note that you can only copy the java file when you're connected to Vortex. If you want to install PHYLUCE to a different server, you can find it in the [java archives](http://www.oracle.com/technetwork/java/javase/downloads/java-archive-downloads-javase7-521261.html). Download the file with the name: jdk-7u79-linux-x64.tar.gz. 
~~~
cd ~
mkdir opt
cd opt
mkdir java
cd java
cp /home/felix/opt/java/jdk-7u79-linux-x64.tar.gz ./
tar -xzvf jdk-7u79-linux-x64.tar.gz
rm jdk-7u79-linux-x64.tar.gz
ln -s jdk1.7.0_79/ latest
echo '#Changes Version of Java to 1.7 for phylUCE' >>~/.bashrc
echo 'export JAVA_HOME=~/opt/java/latest/bin/java' >>~/.bashrc
echo 'export PATH=~/opt/java/latest/bin:$PATH' >>~/.bashrc
echo 'export MANPATH=~/opt/java/latest/man:$MANPATH' >>~/.bashrc
source ~/.bashrc
cd ~
~~~


## Install anaconda ##
~~~
cd ~
wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.2.0-Linux-x86_64.sh
bash Anaconda-2.2.0-Linux-x86_64.sh
source ~/.bashrc
~~~
Follow instructions: press space bar to page through license agreement, then enter 'yes'. Press Enter to accept default install location. Wait for the install to finish and answer 'yes' to prepend the install location to your PATH.

## Install PHYLUCE ##
~~~
conda config --add channels http://conda.binstar.org/faircloth-lab
conda install phyluce
~~~
When asked to proceed, type 'y'.

## Install Illumiprocessor ##
~~~
conda install illumiprocessor
~~~

---------
To verify your installation and get familiar with the PHYLUCE pipeline, try to complete the tutorial on this [webpage](https://phyluce.readthedocs.io/en/latest/tutorial-one.html).



