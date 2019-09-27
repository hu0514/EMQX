From centos

ENV ER_LANG=/usr/local/erlang/bin
ENV PATH=$PATH:$ER_LANG

ARG EMQX_VERSIONS=v3.2.0

RUN yum install gcc gcc-c++ glibc-devel make ncurses-devel openssl-devel xmlto perl git wget vim unzip -y \
    && cd /mnt \
    && wget http://erlang.org/download/otp_src_22.1.tar.gz \
    && tar zxvf otp_src_22.1.tar.gz \
    && cd otp_src_22.1 \
    && ./configure --prefix=/usr/local/erlang \
    && make && make install \
    && cd /mnt \
    #&& git clone https://github.com/emqx/emqx-rel.git emqx-rel \
    #&& cd emqx-rel \
    && wget https://s3.amazonaws.com/rebar3/rebar3 \
    && chmod +x rebar3 && mv rebar3 /usr/bin/ \
    && git clone -b ${EMQX_VERSIONS} https://github.com/emqx/emqx-rel.git \
    && cd emqx-rel && make \
    && cp -r _build/emqx/rel/emqx /usr/local/ \
    && ln -s /usr/local/emqx/bin/* /usr/bin \
    && yum clean all && rm -rf /mnt/*
#ENV ER_LANG=/usr/local/erlang/bin
#ENV PATH=$PATH:$ER_LANG
COPY ./files/setup.sh /tmp/setup.sh
COPY ./files/start.sh /tmp/start.sh
RUN chmod +x /tmp/setup.sh \
    && chmod +x /tmp/start.sh
ENTRYPOINT ["/tmp/setup.sh"]
CMD ["/tmp/start.sh"]
