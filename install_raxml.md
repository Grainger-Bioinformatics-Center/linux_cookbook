# How to install phyml for multiple threads locally #
Version 0.1 (not tested - use at your own risk)

RAxML is a program for phylogenetic maximum likelihood estimation. The program is globally installed on our servers. Start the sequetial or parallel MPI version with:
~~~
raxmlHPC-SSE3 [...]
~~~

And start it with Pthreads-based parallelization with:
~~~
raxmlHPC-PTHREADS [...]
~~~

An example command line to stat RAxML with the mydata.phy file could look like:
~~~
raxmlHPC-PTHREADS -s mydata.phy -n mydata-output -m GTRGAMMA -f a -p 194955 -x 12345 -# 100 -T 12 
~~~

-----------------
[RAxML manual](http://sco.h-its.org/exelixis/php/countManualNew.php)