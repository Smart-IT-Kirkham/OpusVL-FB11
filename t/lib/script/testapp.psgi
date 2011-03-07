#!/usr/bin/env perl
use strict;
use TestApp;

TestApp->setup_engine('PSGI');
my $app = sub { TestApp->run(@_) };


