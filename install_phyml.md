# How to install phyml for multiple threads locally #
Version 0.1 (not tested - use at your own risk)

Phyml is a program for phylogenetic estimation. The single core version is globally installed on our servers. Start it with:
~~~
phyml
~~~
--------------------------------

Although the program is globally installed on our servers with version 20131022, you may want to run the newest version which is available on github and allows to use multiple cores. You have to install phyml version 3.2.0 in your local directory.

Download and install from git:
~~~
cd ~
mkdir -p programs
cd programs
wget https://github.com/stephaneguindon/phyml/releases/download/v3.2.20160530/phyml-mpi
~~~

To start phyml with 7 cores, type e.g.:
~~~ 
mpirun -n 7 ~/programs/phyml-mpi -i myseq -b 100
~~~

