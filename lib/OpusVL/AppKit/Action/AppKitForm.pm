package OpusVL::AppKit::Action::AppKitForm;

=head1 NAME

    OpusVL::AppKit::Action::AppKitForm - Action class for OpusVL::AppKit FormConfig Loading

=head1 SYNOPSIS

    package TestX::CatalystX::ExtensionA::Controller::ExtensionA 
    sub formpage :Local :AppKitForm("admin/users/userform.yml")
    {
        my ($self, $c) = @_;
        $self->stash->{form}
        $c->stash->{template} = 'formpage.tt';
    }

=head1 DESCRIPTION

    When extension plugins for the AppKit are written they often use FormFu. The Confguration file these
    extentions FormFu bits can be tricky to load, what with all the namespace changes that occur.
    This action class helps in making things more tidy.

    Basically this is just uses File::ShareDir (with the 'appkit_myclass' config key) to find the dir and looks
    for the config file like so './root/forms/<actionname>.yml' .. or if you passed an argument, it will look for
    './root/forms/ARGUMENT0'

=head1 SEE ALSO

    L<Catalyst>
    L<OpusVL::AppKit::Base::Controller::GUI>

=head1 AUTHOR

    OpusVL - www.opusvl.com

=head1 LICENSE

    This library is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=cut

############################################################################################################################
# use lines.
############################################################################################################################
use Moose;
use namespace::autoclean;
use MRO::Compat; 
extends 'Catalyst::Action';
use File::ShareDir;

############################################################################################################################
# Methods
############################################################################################################################

=head2 execute
    Method called when an action is requested that has the 'AppKitForm' attribute.
=cut 
sub execute 
{
    my $self = shift;
    my ($controller, $c, @args) = @_;

    # get the FormFu object ...
    my $form = $controller->form;
    die("Failed to pull form from controller... did you 'extend' the OpusVL::AppKit::Base::Controller::GUI (which extends HTML::FormFu)???") unless defined $form;
    
    # Configure the form to generate IDs automatically
    $form->auto_id("formfield_%n_%r_%c");
    
    # The action attribute should point the path of the config file...
    my $config_file = $self->attributes->{AppKitForm}->[0];

    unless ( $controller->appkit_myclass )
    {
        die("Failed to load AppKitForm.. no appkit_myclass specified for $controller ");
    }

    # build the start of config file path..
    my $path = File::ShareDir::module_dir( $controller->appkit_myclass ) . '/root/forms/';
    # ... build the rest of the path..
    if ( defined $config_file )
    {
        $path .= $config_file;
    }
    else
    {
        $path .= $self->reverse . '.yml';
    }

    $c->log->debug("****************************** AppKitForm - Loading config: $path \n" );

    # .. now get the full path...
    my $form_file = File::Spec->rel2abs( $path );

    if ( -r $form_file )
    {
        # .. load it..
        $form->load_config_file ( $form_file );
        
        # .. process it..
        $form->process;
        
        # .. stash it..
        $c->stash->{ 'form' } = $form;
    }
    else
    {
        die("Could not find form config: $form_file ");
    }

    # call the next 'excute'...
    my $r = $self->next::method(@_);

    return $r;
}

1;
