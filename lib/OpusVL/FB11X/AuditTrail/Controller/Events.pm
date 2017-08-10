package OpusVL::FB11X::AuditTrail::Controller::Events;

use v5.14;

use Moose;
use namespace::autoclean;

BEGIN { extends "Catalyst::Controller" };
with 'OpusVL::FB11::RolesFor::Controller::GUI';

__PACKAGE__->config
(
    fb11_name          => 'Event Log',
    fb11_icon          => '/static/images/audit-icon-small.png',
    fb11_myclass       => 'OpusVL::FB11X::AuditTrail',  
    fb11_shared_module => 'Events',
    fb11_method_group  => 'Events',
    fb11_css           => ['/static/css/audit-trail.css'],
);

has_forms(
    event_search_form => '+OpusVL::FB11X::AuditTrail::Form::EventSearch',
);

sub auto :Action {
    my ($self, $c) = @_;
    return 1;
}

sub home
    : Path
    : Args(0)
    : NavigationHome
{
    my $self = shift;
    my $c    = shift;

    $c->res->redirect ($c->uri_for ($self->action_for ('all_events')));
    $c->detach;
}

sub all_events
    : Path('all')
    : NavigationName('Search')
    : Args(0)
    : FB11Feature('Search Audit Trail')
{
    my $self = shift;
    my $c    = shift;

    $c->stash->{section} = 'Search';
    my $events = $c->model ('AuditTrail::EvtEvent');


    my $search_args = 
    [{
        resultset => $events
    }];

    $c->forward ('/fb11/audittrail/events/event_search' => $search_args);
}

sub event_search :Private
{
    my ($self, $c, $search_args) = @_;
    
    my $form = $self->event_search_form;
    $c->stash(form => $form);

    push @{ $search_args->{sort_defs} }, ([ event_date => 'Event Date' ]);

    my $types = $c->model('AuditTrail::EvtType')->search({}, { order_by => { -asc => 'event_type' } });

    my $type_field = $form->field('type_id');
    # use Data::Dumper;
    # say STDERR Dumper($type_field);
    $type_field->options([
        map +{
            value => $_->id,
            label => $_->event_type
        }, $types->all
    ]);

    $c->forward ('/modules/resultsetsearch/search_results' => [$search_args]);
}
return 1;

=head1 NAME

OpusVL::FB11X::AuditTrail::Controller::Events

=head1 DESCRIPTION

=head1 METHODS

=head2 auto

=head2 home

=head2 all_events

=head2 event_search

=head1 ATTRIBUTES


=head1 LICENSE AND COPYRIGHT

Copyright 2015 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
