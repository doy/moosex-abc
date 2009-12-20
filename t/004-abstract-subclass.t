#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 3;
use Test::Exception;

package Foo;
use Moose;
use MooseX::ABC;

requires 'foo';
requires 'bar';

package Foo::Sub;
use Moose;
use MooseX::ABC;
extends 'Foo';

requires 'baz';

sub bar { 'BAR' }

package Foo::Sub::Sub;
use Moose;
extends 'Foo::Sub';

sub foo { 'FOO' }
sub baz { 'BAZ' }

package main;

dies_ok { Foo->new } "can't create Foo objects";
dies_ok { Foo::Sub->new } "can't create Foo::Sub objects";
my $foo = Foo::Sub::Sub->new;
is($foo->foo, 'FOO', 'successfully created a Foo::Sub::Sub object');
