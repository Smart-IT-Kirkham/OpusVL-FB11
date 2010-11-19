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

=head1 COPYRIGHT and LICENSE

Copyright (C) 2010 OpusVL

This software is licensed according to the "IP Assignment Schedule" provided with the development project.

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
    die("Failed to pull form from controller. Ensure your Controller 'extends' Catalyst::Controller::HTML::FormFu") unless $controller->can('form');
    my $form = $controller->form;
    
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

    $c->log->debug("AppKitForm Loading config: $path \n" ) if $c->debug;

    # .. now get the full path...
    my $form_file = File::Spec->rel2abs( $path );

    if ( -r $form_file )
    {
        # .. load it..
        $form->load_config_file ( $form_file );
    
        $self->process( $form );
        
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

sub process
{
    my $self = shift;
    my $form = shift;
    # this is here so that other classes/roles can hook this method.
    # .. process it..
    $form->process;
}

1;
