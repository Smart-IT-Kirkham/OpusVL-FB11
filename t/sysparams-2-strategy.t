#!perl

use v5.24;
use Test::Most;
use Test::DBIx::Class -config_path => [qw/t etc sysparams/], qw/SysParam/;
use OpusVL::SysParams::Strategy::Namespaced;
use OpusVL::SysParams::Manager::Namespaced;

fixtures_ok 'some_params';

my $strat = OpusVL::SysParams::Strategy::Namespaced->new({
    schema => Schema,
    namespace => 'test::namespace',
});

my $p = $strat->value_of('array');
ok $p, "Found value";
ok $p->@* == 2, "Correctly deserialised";

my $m_strat = OpusVL::SysParams::Manager::Namespaced->new({
    schema => Schema,
    namespace => 'test::namespace'
});

{
    my $new_val = [ qw/more than two values/ ];
    lives_ok { $m_strat->set_value('array', $new_val) } "Successfully set value";
    eq_or_diff scalar $strat->value_of('array'), $new_val, "Stored successfully";
}

{
    my $new_param = {
        name => 'new.test.value',
        value => 'simple string',
        metadata => {
            label => "New test value",
            data_type => 'text',
        }
    };

    my $expected_metadata = {
        $new_param->{metadata}->%*,
        comment => undef,
    };

    lives_ok {
        $m_strat->set_default( $new_param->@{qw/name value metadata/} )
    } "Set new default";
    eq_or_diff scalar $strat->value_of('new.test.value'), $new_param->{value}, "Correctly set";
    eq_or_diff scalar $m_strat->metadata_for($new_param->{name}), $expected_metadata, "Metadata created correctly";

    my $updated_value = "Better value";
    lives_ok {
        $m_strat->set_value($new_param->{name}, $updated_value)
    } "Set new value";
    eq_or_diff scalar $strat->value_of($new_param->{name}), $updated_value, "Correctly set";

    lives_ok {
        $m_strat->set_default( $new_param->@{qw/name value metadata/} )
    } "Set same default";
    eq_or_diff scalar $strat->value_of($new_param->{name}), $updated_value, "Default didn't change value";

    eq_or_diff scalar $strat->value_of('array'), $m_strat->value_of('array'), "Both strats return same value_of";
}

done_testing;
