#!perl

use v5.24;
use strict;
use warnings;
no warnings 'experimental::signatures';;

use OpusVL::SysParams;
use OpusVL::SysParams::Reader;
use OpusVL::SysParams::Manager::Namespaced;

use Test::Most;
use Test::DBIx::Class -config_path => [qw/t etc sysparams/], qw/SysParam/;

fixtures_ok 'some_params';

my $manager = OpusVL::SysParams::Manager::Namespaced->new({
    schema => Schema,
    namespace => 'test::namespace'
});

my $strat = OpusVL::SysParams::Reader->new({
    manager => $manager
});

my $p = $strat->value_of('array');
ok $p, "Found value";
ok $p->@* == 2, "Correctly deserialised";

{
    my $new_val = [ qw/more than two values/ ];
    lives_ok { $manager->set_value('array', $new_val) } "Successfully set value";
    eq_or_diff scalar $strat->value_of('array'), $new_val, "Stored successfully";
}

{
    my $new_param = {
        name => 'new.test.value',
        value => 'simple string',
        metadata => {
            label => "New test value",
            data_type => {
                type => 'text',
            }
        }
    };

    my $expected_metadata = {
        $new_param->{metadata}->%*,
        comment => undef,
    };

    lives_ok {
        $manager->set_default( $new_param->@{qw/name value metadata/} )
    } "Set new default";
    eq_or_diff scalar $strat->value_of('new.test.value'), $new_param->{value}, "Correctly set";
    eq_or_diff scalar $manager->metadata_for($new_param->{name}), $expected_metadata, "Metadata created correctly";

    my $updated_value = "Better value";
    lives_ok {
        $manager->set_value($new_param->{name}, $updated_value)
    } "Set new value";
    eq_or_diff scalar $strat->value_of($new_param->{name}), $updated_value, "Correctly set";

    lives_ok {
        $manager->set_default( $new_param->@{qw/name value metadata/} )
    } "Set same default";
    eq_or_diff scalar $strat->value_of($new_param->{name}), $updated_value, "Default didn't change value";

    eq_or_diff scalar $strat->value_of('array'), $manager->value_of('array'), "Both strats return same value_of";
}


eq_or_diff [$manager->all_params], [ 'array', 'new.test.value', 'value', ], "Correct names returned from all_params";
eq_or_diff [$manager->all_params_fulldata], [
    {
        name => 'array',
        label => "Test/Namespace/Array",
        data_type => {
            type => 'text'
        },
        value => [ qw/more than two values/ ],
        comment => undef,
    },
    {
        name => 'new.test.value',
        label => "New test value",
        data_type => {
            type => 'text'
        },
        value => "Better value",
        comment => undef,
    },
    {
        name => 'value',
        label => "Test/Namespace/Value",
        data_type => {
            type => 'text'
        },
        value => 'test value',
        comment => undef,
    },
], "Correct full data";
done_testing;
