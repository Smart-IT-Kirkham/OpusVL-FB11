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

    lives_ok { $p->update({ value => "Better value" }) } "No problem updating with update";
    lives_ok { $p->value("Better value"); $p->update } "No problem updating with column accessor";

}

{
    lives_ok {
        SysParam->set_default(
            'test::new.parameter',
            {
                value => "New parameter",
                label => "Testing new parameter",
                comment => "Should be created once",
                data_type => 'text',
            }
        )
    } "Set default lives OK";

    ok my $p = SysParam->find_by_name('test::new.parameter'), "Found new parameter";
    ok $p->value eq "New parameter", "Correct value";
    ok $p->comment eq "Should be created once", "Comment also matches";

    $p->update({value => "Updating parameter"});

    lives_ok {
        SysParam->set_default(
            'test::new.parameter',
            {
                value => "New parameter",
                label => "Testing new parameter",
                comment => "Should be created once",
                data_type => 'text',
            }
        )
    } "Set default again still lives OK";

    $p->discard_changes;
    ok $p->value eq "Updating parameter", "Setting default again didn't change anything";

    ok my $q = SysParam->find_by_name('test::new.parameter'), "Still can find new parameter";
    ok $q->value eq "Updating parameter", "Parameter in DB is still the updated value";
}

done_testing;
