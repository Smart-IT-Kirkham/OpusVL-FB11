package OpusVL::FB11::RolesFor::Controller::FormHandler;

use Moose::Role;
use Module::Runtime qw/require_module/;

sub has_forms {
    my (%forms) = @_;
    {
        no strict 'refs';
        for my $method (keys %forms) {
            my $form = $forms{$method};
            my $caller = scalar caller;
            # absolute module
            if (substr($form, 0, 1) eq '+') {
                $form =~ s/^\+//g;
            }
            else {
                my $base = $caller;
                $base =~ s/::Controller::(.+)//g;
                $form = "${base}::Form::${form}";
            }
            require_module $form;
            
            my $to_install = "${caller}::${method}";

            if (defined &{$to_install}) {
                die "Form name collides with existing method name: $method";
            }
            *{$to_install} = sub { shift;$form->new(name => $method, @_) };
        }
    }
}

sub form {
    my ($self, $c, $form, $opts) = @_;
    my $base = scalar caller;
    $base =~ s/::Controller::(.+)//g;

    #if (not ref $c eq $base) {
    #    die "form() expects '${base}' object as second parameter. Received " . ref($c) . " instead\n";
    #}

    my $caller = scalar caller;
    # absolute module
    if (substr($form, 0, 1) eq '+') {
        $form =~ s/^\+//g;
    }
    else {
        $form = "${base}::Form::${form}";
    }
    eval "use $form";
    if ($@) {
        die "Could not use form $form: $@\n";
    }

    $opts //= {};
    my %args = ( ctx => $c );
    if (delete $opts->{update}) { $args{update_only} = 1; }

    return $form->new(%args, %$opts);
}


1;
