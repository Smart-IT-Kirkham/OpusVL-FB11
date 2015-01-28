package OpusVL::FB11::Plugin::FB11::FeatureList;

=head1 NAME

OpusVL::FB11::Plugin::FB11::FeatureList;

=head1 DESCRIPTION

Object to manage the features in AppKit to provide a less granular view of our access control 
system.

=head1 SYNOPSIS

    my $features = OpusVL::FB11::Plugin::FB11::FeatureList->new;

=head1 METHODS

=cut

use Moose;

has _features           => ( is => 'rw'       , isa => 'HashRef', default => sub { {}; } );
has _path_to_feature    => ( is => 'rw'       , isa => 'HashRef', default => sub { {}; } );

=head2 add_action

Pass it an action from the controller and it will read the features it is part of and store
the details.

=cut
sub add_action
{
    my $self = shift;
    my $app = shift;
    my $action = shift;

    my $features = $action->attributes->{AppKitFeature};
    return if !$features || !@$features;
    my $list = $features->[0];
    my @features = split /,/, $list;
    for my $feature (@features)
    {
        $self->_add_to_feature($app .'/'. $feature, $action->reverse);
    }
    my @app_and_feature = map { $app .'/'. $_ } @features;
    $self->_path_to_feature->{$action->reverse} = \@app_and_feature;
}

sub _add_to_feature
{
    my ($self, $feature, $action) = @_;

    if(!defined $self->_features->{$feature})
    {
        $self->_features->{$feature} = { actions => [], roles_allowed => [] };
    }
    push @{$self->_features->{$feature}->{actions}}, $action;
}

=head2 set_roles_allowed

Allows you to set the roles allowed to access a feature.

=cut
sub set_roles_allowed
{
    my ($self, $feature, $roles) = @_;

    my $f = $self->_features->{$feature};
    $f->{roles_allowed} = $roles if $f;
}

=head2 roles_allowed_for_action

Returns a list of roles allow to access an action path.

=cut
sub roles_allowed_for_action
{
    my $self = shift;
    my $action_path = shift;

    my $features = $self->_path_to_feature->{$action_path};
    return [] if !$features || !@$features;
    my @roles = map { @{$self->_features->{$_}->{roles_allowed} } } @$features;
    return \@roles;
}

=head2 feature_list

Returns a hash containing the feature names and their allowed roles.

=cut
sub feature_list
{
    my $self = shift;
    my $current_role = shift;

    # return a list of Feature name -> [roles allowed]
    my %map;
    my @keys = keys %{$self->_features};
    if($current_role)
    {
        # filter it down to a yes/no type deal.
        %map = map { $_ => scalar grep { $current_role eq $_ } @{$self->_features->{$_}->{roles_allowed}} } @keys;
    }
    else
    {
        %map = map { $_ => $self->_features->{$_}->{roles_allowed} } @keys;
    }
    # now split the map up some more.
    my %apps;
    for my $key (sort keys %map)
    {
        $key =~ q|^(.*)/(.*)$|;
        $apps{$1} = {} if !defined $apps{$1};
        $apps{$1}->{$2} = $map{$key};
    }
    return \%apps;
}

=head2 feature_names_with_app

Returns a flat list of features.  These feature names have the app name encoded in.

This is used by code that talks to the database since that's the format we store the features in.

=cut
sub feature_names_with_app
{
    my $self = shift;
    my %map;
    my @keys = keys %{$self->_features};
    return \@keys;
}

1;

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut
