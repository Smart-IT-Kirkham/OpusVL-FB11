FROM quay.io/opusvl/perl-5.20-dev:master as dbic-catalyst

ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com'

RUN apt-get update \
    && apt-get install -y postgresql-9.6 libpq-dev \
    && apt-get clean

ENV PATH "/opt/perl5/bin:$PATH"
RUN cpanm DBD::Pg

RUN /opt/perl5/bin/cpanm Term::ReadKey HTML::FormFu Catalyst::Runtime \
    DBIx::Class Devel::Confess DBD::Pg
RUN /opt/perl5/bin/cpanm JSON::XS Starman

# ----- #
# FB11 is a framework, so aimed at developers, so its "release" is a development
# image
FROM quay.io/opusvl/perl-5.20-dev:master as release
COPY --from=dbic-catalyst /opt/perl5 /opt/perl5

RUN apt-get update && apt-get -y install libexpat1-dev libpq5

ENV PATH "/opt/perl5/bin:$PATH"

ENV PERL_CPANM_OPT=' \
    --configure-timeout 84000 \
    --build-timeout 84000 \
    --test-timeout 84000 \
    --mirror http://cpan.opusvl.com'

ARG version
RUN if [ -z "$version" ]; then echo "Version not provided"; exit 1; fi;

COPY OpusVL-FB11-$version.tar.gz .
RUN cpanm --notest Catalyst::Plugin::Static::Simple
RUN cpanm ./OpusVL-FB11-$version.tar.gz \
    && rm ./OpusVL-FB11-$version.tar.gz

ENTRYPOINT [ "/opt/perl5/bin/entrypoint" ]
