ARG OS=debian
ARG VERSION=stable-slim

FROM $OS:$VERSION


# Set Env Variables
ENV TF_VERSION='1.2.9'
ENV TG_VERSION='0.29.10'


# Install Base Components
RUN apt-get -y update && \
     apt-get -y upgrade -y && \
     apt-get -y install wget curl git python3-pip build-essential


# Install awscli via Python Package Manager
RUN pip install awscli --ignore-installed six


# Install & Configure Brew
RUN git clone https://github.com/Homebrew/brew ~/.linuxbrew/Homebrew \
      && mkdir ~/.linuxbrew/bin \
      && ln -s ../Homebrew/bin/brew ~/.linuxbrew/bin \
      && eval $(~/.linuxbrew/bin/brew shellenv) \
      && brew install  \
        jq \
        yq \
        tfenv \
        tgenv \
        terramate \
        kubectl \
        helm \
        FairwindsOps/tap/pluto && \
        tfenv install $TF_VERSION && tfenv use $TF_VERSION && \
        tgenv install $TG_VERSION && tgenv use $TG_VERSION

ENV PATH=~/.linuxbrew/bin:~/.linuxbrew/sbin:$PATH

