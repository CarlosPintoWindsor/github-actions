FROM katalonstudio/katalon:latest

# common environment variables
ARG KATALON_ROOT_DIR=/katalon
ARG KATALON_BASE_ROOT_DIR=$KATALON_ROOT_DIR/base
ENV KATALON_VERSION_FILE=$KATALON_ROOT_DIR/version
ENV KATALON_SOFTWARE_DIR=/opt

ARG KATALON_KATALON_SCRIPT_DIR=$KATALON_ROOT_DIR/scripts
ENV PATH "$PATH:$KATALON_KATALON_SCRIPT_DIR"
ENV KATALON_KATALON_ROOT_DIR=$KATALON_ROOT_DIR/katalon

ARG CHROMEDRIVER_VERSION

# Copy "wrap_chrome_binary" script
WORKDIR $KATALON_BASE_ROOT_DIR
COPY ./katalon-docker-scripts/wrap_chrome_binary.sh wrap_chrome_binary.sh
RUN chmod a+x wrap_chrome_binary.sh

# Copy script to install Chrome
WORKDIR $KATALON_KATALON_SCRIPT_DIR
COPY ./katalon-docker-scripts/setup.sh setup.sh
RUN chmod a+x setup.sh

# Main setup
# -> install chrome browser
# -> install chrome driver
RUN $KATALON_KATALON_SCRIPT_DIR/setup.sh

# set work directory at /
WORKDIR /