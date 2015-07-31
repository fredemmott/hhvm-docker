FROM ubuntu:14.04

RUN apt-get update -y
RUN apt-get install -y software-properties-common
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0x5a16e7281be7a449
RUN add-apt-repository "deb http://dl.hhvm.com/ubuntu trusty main"
RUN apt-get update -y && apt-get install -y hhvm=3.8.0~trusty
