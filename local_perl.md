# How to install Perl modules locally #
Version 0.1 (not tested - use at your own risk)

It may be required for you to install Perl modules locally as you don't have administrative rights on any of the servers at the Field Museum. Here I will describe two ways to install these modules to your home directory; with the use of local::lib and without. The first of both solutions shows you how to use local::lib to create a local folder in which you can install modules from CPAN (The Comprehensive Perl Archive Network), a curated library with many Perl modules. Then you can see how to install downloaded modules with local::lib. The last solution will show how to install downloaded modules without local::lib.

## Local installation of CPAN modules with local::lib ##

This is my preferred solution! Here we use local::lib to create a local folder in your home directory in which from now on all libraries from CPAN (or downloaded - see below) will be locally installed.

Type each line after another:

~~~
cd ~
wget http://search.cpan.org/CPAN/authors/id/H/HA/HAARG/local-lib-2.000018.tar.gz
tar zxf local-lib-2.000018.tar.gz
cd ~/local-lib-2.000018
perl Makefile.PL --bootstrap
make test && make install
echo 'eval $(perl -I $HOME/perl5/lib/perl5 -Mlocal::lib)' >>~/.bashrc
source ~/.bashrc
~~~

If you're asked *"Would you like me to configure as much as possible automatically? [yes]"*, type:
~~~
yes
~~~

Test if everything works fine by typing these two lines, one after another:

~~~
cpan Acme::Time::Baby
perl -MAcme::Time::Baby -E 'say babytime'
~~~

If you get the time in baby language everything works fine. A error message such as **Can't locate Acme/Time/Baby.pm in @INC" blah, blah, blah...** indicates the local installation didn't work.

Further installation of modules from CPAN work very similar. For example, if you want to install **File::Which** to run [map_and_extract.pl](https://github.com/felixgrewe/map_n_extract), you type:

~~~
cpan File::Which
~~~

Installation should start and complete automatically.

-----------

Find more information here:

[link1](http://search.cpan.org/~haarg/local-lib-2.000018/lib/local/lib.pm)

[link2](http://scratching.psybermonkey.net/2010/03/perl-how-to-install-perl-module-without.html) 

## Local installation of downloaded Perl modules with local::lib ##

After local::lib installation, all of your downloaded modules should get installed into your home directory. E.g. download and unzip the module "baby time":

~~~
wget https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/Acme-Time-Baby-2010090301.tar.gz
tar zxf Acme-Time-Baby-2010090301.tar.gz
cd Acme-Time-Baby-2010090301
~~~

Now prepare the installation:

~~~
perl Makefile.PL
make
make test
~~~

And if all tests pass successful, continue:

~~~
make install
~~~

## Local installation of downloaded Perl modules without local::lib ##

If you don't want to install local::lib, you have to follow this description.

With local::lib installed, you'll find a folder **perl5** with folders **bin, lib, and man** in your home directory. Without local::lib, you have create these folders by yourself:

~~~
cd ~
mkdir perl5
mkdir perl5/bin
mkdir perl5/man
mkdir perl5/man/man1
mkdir perl5/lib
~~~

Then you have to create a file with variables to configure Perl locally:

~~~
touch perl_local_config
echo PREFIX=$HOME/perl5/perl_modules \ >> perl_local_config
echo INSTALLSCRIPT=$HOME/perl5/bin \ >> perl_local_config
echo INSTALLBIN=$HOME/perl5/bin \ >> perl_local_config
echo INSTALLMAN1DIR=$HOME/perl5/man1 \ >> perl_local_config
echo INSTALLSITELIB=$HOME/perl5/lib >> perl_local_config
~~~

Now download the module you want to install, unzip it, and cd into the directory. E.g.:

~~~
wget https://cpan.metacpan.org/authors/id/A/AB/ABIGAIL/Acme-Time-Baby-2010090301.tar.gz
tar zxf Acme-Time-Baby-2010090301.tar.gz
cd Acme-Time-Baby-2010090301
~~~

Set up the installation by typing:

~~~
perl Makefile.PL `cat $HOME/perl_local_config`
make
make test
~~~

And if all tests pass successful, continue:

~~~
make install
~~~

If you have installed the babytime example from above, you can test if everything works fine by typing these two lines, one after another:

~~~
cpan Acme::Time::Baby
perl -MAcme::Time::Baby -E 'say babytime'
~~~

-----

Find more information on this topic here:

[link1](https://www.maketecheasier.com/install-perl-module-in-linux-without-root-permission/)

