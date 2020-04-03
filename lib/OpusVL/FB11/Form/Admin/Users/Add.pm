package OpusVL::FB11::Form::Admin::Users::Add;

our $VERSION = '2';

use OpusVL::FB11::Plugin::FormHandler;
extends 'OpusVL::FB11::Form::Admin::Users::Edit';

has_field 'password' => (
    type        => 'Password',
    label       => 'Password',
    required    => 1,
    # Stops chrome trying to populate it like a login form
    element_attr => {
        autocomplete => 'new-password',
    }
);

sub build_render_list { [qw/username password name email tel status submit-it/] }

# This allows other things up the hierarchy to also add attrs
around build_form_element_attr => sub {
    my $orig = shift;
    my $self = shift;

    my $attr = $self->$orig(@_);

    $attr->{autocomplete} = 'off';

    return $attr;
};

no HTML::FormHandler::Moose;
1;
__END__
