FROM quay.io/opusvl/catalyst-dbic
MAINTAINER Alastair McGowan-Douglas <alastair.mcgowan@opusvl.com>

COPY docker-local-libs /
RUN /opt/perl5/bin/cpanm -M http://cpan.opusvl.com OpusVL::FB11
