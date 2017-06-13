#!/opt/perl5/bin/perl

use strict;
use warnings;
use v5.20;
use Path::Class;

my $PERL5LIB = $ENV{PERL5LIB} || '';

if ($ENV{LOCAL_LIBS}) {
    for my $lib (split /:/, $ENV{LOCAL_LIBS}) {
        add_project_to_perl5lib($lib);
    }
}

if ($ENV{DEV_MODE}) {
    my $default_local_libs = dir($ENV{LOCAL_LIBS_FROM} || '/opt/local');
    if ( -e $default_local_libs ) {
        say "Adding $_ to PERL5LIB",
        add_project_to_perl5lib($_) for $default_local_libs->children;
    }
}

$ENV{PERL5LIB} = $PERL5LIB;
$ENV{PSGI} ||= '/opt/perl5/bin/opusvl_fb11website.psgi';

exec @ARGV if @ARGV;

my @cmd;

my $PORT = $ENV{FB11_PORT} || 5000;

# in DEV_MODE we ignore MEMORY_LIMIT and WORKERS
if ($ENV{DEV_MODE}) {
    @cmd = (qw(/opt/perl5/bin/plackup --port), $PORT);

    if ($ENV{DEBUG_CONSOLE} or -t STDOUT) {
        unshift @cmd, qw(/opt/perl5/bin/perl -d);
    }
}
else {
    @cmd = (qw(/opt/perl5/bin/starman --server Martian --listen), ":$PORT");
    
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
        say "Installing deps for $libdir";
        system( qw(/opt/perl5/bin/cpanm -l /opt/fb11 --installdeps), $libdir );
    }
}
