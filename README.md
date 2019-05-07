# HIT IZ TOOL

Environment to build war files for hit tools.

NIST is providing this procedure in order to allow external collaborators to build their own iztool.war file.
The build is based on all required github repositories (the latest and up to date).

We assume that docker is already installed. If not, please go to https://docs.docker.com/install/ .
As long as docker is installed and working, it does not matter which Operating System is being used.

Also, remember the path of the directory you are in now. After you have followed the instructions, you will have the war file in the parent directory.
To build the docker image:

Go the folder hit-iz-tool-himss
```bash
cd hit-iz-tool-himss
```

Now, we can build the docker container.
```bash
docker build -t hit-iz-tool-himss .
```
The . at the end is important.
It takes **some time** to build the docker image.

In order to use the iztool.war file, we create a container based on the freshly build image, and copy the war file to the parent directory.
```bash
docker create -ti --name iz-tool hit-iz-tool-himss bash
docker cp iz-tool:/root/hit-iz-tool/hit-iz-web/target/iztool.war ../hit-iz-tool-himss.war
docker rm iz-tool
```
The docker image name is *hit-iz-tool-himss*. It is given at the build time.
The container image is *iz-tool*. It is given when we create an instance of the image, aka a container, in order to go inside and retrieve the war file.
We destroy the container at the end of the procedeure, but the image is still available. You can check by running :
```bash
docker images
```
 
