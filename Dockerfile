FROM quay.io/opusvl/opusvl-perl-base:release-2 AS FB11

# Do some checks no point continuing otherwise

ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;
ARG gitrev
RUN if [ -z "$gitrev" ]; then echo "gitrev not provided"; exit 2; fi;
RUN echo "$gitrev" > /root/OpusVL-FB11-gitrev

# Poison path so we can use our version of perl
ENV PATH="/opt/perl5/bin:$PATH"

# Copy in vendor specific riles
COPY vendor/* /root/vendor/
RUN if [ "$(ls /root/vendor)" ]; then \
    cpanm /root/vendor/*.tar.gz \
    && rm -rf /root/vendor; \
fi

# HACK FOR BROKEN LIBS
RUN apt-get update \
    && apt-get -y install build-essential
RUN cpanm --installdeps DBIx::Class::DeploymentHandler::VersionStorage::WithSchema
RUN cpanm DBIx::Class::DeploymentHandler::VersionStorage::WithSchema \
    || cpanm -n DBIx::Class::DeploymentHandler::VersionStorage::WithSchema

# Finally install the FB11 tarball, use the OpusVL backing mirror
COPY OpusVL-FB11-$version.tar.gz .
RUN /opt/perl5/bin/cpanm -M http://cpan.opusvl.com ./OpusVL-FB11-$version.tar.gz \
    && rm ./OpusVL-FB11-$version.tar.gz

#
# Clean up the final image
#

FROM quay.io/opusvl/opusvl-perl-base:release-2 AS FB11-Final

RUN PATH="/opt/perl5/bin:$PATH" \
    && echo OpusVL-FB11@$version >> /version \
    && useradd -rs /bin/false fb11

COPY --from=FB11 /opt /opt

# We intentionally leave the USER as root, and drop privs in the entrypoint.
# This lets us (and derived images) run initialisation as root without having to
# worry about running the app as a privileged user
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/opt/perl5/bin/entrypoint" ]
