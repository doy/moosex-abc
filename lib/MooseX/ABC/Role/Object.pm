package MooseX::ABC::Role::Object;
use Moose::Role;

=head1 NAME

MooseX::ABC::Role::Object - base object role for L<MooseX::ABC>

=head1 DESCRIPTION

This is a base object role implementing the behavior of L<MooseX::ABC> classes
being uninstantiable.

=cut

around new => sub {
    my $orig = shift;
    my $class = shift;
    my $meta = Class::MOP::class_of($class);
    $meta->throw_error("$class is abstract, it cannot be instantiated")
        if $meta->has_required_methods;
    $class->$orig(@_);
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
