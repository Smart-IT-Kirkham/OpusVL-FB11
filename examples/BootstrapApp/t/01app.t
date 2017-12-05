#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'BootstrapApp';

BootstrapApp->model('FB11AuthDB')->schema->deploy({add_drop_table => 1});

ok( request('/login')->is_success, 'Request should succeed' );

done_testing();
