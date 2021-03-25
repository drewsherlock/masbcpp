# Pull base image
# based on - https://larrylisky.com/2016/11/03/point-cloud-library-on-ubuntu-16-04-lts/
FROM ubuntu:16.04
MAINTAINER Matt MacGillivray

# install prereqs
RUN apt-get update
RUN apt-get install -y software-properties-common
RUN apt-get update
RUN apt-get install -y git build-essential linux-libc-dev
RUN apt-get install -y cmake cmake-gui 
RUN apt-get install -y libusb-1.0-0-dev libusb-dev libudev-dev
RUN apt-get install -y mpi-default-dev openmpi-bin openmpi-common  
RUN apt-get install -y libflann1.8 libflann-dev
RUN apt-get install -y libeigen3-dev
RUN apt-get install -y libboost-all-dev
RUN apt-get install -y libvtk5.10-qt4 libvtk5.10 libvtk5-dev
RUN apt-get install -y libqhull* libgtest-dev
RUN apt-get install -y freeglut3-dev pkg-config
RUN apt-get install -y libxmu-dev libxi-dev 
RUN apt-get install -y mono-complete
RUN apt-get install -y qt-sdk openjdk-8-jdk openjdk-8-jre
RUN apt-get install -y openssh-client


# get pcl
RUN git clone https://github.com/PointCloudLibrary/pcl.git ~/pcl

# install pcl
RUN mkdir ~/pcl/release
RUN cd ~/pcl/release && cmake -DCMAKE_BUILD_TYPE=None -DCMAKE_INSTALL_PREFIX=/usr \
           -DBUILD_GPU=ON -DBUILD_apps=ON -DBUILD_examples=ON \
           -DCMAKE_INSTALL_PREFIX=/usr ~/pcl
RUN cd ~/pcl/release && make
RUN cd ~/pcl/release && make install


# install Anaconda
RUN apt-get install wget
RUN mkdir -p /tmp/stuff/Anaconda
RUN cd /tmp/stuff/Anaconda
RUN wget -c https://repo.continuum.io/archive/Anaconda3-2020.11-Linux-x86_64.sh
RUN bash Anaconda3-2020.11-Linux-x86_64.sh -b -p /opt/conda

# avoid kernel crashes.
ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD ["/opt/conda/bin/jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0", "--notebook-dir=/home/analytics/notebooks", "--allow-root"]

# Build masbcpp
#RUN \
#      cd /tmp/stuff && \
#      git clone https://github.com/drewsherlock/masbcpp.git && \
#      cd masbcpp && \
#      cmake . && \
#      make

# Build masbcpp
COPY . /tmp/stuff/masbcpp 
RUN cd /tmp/stuff/masbcpp && \
    cmake . && \
    make