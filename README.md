# hitdevenv

Environment to build war files for hit tools.

NIST is providing this procedure in order to allow external collaborators to build their own iztool.war file.
The build is based on all required github repositories (the latest and up to date).

We assume that docker is already installed. If not, please go to https://docs.docker.com/install/ .

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

In order to use the iztool.war file, we create a container based on the freshly build image, and copy the war file to the parent directory.
```bash
docker create -ti --name iz-tool hit-iz-tool-himss bash
docker cp iz-tool:/root/hit-iz-tool/hit-iz-web/target/iztool.war ../hit-iz-tool-himss.war
docker rm iz-tool
```
