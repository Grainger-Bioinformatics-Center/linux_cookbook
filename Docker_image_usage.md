# Docker image usage (use REPET as an example)

This instruction is to show the usage of Docker image for the complex tools which has lots of dependency issues.

## Installation of the docker image

This include the download of the image and build up image container. The image is usually very large and occupied a lot of disk space. The image downloading and container creating usually needs sudoer permission. Please contact Felix or Yukun for help for the downloading and disk space management.

### Download the image

**Download the image with current version (REPET v3.0):**
	
    docker pull urgi/docker_vre_aio:latest

**Download the image with specific version (REPET v2.5):**
	
    docker pull urgi/docker_vre_aio:v2.5

### List and check all the downloaded image
	
    docker image ls

### Create a container from the image and forward port for SSH link

**Forward the port 22 to 222 to enable the SSH connection from user to container:**
	
    docker run -p 222:22 --name test -d urgi/docker_vre_aio

## Usage of the REPET image

This include the connection to the Docker container using the REPET as an example

### Connect with the Docker container with the preset username of centos

**Connect with bash shall via SSH:**
	
    ssh -p 222 centos@localhost

**Ask for the storage of RSA key and default password "centos":**

**Connect with bash shall via SSH:**
> The authenticity of host \'[localhost]:222 ([127.0.0.1]:222)\' can\'t be established.
RSA key fingerprint is SHA256:0CBOfQGRiAo5+cH5C3EK8IlXgqDgYFveg+wWyceTTEk.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added \'[localhost]:222\' (RSA) to the list of known hosts.
centos@localhost\'s password:
	
### List running containers for checking

    docker ps

### To stop the container
	
    docker stop repet

