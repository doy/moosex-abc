package MooseX::ABC::Trait::Class;
use Moose::Role;
use MooseX::AttributeHelpers;

has required_methods => (
    metaclass  => 'Collection::Array',
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    auto_deref => 1,
    provides   => {
        push  => 'add_required_method',
        empty => 'has_required_methods',
    },
);

after _superclasses_updated => sub {
    my $self = shift;
    my @supers = $self->linearized_isa;
    shift @supers;
    for my $superclass (@supers) {
        my $super_meta = Class::MOP::class_of($superclass);
        next unless $super_meta->meta->can('does_role')
                 && $super_meta->meta->does_role('MooseX::ABC::Trait::Class');
        for my $method ($super_meta->required_methods) {
            if (!$self->find_method_by_name($method)) {
                my $classname = $self->name;
                $self->throw_error(
                    "$superclass requires $classname to implement $method"
                );
            }
        }
    }
};

around _immutable_options => sub {
    my $orig = shift;
    my $self = shift;
    my @options = $self->$orig(@_);
    my $constructor = $self->find_method_by_name('new');
    if ($self->has_required_methods) {
        push @options, inline_constructor => 0;
    }
    # we know that the base class has at least our base class role applied,
    # so it's safe to replace it if there is only one wrapper.
    elsif ($constructor->isa('Class::MOP::Method::Wrapped')
        && $constructor->get_original_method == Class::MOP::class_of('Moose::Object')->get_method('new')) {
        push @options, replace_constructor => 1;
    }
    return @options;
};

no Moose::Role;

1;
