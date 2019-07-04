use Test::Most qw/no_plan/;
use OpusVL::FB11::Hive;
use OpusVL::EventLog;
use OpusVL::EventLog::Adapter::Static;
use Test::DBIx::Class -config_path => [qw/t etc eventlog/], qw/Event/;

my $hive = "OpusVL::FB11::Hive";

lives_ok {
    $hive->configure({
        brains => [
            {
                class => 'OpusVL::EventLog',
                constructor => {
                    schema => Schema
                }
            },
        ],
        services => {
            eventlog => {
                brain => 'event-log'
            }
        }
    })
} "Configure Hive";

subtest "Syslog" => sub {
    my $service = $hive->service('eventlog');

    $service->add_event(
        object => $OpusVL::EventLog::SYSTEM,
        payload => {
            message => "Testing event"
        },
        type => 'test'
    );

    is Event->count, 1, "1 event in table";

    my @events = $service->search_events(
        object => $OpusVL::EventLog::SYSTEM
    );

    is scalar @events, 1, "1 returned from search_events";
};

reset_schema;

subtest "Object log" => sub {
    my $service = $hive->service('eventlog');

    my $adapter = OpusVL::EventLog::Adapter::Static->new({
        object_type => "semantic::type",
        id => { id => 1 }
    });

    $service->add_event(
        object => $adapter,
        payload => {
            message => "Testing event"
        },
        type => 'test'
    );

    is Event->count, 1, "1 event in table";

    my @events = $service->search_events(
        object => $adapter,
    );

    is scalar @events, 1, "1 returned from search_events";
};

reset_schema;

subtest "Environmental data" => sub {
    my $service = $hive->service('eventlog');

    my $adapter = OpusVL::EventLog::Adapter::Static->new({
        object_type => "semantic::type",
        id => { id => 1 }
    });

    subtest "1 nesting of data" => sub {
        my $guard = $service->set_environmental_data({
            user => 'fb11admin'
        });

        $service->add_event(
            object => $adapter,
            payload => {
                message => "Testing event"
            },
            tags => {
                ip => '127.0.0.1',
            },
            type => 'test'
        );

        is Event->count, 1, "1 event in table";

        my @events = $service->search_events(
            object => $adapter,
        );

        is scalar @events, 1, "1 returned from search_events";

        is_deeply $events[0]->{tags}, {
            user => 'fb11admin',
            ip => '127.0.0.1',
        }, "Got environmental data in tags";

        subtest "2 nestings of data" => sub {
            my $guard = $service->set_environmental_data({
                ip => '127.0.0.1'
            });

            $service->add_event(
                object => $adapter,
                payload => {
                    message => "Testing event"
                },
                type => 'test'
            );

            is Event->count, 2, "2 events in table";

            my @events = $service->search_events(
                object => $adapter,
            );

            is scalar @events, 2, "2 returned from search_events";

            is_deeply $events[1]->{tags}, {
                user => 'fb11admin',
                ip => '127.0.0.1'
            }, "Got merged environmental data";
        };

        $service->add_event(
            object => $adapter,
            payload => {
                message => "Testing event"
            },
            type => 'test'
        );

        is Event->count, 3, "3 events in table";

        @events = $service->search_events(
            object => $adapter,
        );

        is scalar @events, 3, "3 returned from search_events";

        is_deeply $events[2]->{tags}, { user => 'fb11admin' }, "Environmental data was reset";
    };

    $service->add_event(
        object => $adapter,
        payload => {
            message => "Testing event"
        },
        type => 'test'
    );
    is Event->count, 4, "4 events in table";

    my @events = $service->search_events(
        object => $adapter,
    );

    is scalar @events, 4, "4 returned from search_events";

    is_deeply $events[3]->{tags}, {}, "Environmental data was reset";
};

reset_schema;

subtest "Search by data" => sub {
    my $service = $hive->service('eventlog');

    my $adapter = OpusVL::EventLog::Adapter::Static->new({
        object_type => "semantic::type",
        id => { id => 1 }
    });
    my $tag_adapter = OpusVL::EventLog::Adapter::Static->new({
        object_type => "fb11core::user",
        id => { email => 'admin@fb11.app' }
    });

    my $guard = $service->set_environmental_data({
        username => 'fb11admin',

        # FIXME: Semantic types are not part of FB11 yet, but when they are,
        # everything should understand what an adapter is
        user => $tag_adapter->get_identifier
    });

    $service->add_event(
        object => $adapter,
        payload => {
            message => "Testing event",
            data => "Discoverable data",
        },
        tags => {
            ip => '127.0.0.1',
        },
        type => 'test'
    );

    my @events = $service->search_events(
        tags => { username => 'fb11admin' }
    );
    is scalar @events, 1, "Found by env data";

    @events = $service->search_events(
        payload => { message => "Testing event" }
    );
    is scalar @events, 1, "Found by payload data";

    @events = $service->search_events(
        tags => {
            user => $tag_adapter->get_identifier
        }
    );
    is scalar @events, 1, "Found by tag object identifier";

    @events = $service->search_events(
        payload => {
            data => "Not present",
        }
    );
    is scalar @events, 0, "Not found when not present";

    @events = $service->search_events(
        tags => {
            username => "Testing event",
            user => $tag_adapter->get_identifier
        }
    );
    is scalar @events, 0, "Not found when not present";
};

done_testing;
