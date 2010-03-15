#!/usr/bin/env perl
use FindBin;
use lib "$FindBin::Bin/../"; # because this is a test.
use lib "$FindBin::Bin/../../../lib"; # because this is a test.
use Catalyst::ScriptRunner;
Catalyst::ScriptRunner->run('TestApp', 'Test');
1;
