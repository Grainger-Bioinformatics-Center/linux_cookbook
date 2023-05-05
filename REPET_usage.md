\# REPET usage

This is instruction for REPET usage for transposable elements (TEs) annotation and classification.

 

\## TEdenovo

The TEdenovo is used for 8 steps for the repeats locate and clustering using the DmelChr4 as an example.

 

\### Preparing the config file and genome fasta sequence

 

1. Create a directory with config files

 

  mkdir DmelChr4_TEdenovo

  cd DmelChr4_TEdenovo

  ln -s $REPET_PATH/db/DmelChr4.fa

  cp $REPET_PATH/config/TEdenovo.cfg



2. Config file settings

Open the TEdenovo.cfg and change the settings as follow

​        

  [repet_env]

  repet_version: 3.0

  repet_host: localhost

  repet_user: orepet

  repet_pw: repet_pw

  repet_db: repet

  repet_port: 3306

  repet_job_manager: slurm

 

  [project]

  project_name: DmelChr4

  project_dir: /home/centos/DmelChr4_TEdenovo



\### Step 1 Cut genome into pieces

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 1

 

\### Step 2 Align genome to itself using Blast

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 2 -s Blaster

 

\### Step 3 High-scoring segment pairs clustering using Recon, Grouper and/or Piler

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 3 -s Blaster -c Recon

​      

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 3 -s Blaster -c Grouper

​      

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 3 -s Blaster -c Piler

 

\### Step 4 Align genome to itself using Blast

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 2 -s Blaster

 

\### Step 5 Feature detection by similarity

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 5 -s Blaster -c GrpRecPil -m Map

 

\### Step 6 Classifies the consensus according to their features

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 6 -s Blaster -c GrpRecPil -m Map

 

\### Step 7 Classifie the consensus according to their features

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 6 -s Blaster -c GrpRecPil -m Map

 

\### Step 8 Clustere the consensus into families

​        

  TEdenovo.py -P DmelChr4 -C TEdenovo.cfg -S 8 -s Blaster -c GrpRecPil -m Map -f Blastclust