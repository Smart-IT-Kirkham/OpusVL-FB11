FROM quay.io/opusvl/opusvl-perl-base:release-1

RUN useradd -rs /bin/false fb11

COPY vendor/* /root/vendor/
RUN if [ "$(ls /root/vendor)" ]; then \
    cpanm /root/vendor/*.tar.gz \
    && rm -rf /root/vendor; \
fi

ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;
ARG gitrev
RUN if [ -z "$gitrev" ]; then echo "gitrev not provided"; exit 2; fi;

# Oops ... fix this
RUN cpanm -n DBIx::Class::DeploymentHandler::VersionStorage::WithSchema

RUN echo "$gitrev" > /root/OpusVL-FB11-gitrev

COPY OpusVL-FB11-$version.tar.gz .
RUN cpanm ./OpusVL-FB11-$version.tar.gz \
    && rm ./OpusVL-FB11-$version.tar.gz

RUN echo OpusVL-FB11@$version >> /version

ENV MEMORY_LIMIT 262144

# We intentionally leave the USER as root, and drop privs in the entrypoint.
# This lets us (and derived images) run initialisation as root without having to
# worry about running the app as a privileged user
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/opt/perl5/bin/entrypoint" ]
