#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Requires;

test_requires 'MooseX::StrictConstructor';

{
    package Before;
    use Moose;
    use MooseX::ABC;
    use MooseX::StrictConstructor;

    __PACKAGE__->meta->make_immutable;
}

dies_ok {
    Before->new;
} 'Before->new() dies';

{
    package Foo;
    use Moose;
    extends 'Before';

    __PACKAGE__->meta->make_immutable;
}

dies_ok {
    Foo->new( attr => 'bar' );
} 'Foo->new() dies';

{
    package After;
    use Moose;
    use MooseX::StrictConstructor;
    use MooseX::ABC;

    __PACKAGE__->meta->make_immutable;
}

dies_ok {
    After->new;
} 'After->new() dies';

{
    package Bar;
    use Moose;
    extends 'After';

    __PACKAGE__->meta->make_immutable;
}

dies_ok {
    Bar->new( attr => 'bar' );
} 'Bar->new() dies';

done_testing;
