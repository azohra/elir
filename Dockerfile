# Latest version of Erlang-based Elixir
# FROM bitwalker/alpine-elixir:1.5.1

FROM ubuntu:latest
MAINTAINER Florin Patrascu <florin.patrascu@gmail.com>

RUN apt-get update -q && apt-get install -y build-essential git wget curl autoconf locales unzip libssl-dev libreadline-dev libncurses5-dev zlib1g-dev

ENV LANG en_US.UTF-8
# Set the locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8 

RUN adduser --shell /bin/bash --home /asdf --disabled-password asdf
ENV PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin"

USER asdf
WORKDIR /asdf

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.bashrc && \
    echo '. $HOME/.asdf/asdf.sh' >> $HOME/.profile

RUN asdf update --head

RUN asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
RUN asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git
RUN asdf plugin-add ruby https://github.com/asdf-vm/asdf-ruby.git

RUN asdf install erlang 20.0
RUN asdf install elixir 1.5.1
RUN asdf install ruby 2.4.2

RUN asdf global erlang 20.0
RUN asdf global elixir 1.5.1
RUN asdf global ruby 2.4.2

RUN gem install bundler
RUN gem install rspec

# RUN echo 'export LANG="en_US.UTF-8"' >> $HOME/.bashrc && \
#     echo 'export LC_CTYPE="en_US.UTF-8"' >> $HOME/.bashrc

# Elir
# ----------------------
RUN echo $ELIXIR_VERSION

RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix hex.info

VOLUME ["/asdf/test_dir"]
# RUN mkdir elir

ADD . elir
ENV MIX_ENV prod

WORKDIR /asdf/elir

# Copy all application files
COPY . .
USER root

RUN chown -R asdf:asdf /asdf/elir
# CMD chown asdf:asdf -R /asdf/elir

# Compile the entire project
RUN mix deps.get --only prod
RUN mix deps.compile
RUN mix compile
RUN mix escript.build

USER asdf