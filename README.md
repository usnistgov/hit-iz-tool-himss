# BUILDING HIT IZ TOOL

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
docker cp iz-tool:/root/hit-iz-tool/hit-iz-web/target/iztool.war ../iztool.war
docker rm iz-tool
```
The docker image name is *hit-iz-tool-himss*. It is given at the build time.
The container image is *iz-tool*. It is given when we create an instance of the image, aka a container, in order to go inside and retrieve the war file.
We destroy the container at the end of the procedeure, but the image is still available. You can check by running :
```bash
docker images
```
# DEPLOYING HIT IZ TOOL

To deploy the new war file :

- `git clone https://github.com/usnistgov/hit-base-tool-deploy.git`
- `cd hit-base-tool-deploy`
##### iztool-cni
1) Switch to the `iztool-cni` branch
- `git checkout iztool-cni`
2) Remove old db files to ensure new resource bundle data will be loaded
- `rm -r ./data/app/db`
3) copy the new generated iztool.war file to container-config/hit-base-tool/app/ . Please provide the full path of the freshly generated iztool.war
- `cp iztool.war container-config/hit-base-tool/app/`
Make sure that the name of the war file is **iztool.war**.
4) build the hit-base-tool
- `cd container-config/hit-base-tool/app`
In order to make use of the new iztool.war file, we need to modify the dockerfile such as:
Make sure that the line *COPY ./iztool.war /opt/tomcat/webapps/hit-base-tool.war* is **NOT** commented out.
And that the line ~~RUN wget --quiet --no-cookies https://hit-2015.nist.gov/wars/iztool-cdc.war -O /opt/tomcat/webapps/hit-base-tool.war~~ is commented out.

```Dockerfile
# Pull base image.
FROM tomcat-base
COPY ./config/context.xml /opt/tomcat/conf/

# RUN wget --quiet --no-cookies https://hit-2015.nist.gov/wars/iztool-cdc.war -O /opt/tomcat/webapps/hit-base-tool.war
COPY ./iztool.war /opt/tomcat/webapps/hit-base-tool.war
#RUN mkdir /opt/data/
#RUN chmod 766 /opt/data
#COPY ./config/app-log4j.properties /opt/data/
ENV HIT_LOGGING_DIR /opt/data/logs/
ENV HIT_LOGGING_CONFIG /opt/data/config/app-log4j.properties
ENV RELOAD_DB true
ENV URL_SCHEME https

VOLUME ["/opt/data/","/opt/tomcat/logs/"]

CMD ["/opt/tomcat/bin/catalina.sh", "run"]

```
 - `docker build -t hit-base-tool .`


3) Starts the containers
Go back to the directory where we can deploy. It is two levels up.
 - `cd container-config`
 - `./deploy.sh`
4) Access the tool at https://localhost/
