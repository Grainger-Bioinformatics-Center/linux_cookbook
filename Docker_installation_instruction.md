# Work on Docker engine

Docker container is an environment  for complex pipeline that required a lot dependency and difficult to maintain. This is an instruction of using the docker system on Phoebe.
## Notice

The docker container currently include the REPET 3.0 and other complex pipelines for request. The container will be shared through all the users. Users must put a specific name for their project and move the data to their own folder under their account after finishing the analysis. Users will need to request the username and password for access.

## Test runs and install image for Docker system

**This need sudoer permission:**

 1.  Test runs after installation:
	
    sudo docker run hello-world

 2.  Download images (use REPET as an example):
	
    sudo docker pull urgi/docker_vre_aio:latest

List all the downloaded image:
	
    sudo docker image ls

 3.  Create the container for the image and forward for the port for login:
	
sudo docker run -p 222:22 --name repet -d urgi/docker_vre_aio

list all the created containers:
	
    sudo docker ps

 4.  Execute an interactive bash shell on the container:
	
    sudo docker exec -it repet bash

 5.  Stop the container:
	
    sudo docker stop repet

