use strict;
use Test::More;
use TestApp;
use Test::WWW::Mechanize::PSGI;

TestApp->setup_engine('PSGI');
my $app = sub { TestApp->run(@_) };

my $mech = Test::WWW::Mechanize::PSGI->new( app => $app );
$mech->get_ok('/');

my $mech2 = Test::WWW::Mechanize::PSGI->new( app => $app );
$mech2->get_ok('/');
$DB::single = 1;

done_testing;
