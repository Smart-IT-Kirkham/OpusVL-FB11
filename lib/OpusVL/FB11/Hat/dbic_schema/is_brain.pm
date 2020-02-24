package OpusVL::FB11::Hat::dbic_schema::is_brain;

# ABSTRACT: a dbic_schema hat where the brain is the schema

our $VERSION = '1';

use Moose;
with "OpusVL::FB11::Role::Hat::dbic_schema";

sub schema { shift->__brain }

1;

=head1 DESCRIPTION

A brain can say it wears the dbic_schema hat and then you have to implement how.

If you say you wear the dbic_schema::is_brain hat, you're just saying that your
brain and your schema are the same object, so this just does that.

