# How to install MrBayes as multicore version #
Version 0.1 (not tested - use at your own risk)

MrBayes is a program for phylogenetic reconstruction. You can start it on our servers with the command:
~~~
mb
~~~
----------------------------
However, to run MrBayes with multiple cores, you need to install a personal version into your local directory.

Type in the command line of the server:
~~~
cd ~
mkdir -p programs
~~~

Now, download the MrBayes source code [here](mrbayes-3.2.6.tar.gz) and copy it into the programs folder in your home directory (~/programs) on the server.

Back on the server, enter:
~~~
cd ~/programs
tar zxvf mrbayes-3.2.6.tar.gz
cd mrbayes-3.2.6/src
autoconf
./configure --enable-mpi=yes --with-beagle=no
make
~~~
>You may have to adjust to the newest version number that you downloaded

To start MrBayes with 6 parallel cores:
~~~
cd ~
mpirun -np 6 ~/programs/mb
~~~

Find more information on this topic here:
[link1](https://dwheelerau.com/2012/06/16/making-mrbays-run-on-a-mulitcore-machine-9/)
