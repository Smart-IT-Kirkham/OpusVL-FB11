package OpusVL::FB11::Form::UploadAvatar;

our $VERSION = '1';

use OpusVL::FB11::Plugin::FormHandler;

has '+enctype' => ( default => 'multipart/form-data');

has_field 'file' => ( type => 'Upload', max_size => '2000000', label => "Upload new avatar" );
has_field 'submit'   => (
    type => 'Submit',
    widget => "ButtonTag",
    widget_wrapper => "None",
    value => '<i class="fa fa-check"></i> Upload',
    element_attr => { value => 'upload', class => ['btn', 'btn-primary'] }
);

no HTML::FormHandler::Moose;
1;
__END__
