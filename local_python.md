# How to install python modules locally #
Version 0.1 (not tested - use at your own risk)

It may be required for you to install python modules locally as you don't have administrative rights on any of the servers at the Field Museum. To use this modules you have to create a virtual environment. 

## Creating Virtual Environments ##

Create the virtual environment within a folder:
~~~
virtualenv <my_project>
~~~

Start the virtual environment:
~~~
source <my_project>/bin/activate
~~~

Within this environment you can install modules:
~~~
pip install <my_module>
~~~

When you're done, you can stop the virtual environment with:
~~~
deactivate
~~~


-----

Find more information on this topic here:

[link1](https://packaging.python.org/tutorials/installing-packages/#)

