#!/opt/perl5/bin/perl

use strict;
use warnings;
use Path::Class;

my $PERL5LIB = $ENV{PERL5LIB} || '';

if ($ENV{LOCAL_LIBS}) {
    for my $lib (split /:/, $ENV{LOCAL_LIBS}) {
        add_project_to_perl5lib($lib);
    }
}

my $default_local_libs = dir($ENV{LOCAL_LIBS_FROM} || '/opt/local');
if ( -e $default_local_libs ) {
    add_project_to_perl5lib($_) for $default_local_libs->children;
}

$ENV{PERL5LIB} = $PERL5LIB;
$ENV{PSGI} ||= '/opt/perl5/bin/opusvl_fb11website.psgi';

exec @ARGV if @ARGV;

my @cmd;

# in DEV_MODE we ignore MEMORY_LIMIT and WORKERS
if ($ENV{DEV_MODE}) {
    if ($ENV{DEBUG_CONSOLE} or -t STDOUT) {
        @cmd = qw(/opt/perl5/bin/perl -d /opt/perl5/bin/plackup --port 5000);
    }
    else {
        @cmd = qw(/opt/perl5/bin/plackup --port 5000);
    }
}
else {
    @cmd = qw(/opt/perl5/bin/starman --server Martian --listen :5000);
    
    if ($ENV{MEMORY_LIMIT}) {
        push @cmd, '--memory-limit', $ENV{MEMORY_LIMIT};
    }
    
    if ($ENV{WORKERS}) {
        push @cmd, '--workers', $ENV{WORKERS};
    }

    if ($ENV{STACKTRACE}) {
        unshift @cmd, qw(/opt/perl5/bin/perl -d:Confess);
    }

    # this is 2>&1, which we do for not-dev-mode
    open STDERR, '>&', STDOUT;
}

push @cmd, $ENV{PSGI};
exec @cmd;

sub add_project_to_perl5lib {
    my $dir = dir(shift);
    add_dist_to_perl5lib($_) for $dir->children;
}
sub add_dist_to_perl5lib {
    my $distdir = shift;
    return unless $distdir->is_dir;
    my $libdir = $distdir->subdir('lib');
    if (-e $libdir) {
        $PERL5LIB="$libdir:$PERL5LIB";
    }
}
