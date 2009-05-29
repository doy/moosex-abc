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
    elsif ($constructor->original_package_name eq 'MooseX::ABC::Role::Object') {
        push @options, replace_constructor => 1;
    }
    return @options;
};

no Moose::Role;

1;
