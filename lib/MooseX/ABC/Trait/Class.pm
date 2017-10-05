package MooseX::ABC::Trait::Class;
use Moose::Role;
use Scalar::Util 'refaddr';
# ABSTRACT: metaclass trait for L<MooseX::ABC>

=head1 DESCRIPTION

This is a metaclass trait for L<MooseX::ABC> which implements the behavior of
dying if a subclass doesn't implement the required methods.

=cut

has is_abstract => (
    is      => 'rw',
    isa     => 'Bool',
    default => 0,
);

has required_methods => (
    traits     => ['Array'],
    is         => 'ro',
    isa        => 'ArrayRef[Str]',
    default    => sub { [] },
    auto_deref => 1,
    handles    => {
        add_required_method  => 'push',
        has_required_methods => 'count',
    },
);

after _superclasses_updated => sub {
    my $self = shift;
    return if $self->is_abstract;
    my @supers = $self->linearized_isa;
    shift @supers;
    for my $superclass (@supers) {
        my $super_meta = Class::MOP::class_of($superclass);
        next unless $super_meta->meta->can('does_role')
                 && $super_meta->meta->does_role('MooseX::ABC::Trait::Class');
        next unless $super_meta->is_abstract;
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
    if ($self->is_abstract) {
        push @options, inline_constructor => 0;
    }
    # we know that the base class has at least our base class role applied,
    # so it's safe to replace it if there is only one wrapper.
    elsif ($constructor->isa('Class::MOP::Method::Wrapped')
        && refaddr($constructor->get_original_method) == refaddr(Class::MOP::class_of('Moose::Object')->get_method('new'))) {
        push @options, replace_constructor => 1;
    }
    # if our parent has been inlined and we are not abstract, then it's
    # safe to inline ourselves
    elsif ($constructor->isa('Moose::Meta::Method::Constructor')) {
        push @options, replace_constructor => 1;
    }
    return @options;
};

no Moose::Role;

1;
