#!perl

use v5.24;
use OpusVL::FB11::Hive;
use OpusVL::ObjectParams::Adapter::Static;
use Test::DBIx::Class -config_path => [qw/t etc objectparams/], qw/Storage/;
use Test::Most 'no_plan';

my $hive = "OpusVL::FB11::Hive";

lives_ok {
    $hive->configure({
        brains => [
            {
                class => 'OpusVL::ObjectParams',
                constructor => {
                    schema => Schema
                }
            },
            {
                class => 'Test::Extendee'
            },
            {
                class => 'Test::Extender1'
            },
            {
                class => 'Test::Extender2'
            },
        ],
        services => {
            objectparams => {
                brain => 'objectparams'
            }
        }
    })
} "Configure Hive";

my $service;
lives_ok { $service = $hive->service('objectparams') } "Fetch objectparams service";

my $schemas = $service->get_schemas_for(type => 'test-extendee::test-object');

is_deeply $schemas, {
    'test-extender-1' => {
        'x-schema-name' => "Test Extender 1",
        properties => { test => {} }
    }
}, "Found expected schema";

subtest Saving => sub {
    my $adapter = OpusVL::ObjectParams::Adapter::Static->new(
        id => { id => 1 }, # Remember all identifiers are objects
        type => 'test-extendee::test-object'
    );

    my $params = $service->get_parameters_for(object => $adapter, extender => 'test-extender-1');
    is $params, undef, "No params yet";

    subtest "Returned zero values" => sub {
        my @params = $service->get_parameters_for(object => $adapter, extender => 'test-extender-1');
        is scalar @params, 0, "Didn't return a scalar undef";
    };

    throws_ok {
        $service->set_parameters_for(
            object => $adapter,
            extender => 'test-extender-1',
            parameters => { missing => 'parameter' }
        );
    } 'failure::objectparams::extender::field_not_in_schema', "Cannot set parameter not defined on schema.";

    lives_ok {
        $service->set_parameters_for(
            object => $adapter,
            extender => 'test-extender-1',
            parameters => { test => 'parameter' }
        );
    } "Successfully set params";

    # Resultset from Test::DBIx::Class
    is Storage->count, 1, "In storage";
    $params = $service->get_parameters_for(object => $adapter, extender => 'test-extender-1');
    is_deeply $params, { test => 'parameter' }, "Stored parameter";
};

subtest Searching => sub {
    my @results = $service->search_by_parameters(
        type => 'test-extendee::test-object',
        simple => {
            'test-extender-1::test' => 'not found'
        }
    );

    is scalar @results, 0, "Found no objects";

    @results = $service->search_by_parameters(
        type => 'test-extendee::test-object',
        simple => {
            'test-extender-1::test' => 'parameter'
        }
    );

    is_deeply \@results, [
        {
            object_identifier => { id => 1 },
            object_type => 'test-extendee::test-object'
        }
    ], "Got a list of object IDs";
};

BEGIN {
    package Test::Extendee {
        use Moose;
        with 'OpusVL::FB11::Role::Brain';

        sub hats { 'objectparams::extendee' }

        sub short_name { 'test-extendee' }
    }

    package Test::Extendee::Hat::objectparams::extendee {
        use Moose;
        with 'OpusVL::ObjectParams::Role::Hat::objectparams::extendee';

        # There is no real object to extend but that's OK
        sub extendee_spec {
            {
                'test-extendee::test-object' => {
                    identifiable => 'data'
                }
            }
        }
    }

    package Test::Extender1 {
        use Moose;
        with 'OpusVL::FB11::Role::Brain';

        sub hats { 'objectparams::extender' }

        sub short_name { 'test-extender-1' }
    }

    package Test::Extender1::Hat::objectparams::extender {
        use Moose;
        with 'OpusVL::ObjectParams::Role::Hat::objectparams::extender';

        sub schemas {
            'test-extendee::test-object' => {
                'x-schema-name' => "Test Extender 1",
                properties => {
                    test => {}
                }
            }
        }
    }

    package Test::Extender2 {
        use Moose;
        with 'OpusVL::FB11::Role::Brain';

        sub hats { 'objectparams::extender' }

        sub short_name { 'test-extender-2' }
    }

    package Test::Extender2::Hat::objectparams::extender {
        use Moose;
        with 'OpusVL::ObjectParams::Role::Hat::objectparams::extender';

        sub schemas {
            'external::object' => {
                'x-schema-name' => "Test Extender 2"
            }
        }
    }
}
