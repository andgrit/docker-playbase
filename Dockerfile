FROM ubuntu:14.04
MAINTAINER Powell Quiring <powellquiring@gmail.com>

ADD control.sh /play/control.sh
WORKDIR /play

ENTRYPOINT ["/play/control.sh"]

# Expose Code volume and play ports 9000 default 9999 debug 8888 activator ui
EXPOSE 9000
EXPOSE 9999
EXPOSE 8888

# change this default version if needed:
ENV ACTIVATOR_VERSION 1.3.2


#################################################################################################
# Children of this image (FROM thisImage) use this as follows:
#FROM andgrit/playbase

#ENV ACTIVATOR_VERSION 1.3.3
# doubtful you will need to change this version

#ENV PLAY_REPOSITORY https://github.com/YOURREPOSITORY
# specify the git repo that holds your play code

#RUN /play/control.sh dist
# build your layer.  The build script supports one of the parameters:
# dist - create a play distribution docker image. Make it small as possible
# test - run the tests
#
# this can take a long time to prepare a play environment, compile your code, and clean up.
# more docs are in the control.sh script

# Then docker run, maybe: docker run -d -p 80:9000 yourimage
# or pass the parameters: "-- whatever" typically something like: docker run -it yourimage -- bash

# Notes:
## do not change the WORKDIR it will contain your play application

#################################################################################################
# example:
#
#FROM andgrit/playbase
#ENV PLAY_REPOSITORY https://github.com/andgrit/estimate.git
#RUN /play/control.sh dist
