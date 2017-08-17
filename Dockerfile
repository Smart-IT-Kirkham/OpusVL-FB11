FROM quay.io/opusvl/perl-5.20-dev:master as build

RUN /opt/perl5/bin/cpanm Term::ReadKey HTML::FormFu Catalyst::Runtime DBIx::Class Devel::Confess
RUN /opt/perl5/bin/cpanm -M http://cpan.opusvl.com OpusVL::FB11 Starman

FROM quay.io/opusvl/perl-5.20:master as release
COPY --from=build /opt/perl5 /opt/perl5

COPY entrypoint.pl /

RUN useradd -m -U -b /opt fb11
ENV PERL5LIB /opt/fb11/lib/perl5

USER fb11
WORKDIR /opt/fb11

ENTRYPOINT [ "/entrypoint.pl" ]