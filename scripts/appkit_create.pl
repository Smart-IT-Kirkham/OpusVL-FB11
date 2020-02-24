#!/usr/bin/env perl

use strict;
use warnings;
no warnings 'experimental::signatures';;

use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('OpusVL::FB11', 'Create');

1;
