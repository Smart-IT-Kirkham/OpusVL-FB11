package OpusVL::FB11::RolesFor::Schema::FB11AuthDB;

=head1 NAME

OpusVL::FB11::RolesFor::Schema::FB11AuthDB

=head1 DESCRIPTION

The role allows the simple importing of the FB11AuthDB into your own schema so that you can join
to the objects.  Simply use the role and call merge_authdb (via __PACKAGE__).

=head1 SYNOPSIS

    with 'OpusVL::FB11::RolesFor::Schema::FB11AuthDB';

    __PACKAGE__->merge_authdb;

=head1 METHODS

=head2 merge_authdb

This loads the results and resultsets from the FB11AuthDB into your schema.

=head1 LICENSE AND COPYRIGHT

Copyright 2011 OpusVL.

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

=cut

use Moose::Role;

requires 'load_namespaces';

sub merge_authdb
{
    my $class = shift;
    $class->load_namespaces(
        result_namespace => '+OpusVL::FB11::Schema::FB11AuthDB::Result',
        resultset_namespace => '+OpusVL::FB11::Schema::FB11AuthDB::ResultSet',
    );
}

1;
