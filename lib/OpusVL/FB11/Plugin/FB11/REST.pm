package OpusVL::FB11::Plugin::FB11::REST;

use Moose;
extends 'OpusVL::FB11::Plugin::FB11';

use HTTP::Status qw/:constants/;

override detach_to_fb11_access_denied => sub {
    my ($c, $denied_access_to_action) = @_;

    $c->log->debug("FB11 - Not Allowed Access to " . $denied_access_to_action->reverse . " - Returning 401");
    
    $c->res->status(HTTP_UNAUTHORIZED);
    $c->stash->{rest} = \undef;
    $c->detach;
};

1;

=head1 NAME

OpusVL::FB11::Plugin::FB11::REST - For RESTful apps

=head1 DESCRIPTION

Use in place of L<OpusVL::FB11::Plugin::FB11> in order to get RESTful behaviour.
This is instead of the old-fashioned behaviour that would use a normal set of
controllers and just set a RESTful flag.

    override _build_plugins => sub {
        my $plugins = super();

        @$plugins = grep { $_ ne '+OpusVL::FB11::Plugin::FB11' } @$plugins;

        push @$plugins, qw/
            +OpusVL::FB11::Plugin::FB11::REST
            +Pulsar::FB11X::DB
            +Pulsar::FB11X::API
        /;

        return $plugins;
    };
