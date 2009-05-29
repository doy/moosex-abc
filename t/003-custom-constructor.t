#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 1;

our $custom_constructor_called = 0;

package Foo;
use Moose;
use MooseX::ABC;

requires 'bar', 'baz';

package Foo::Sub;
use Moose;
extends 'Foo';

sub bar { }
sub baz { }
sub new { $::custom_constructor_called++; shift->SUPER::new(@_) }

package main;
my $foosub = Foo::Sub->new;
ok($custom_constructor_called, 'custom constructor was called');
