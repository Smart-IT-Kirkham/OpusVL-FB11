package OpusVL::AppKit::Model::AppKitAuthDB;

=head1 NAME

    OpusVL::AppKit::Model::AppKitAuthDB - AppKit's Authenication Model

=head1 SYNOPSIS

    Move along please.... nothing to see or do here... 

=head1 DESCRIPTION

    This is the Authenication model for the AppKit.
    It is configured in your Top Level App.

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 LICENSE

    This library is free software, you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

####################################################################################################################
# construction of object.
####################################################################################################################
use Moose;
BEGIN { extends 'Catalyst::Model::DBIC::Schema'; }
1;
__END__
