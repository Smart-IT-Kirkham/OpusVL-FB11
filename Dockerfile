FROM quay.io/opusvl/perl-dev:v5.26.2 as dbic-catalyst

ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com'

RUN apt-get update \
    && apt-get install -y postgresql-9.6 libpq-dev \
    && apt-get clean

ENV PATH "/opt/perl5/bin:$PATH"
RUN cpanm Module::Version

# ----- #
# FB11 is a framework, so aimed at developers, so its "release" is a development
# image
FROM quay.io/opusvl/perl-dev:v5.26.2 as release
COPY --from=dbic-catalyst /opt/perl5 /opt/perl5

COPY dumb-init_1.2.1_amd64 /usr/local/bin/dumb-init
RUN chmod +x /usr/local/bin/dumb-init

RUN useradd -rs /bin/false fb11

RUN apt-get update \
    && apt-get -y install libexpat1-dev libpq5 libssl-dev gosu \
    && apt-get clean \
    && gosu nobody true

ENV PATH "/opt/perl5/bin:$PATH"

ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com'

COPY vendor/* /root/vendor/
RUN if [ "$(ls /root/vendor)" ]; then \
    cpanm /root/vendor/*.tar.gz \
    && rm -rf /root/vendor; \
fi

ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;
ARG gitrev
RUN if [ -z "$gitrev" ]; then echo "gitrev not provided"; exit 2; fi;

RUN echo "$gitrev" > /root/OpusVL-FB11-gitrev

COPY OpusVL-FB11-$version.tar.gz .
RUN cpanm --notest Catalyst::Plugin::Static::Simple
RUN cpanm -n ./OpusVL-FB11-$version.tar.gz \
    && rm ./OpusVL-FB11-$version.tar.gz

RUN echo OpusVL-FB11@$version >> /version

ENV MEMORY_LIMIT 262144

# We intentionally leave the USER as root, and drop privs in the entrypoint.
# This lets us (and derived images) run initialisation as root without having to
# worry about running the app as a privileged user
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/opt/perl5/bin/entrypoint" ]
