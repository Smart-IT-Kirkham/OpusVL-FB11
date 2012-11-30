package OpusVL::AppKit::RolesFor::Schema::DataInitialisation;

use Moose::Role;

sub deploy_with_data
{
    my $self = shift;
    $self->deploy;
    for my $resultset ($self->sources)
    {
        my $rs = $self->resultset($resultset);
        $rs->initdb if $rs->can('initdb');
        $rs->initdb_populate if $rs->can('initdb_populate');
    }
    return $self;
}

1;
