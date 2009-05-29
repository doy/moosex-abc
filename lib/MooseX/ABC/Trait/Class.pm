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
        push => 'add_required_method',
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
                die "$superclass requires $classname to implement $method";
            }
        }
    }
};

no Moose::Role;

1;
