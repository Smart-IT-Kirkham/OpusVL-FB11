package OpusVL::FB11::Form::Role::Users;

use Moose::Role;

sub validate_username {
    my ($self, $field) = @_;
    unless ($self->update_only) {
        my $user_rs = $self->ctx->model('FB11AuthDB::User');
        if ($user_rs->find({ username => $field->value })) {
            $field->add_error('Username must be unique');
        }
    }
}

sub validate_password {
    my ($self, $field) = @_;
    my $ctx = $self->ctx;
    my $password = $field->value;

    my ($pass_min_length, $pass_numerics, $pass_symbols) = (
        $ctx->config->{FB11}->{password_min_characters},
        $ctx->config->{FB11}->{password_force_numerics},
        $ctx->config->{FB11}->{password_force_symbols},
    );

    if ($pass_min_length && length($password) < $pass_min_length) {
        $field->add_error("Minimum length for password is ${pass_min_length} characters");
    }

    if ($pass_numerics && $password !~ /[0-9]/) {
        $field->add_error("Expecting a numeric character in password. None found");
    }

    if ($pass_symbols && $password !~ /\W/) {
        $field->add_error("Expecting a symbol character in password. None found");
    }
}

sub validate_newpassword {
    my ($self, $field) = @_;
    my $ctx = $self->ctx;
    my $password = $field->value;

    my ($pass_min_length, $pass_numerics, $pass_symbols) = (
        $ctx->config->{FB11}->{password_min_characters},
        $ctx->config->{FB11}->{password_force_numerics},
        $ctx->config->{FB11}->{password_force_symbols},
    );

    if ($pass_min_length && length($password) < $pass_min_length) {
        $field->add_error("Minimum length for password is ${pass_min_length} characters");
    }

    if ($pass_numerics && $password !~ /[0-9]/) {
        $field->add_error("Expecting a numeric character in password. None found");
    }

    if ($pass_symbols && $password !~ /\W/) {
        $field->add_error("Expecting a symbol character in password. None found");
    }
}
1;
__END__
