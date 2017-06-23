FROM quay.io/opusvl/catalyst-dbic
MAINTAINER Alastair McGowan-Douglas <alastair.mcgowan@opusvl.com>

RUN /opt/perl5/bin/cpanm -M http://cpan.opusvl.com OpusVL::FB11 Starman

COPY entrypoint.pl /

RUN mkdir /opt/fb11 \
    && groupadd -r fb11 \
    && useradd --home /opt/fb11 -r -g fb11 fb11 \
    && chown -R fb11: /opt/fb11

ENV PERL5LIB /opt/fb11/lib/perl5

USER fb11

ENTRYPOINT [ "/entrypoint.pl" ]
