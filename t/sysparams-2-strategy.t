#!perl

use v5.24;
use Test::Most;
use Test::DBIx::Class -config_path => [qw/t etc sysparams/], qw/SysParam/;
use OpusVL::SysParams::Strategy::Namespaced;

fixtures_ok 'some_params';

my $strat = OpusVL::SysParams::Strategy::Namespaced->new({
    schema => Schema,
    namespace => 'test::namespace',
});

my $p = $strat->value_of('array');
ok $p, "Found value";
ok $p->@* == 2, "Correctly deserialised";

reset_schema;

# TODO: management strat
done_testing;
