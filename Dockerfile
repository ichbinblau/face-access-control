FROM ubuntu:16.04

ARG http_proxy

ARG https_proxy

ENV http_proxy ${http_proxy}

ENV https_proxy ${https_proxy}

RUN echo $https_proxy

RUN echo $http_proxy

# Uncomment the two lines below if you wish to use an Ubuntu mirror repository
# that is closer to you (and hence faster). The 'sources.list' file inside the
# 'tools/docker/' folder is set to use one of Ubuntu's official mirror in Taiwan.
# You should update this file based on your own location. For a list of official
# Ubuntu mirror repositories, check out: https://launchpad.net/ubuntu/+archivemirrors
COPY sources.list /etc/apt
RUN rm /var/lib/apt/lists/* -vf

RUN apt-get clean && apt-get update

RUN apt-get install -y -q wget unzip git

WORKDIR /opt

# 1. Download the installation script for OpenCL
RUN wget -O install_OCL_driver2_sh.tgz https://software.intel.com/file/593325/download

RUN tar xf install_OCL_driver2_sh.tgz

RUN mkdir opencl-temp

RUN sh -c '/bin/echo -e "n" | ./install_OCL_driver2.sh install -y --workspace opencl-temp'

## Add user root to the video group
RUN usermod -a -G video root

# 2. Install OpenCV
COPY intel_cv_sdk_ubuntu_r2_2017.0.113.tgz /opt/intel_cv_sdk_ubuntu_r2_2017.0.113.tgz

RUN tar xaf intel_cv_sdk_ubuntu_r2_2017.0.113.tgz

WORKDIR /opt/intel_cv_sdk_ubuntu_r2_2017.0.113

COPY silent.cfg /opt/intel_cv_sdk_ubuntu_r2_2017.0.113/

RUN apt-get install -y cpio

RUN ./install.sh --cli-mode -s silent.cfg

# 3. Install Paho* MQTT* C client libraries dependencies
RUN apt-get install -y libssl-dev ffmpeg lsb-release

WORKDIR /opt

#RUN mkdir /opt/face-access-control

COPY face-access-control /opt/face-access-control/ 

WORKDIR /opt/face-access-control/cvservice

#RUN ["/bin/bash", "-c", "source /opt/intel/computer_vision_sdk_2017.0.113/bin/setupvars.sh"]

RUN mkdir build

WORKDIR /opt/face-access-control/cvservice/build

RUN /bin/bash -c "source /opt/intel/computer_vision_sdk_2017.0.113/bin/setupvars.sh; cmake .."

RUN /bin/bash -c "source /opt/intel/computer_vision_sdk_2017.0.113/bin/setupvars.sh; make"

ENV MQTT_SERVER 10.239.76.41:1883

ENV MQTT_CLIENT_ID cvservice

ENV FACE_DB ./defaultdb.xml

ENV FACE_IMAGES=../../webservice/server/node-server/public/profile/

ENV http_proxy ""

ENV https_proxy ""

#RUN cd .. & ffserver -f ./ffmpeg/server.conf

#CMD ["/bin/bash", "tail", "-f", "/dev/null"] 
