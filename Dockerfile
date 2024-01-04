#FROM registry.smart-ltd.co.uk/bca/opusvl-perl-base:release-3 AS fb11
FROM registry.smart-ltd.co.uk/bca/base-perl-5.38:20240104-095518 AS fb11

FROM fb11 AS fb11-layer0

#ENV PERL_CPANM_OPT "--mirror http://www.opusvl.com --mirror-only"

ENV DEBIAN_FRONTEND=noninteractive

#
# Update the Base OS as far as possible
#

#COPY sources.list /etc/apt/sources.list
#RUN rm /etc/apt/sources.list.d/pgdg.list
#    # ^ Chicken and egg - to use the pgdg.list we need apt-transport-https
#RUN :\
#    && apt-get update \
#    && apt-get -y install apt-transport-https \
#    && apt-get clean
#COPY pgdg.list /etc/apt/sources.list.d/pgdg.list
#
#RUN apt-get -y clean \
#    && apt-get -y update \
#    && apt-get -y upgrade \
#    && apt-get -y dist-upgrade

# # Target buster rather than stretch
# RUN sed -i 's/stretch/buster/g' /etc/apt/sources.list \
#     && echo "buster" > /etc/os-tag

# # Following is due to Permission Denied removing lockfiles - perhaps corrupted caches from parent image?
# RUN rm -rf /var/lib/apt/lists /var/cache/apt/archives

# # Re add in the neccesary packages for postgres
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN : \
    && wget --quiet -O- https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor --yes --output /etc/apt/trusted.gpg.d/pgdg.gpg \
    && :


#ADD pgdg.list /etc/apt/sources.list.d/pgdg.list

#
# Add in development libraries
#

# Which postgres version are we targetting (add this to /etc)
ARG PG_VERSION=postgresql-server-dev-10

# Add Postgres
RUN apt-get -y clean \
    && apt-get -y update \
    && apt-get -y upgrade \
    #&& apt-get -y install aptitude \
    && apt-get -y install build-essential libpq-dev postgresql-10

# Do some checks no point continuing otherwise
# Do this after apt-get or we will never cache the apt-get
ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;
ARG gitrev
RUN if [ -z "$gitrev" ]; then echo "gitrev not provided"; exit 2; fi;


# Install build dependencies for Perl C modules
# libexpat1-dev needed by XML::Parser
RUN : \
    && apt-get update \
    && apt-get -y install build-essential libexpat1-dev \
    && apt-get -y clean


#
# Base libs required to test postgresql (special case)
#

# Lets make this install and test correctly (Add in the base requirements for 
# Test Postgresql)
RUN /opt/perl5/bin/cpanm Class::Accessor::Lite DBI File::Temp Cwd POSIX DBD::Pg

# We have to set more leniant permissiones for this one ...
RUN chmod -R 775 /opt

# Copy in the latest fb11
COPY OpusVL-FB11-$version.tar.gz .

# Now lets create a test user for this stupid module
RUN useradd -rs /bin/false -d /tmp -g 0 testuser
USER testuser
ENV USER=testuser

# And this should work, or I am going to hunt down coli...
RUN /opt/perl5/bin/cpanm Test::Postgresql58

# Install flexibase
# Needs -Mhttps://cpan.opusvl.com because of (at least) OpusVL::DBIC::Helper

# Install all deps first (for testing, may not be required)
RUN /opt/perl5/bin/cpanm -Mhttps://cpan.opusvl.com --installdeps ./OpusVL-FB11-$version.tar.gz \
    || ( >&2 cat /tmp/.cpanm/work/*/build.log && exit 1 )

# Install install the end product
RUN /opt/perl5/bin/cpanm -Mhttps://cpan.opusvl.com ./OpusVL-FB11-$version.tar.gz \
    || ( >&2 cat /tmp/.cpanm/work/*/build.log && exit 1 )

# Now lets tidy up
USER root
ENV USER=root
RUN userdel testuser



#
# Clean up the final image
#

# FROM fb11 AS fb11-final

# Arguments
RUN echo "$gitrev" > /root/OpusVL-FB11-gitrev

# Poison path so we can use our version of perl
ENV PATH="/opt/perl5/bin:$PATH"

# Copy all the old opt to the new opt
# COPY --from=fb11-layer0 /opt /opt

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
#ENTRYPOINT [ "/usr/local/bin/dumb-init", "--", "/opt/perl5/bin/entrypoint" ]
ENTRYPOINT ["/opt/perl5/bin/entrypoint"]
