# How to install QIIME2 on our linux server #
Version 0.2 (not tested - use at your own risk)

If not already done, you need to install Anaconda:
~~~
cd ~
wget https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh
bash Anaconda3-2021.05-Linux-x86_64.sh
source ~/.bashrc
~~~

Install QIIME with Anaconda:
~~~
cd ~/Downloads
wget https://data.qiime2.org/distro/core/qiime2-2021.4-py38-linux-conda.yml
conda env create -n qiime2-2021.4 --file qiime2-2021.4-py38-linux-conda.yml
~~~

Start QIIME by activating the QIIME environment:
~~~
conda activate qiime2-2021.4
~~~

Finish your work in QIIME by deactivating the QIIME environment:
~~~
conda deactivate
~~~
