FROM quay.io/opusvl/opusvl-perl-base:release-3 AS FB11

FROM FB11 AS FB11-layer0

# DEBT a hack to work around fact 'stable' has moved to buster but our base images haven't
RUN sed -i 's/stable/stretch/g' /etc/apt/sources.list
# Following is due to Permission Denied removing lockfiles - perhaps corrupted caches from parent image?
RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Re add in the neccesary packages for postgres
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ $(cat /etc/os-tag)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

#
# Add in development libraries
#

# Which postgres version are we targetting (add this to /etc)
ARG PG_VERSION=postgresql-server-dev-10

# Add Postgres
RUN apt-get update \
    && apt-get -y install build-essential libpq-dev postgresql-10
# Fix upstream fuckery
RUN ln -sf /usr/include/locale.h /usr/include/xlocale.h

# Do some checks no point continuing otherwise
# Do this after apt-get or we will never cache the apt-get
ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;
ARG gitrev
RUN if [ -z "$gitrev" ]; then echo "gitrev not provided"; exit 2; fi;

# Finally install the FB11 tarball, use the OpusVL backing mirror
# We CANNOT run the tests right now. Test::Postgresql58 REFUSES to run as root.
# Test::PostgreSQL itself seems to work fine as root but we are not given the
# option to use that.
# To run the tests as user we need a user whose home directory exists and can be
# written to by cpanm, (it wants /home/user/.cpanm)

# Until I fixed it :D ^
COPY OpusVL-FB11-$version.tar.gz .
RUN /opt/perl5/bin/cpanm --installdeps ./OpusVL-FB11-$version.tar.gz ||:

RUN useradd -rs /bin/false -d /tmp -g 0 testuser
RUN chmod -R 775 /opt
USER testuser
RUN /opt/perl5/bin/cpanm -M http://cpan.opusvl.com ./OpusVL-FB11-$version.tar.gz \
    || ( cat /tmp/.cpanm/work/*/build.log && exit 1 )

# Swap back to root incase we add anything else
USER root

#
# Clean up the final image
#

FROM FB11 AS FB11-Final

# Arguments
RUN echo "$gitrev" > /root/OpusVL-FB11-gitrev

# Poison path so we can use our version of perl
ENV PATH="/opt/perl5/bin:$PATH"

# Copy all the old opt to the new opt
COPY --from=FB11-layer0 /opt /opt

# Copy in vendor specific riles
COPY vendor/* /root/vendor/
RUN if [ "$(ls /root/vendor)" ]; then \
    /opt/perl5/bin/cpanm /root/vendor/*.tar.gz \
    && rm -rf /root/vendor; \
fi

# Echo the version to the root of the file system
RUN echo OpusVL-FB11@$version >> /version \
    && useradd -rs /bin/false fb11

# There is now a default PSGI you can rely on
ENV PSGI /opt/perl5/bin/fb11.psgi

# We intentionally leave the USER as root, and drop privs in the entrypoint.
# This lets us (and derived images) run initialisation as root without having to
# worry about running the app as a privileged user
ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/opt/perl5/bin/entrypoint" ]
