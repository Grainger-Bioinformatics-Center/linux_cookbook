# GPU server usage

Our GBC center have a GPU server called Chandler, which is dedicate to task like AI training, BEAGLE library, etc. This server is only available by application, please contact Yukun Sun (ysun@fieldmuseum.org) if you are interested to use it.

## Why we want to use GPU server? 

A GPU can complete simple and repetitive tasks much faster because it can break the task down into smaller components and finish them in parallel.

## Basic configuration of Chandler:

72 cores @ 2.20 GHz 
256 GB RAM 
6.9 TB hard disk 
4 Nvidia RTX A5000    

## More efficient way to use it:
    
The GPU 0 and 1 and GPU 2 and 3 are nv-linked, respectively. So, the best way to use is to max out one unit of the GPU for cores or memory. For example:

    GPU0 			100% usage
    GPU0 and 1 		100% usage
    GPU2 and 3 		100% usage
    GPU0, 1 and 2 	100% usage
    GPU0, 2 and 3 	100% usage
    GPU1, 2 and 3 	100% usage

    ### common usage for programs using Nvidia driver
    
    export CUDA_VISIBLE_DEVICES=X (X can be one or more of 0,1,2,3)


## Ways to check for GPU usage before running any program:

    1) (h)top like task monitor for GPUs and accelerators:

    nvtop

    2) System Management Interface SMI (utility allows administrators to query GPU device state):

    nvidia-smi
    nvidia-smi topo -m (check for the link method between GPUs)
