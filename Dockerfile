ARG TAG
FROM continuumio/miniconda3

USER root
RUN  apt-get update && apt install libgl1-mesa-glx --yes

RUN conda update conda
RUN conda config --append channels conda-forge
RUN conda install "python>=3.7" pip

ADD requirements.txt /home

WORKDIR /home

# install packages here
# install packages necessary for celery and dask.
RUN pip install -r requirements.txt
RUN conda install -c conda-forge lz4

ARG TITLE
ARG OWNER
ARG REPO_URL
ARG RAW_REPO_URL
ARG BRANCH=master

# Install necessary packages, copying files, etc.
######################
# Bump to trigger build
ARG BUILD_NUM=0

ADD ${RAW_REPO_URL}/${BRANCH}/cs-config/install.sh /home
RUN cat /home/install.sh
RUN bash /home/install.sh

# Bump to trigger re-install of source, without re-installing dependencies.
ARG INSTALL_NUM=0
RUN pip install "git+${REPO_URL}.git@${BRANCH}#egg=cs-config&subdirectory=cs-config"
ADD ${RAW_REPO_URL}/${BRANCH}/cs-config/cs_config/tests/test_functions.py /home
RUN pip install cs-kit
######################

RUN mkdir /home/cs_publish
COPY cs_publish /home/cs_publish
COPY setup.py /home
RUN cd /home/ && pip install -e .

WORKDIR /home

COPY scripts/celery_sim.sh /home
COPY scripts/celery_io.sh /home