package MooseX::ABC::Trait::Class;
use Moose::Role;
use MooseX::AttributeHelpers;

=head1 NAME

MooseX::ABC::Trait::Class - metaclass trait for L<MooseX::ABC>

=head1 DESCRIPTION

This is a metaclass trait for L<MooseX::ABC> which implements the behavior of
dying if a subclass doesn't implement the required methods.

=cut

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

=head1 SUPPORT

You can find this documentation for this module with the perldoc command.

    perldoc MooseX::ABC

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/MooseX-ABC>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/MooseX-ABC>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=MooseX-ABC>

=item * Search CPAN

L<http://search.cpan.org/dist/MooseX-ABC>

=back

=head1 AUTHOR

  Jesse Luehrs <doy at tozt dot net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2009 by Jesse Luehrs.

This is free software; you can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
