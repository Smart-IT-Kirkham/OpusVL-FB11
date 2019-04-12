#!perl

use v5.24;
use strict;
use warnings;
use Test::Most;

use Test::DBIx::Class -config_path => [qw/t etc sysparams/], qw/SysParam/;

fixtures_ok 'some_params';

{
    ok my $p = SysParam->find_by_name('test::namespace::value'), "Found parameter by FQN";

    ok $p->value eq 'test value', "Test value deserialised correctly";
}

{
    my $ns = SysParam->with_namespace('test::namespace');
    ok my $p = $ns->find_by_name('value'), "Found parameter with predefined namespace";
    ok $p->value eq 'test value', "Test value deserialised correctly";

    ok my $arr_p = $ns->find_by_name('array'), "Found array parameter";
    ok $arr_p->value->@* == 2, "Deserialised two items correctly";
}

{
    my $ns = SysParam->with_namespace;
    ok my $p = $ns->find_by_name('root.value'), "Found value in root namespace";
    ok $p->value eq 'root value', "Found correct value";
}

done_testing;
