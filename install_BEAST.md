# How to install BEAST on our linux server #
Version 0.1 (not tested - use at your own risk)

You need to install a copy of BEAST (here version 1.8.3) into your local folder to run it on the server:
~~~
cd ~
mkdir -p /programs
cd programs
wget https://github.com/beast-dev/beast-mcmc/releases/download/v1.8.3/BEASTv1.8.3.tgz
tar zxvf BEASTv1.8.3.tgz
~~~

To start BEAST:
~~~
~/programs/BEASTv1.8.3/bin/beast -beagle_off yourinputfile.xml
~~~
or 
~~~
~/programs/BEASTv1.8.3/lib/beast -help
~~~
for more information.

To start BEAST with multiple cores (here 4) type:
~~~
~/programs/BEASTv1.8.3/bin/beast -beagle_off -threads 4 yourinputfile.xml
~~~
