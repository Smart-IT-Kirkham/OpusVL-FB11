package OpusVL::FB11X::ResultsetSearch;
use Moose::Role;
use CatalystX::InjectComponent;
use File::ShareDir qw/module_dir/;
use namespace::autoclean;

with 'OpusVL::FB11::RolesFor::Plugin';

our $VERSION = '0.18';

before 'setup_components' => sub {
    my $class = shift;
    $class->add_paths(__PACKAGE__); # 'OpusVL::FB11X::ResultsetSearch'
};

after 'setup_components' => sub {
    my $class = shift;
   
    # .. inject your components here ..
    CatalystX::InjectComponent->inject(
        into      => $class,
        component => 'OpusVL::FB11X::ResultsetSearch::Controller::ResultSetSearch',
        as        => 'Controller::Modules::ResultSetSearch'
    );

};

1;

=head1 NAME

OpusVL::FB11X::ResultsetSearch - Easy display of results from DBIC ResultSets

=head1 DESCRIPTION

=head1 METHODS

=head1 BUGS

=head1 AUTHOR

=head1 COPYRIGHT & LICENSE

Copyright 2011 Opus Vision Limited, All Rights Reserved.

=cut

