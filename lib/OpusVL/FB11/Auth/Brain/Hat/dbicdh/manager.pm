package OpusVL::FB11::Auth::Brain::Hat::dbicdh::manager;

# ABSTRACT: Default DBIDCH manager
our $VERSION = '0';

use v5.24;
use File::ShareDir 'module_dir';
use List::UtilsBy qw/sort_by/;
use OpusVL::FB11::DeploymentHandler;
use Try::Tiny;

use Moose;
with 'OpusVL::FB11::Role::Hat::dbicdh::manager';

=head1 DESCRIPTION

Since the core deployment handler schema is the FB11AuthDB, it follows that the
core deployment handler manager is on the brain that interfaces with it.

To use it, simply ensure the Auth brain is in your hive. See
L<OpusVL::FB11::Auth::Brain>.

=cut

sub deploy_and_upgrade {
    my $self = shift;
    my $hive = shift;

    my @dh_consumers = sort_by {$_->priority} $hive->hats('dbicdh::consumer');

    say scalar @dh_consumers;

    for my $hat (@dh_consumers) {
        my $schema = $hat->schema;
        my $v_deploy = $hat->start_at;
        my $v_upgrade = $schema->schema_version;
        my $module = ref $schema;

        my $dh = OpusVL::FB11::DeploymentHandler->new({
            schema => $schema,
            script_directory => module_dir(ref $schema) . '/sql',
            to_version => $v_upgrade,
        });

        my $v_current = try { $dh->database_version } catch {0};
        unless ($v_current) {
            say "Deploying $module at $v_deploy";
            my $ddl = $dh->deploy({
                version => $v_deploy
            });
            $dh->add_database_version({
                version => $v_deploy,
                ddl => $ddl,
            });
        }

        say "Upgrading $module from $v_current to $v_upgrade";
        $dh->upgrade;
    }
}

1;
