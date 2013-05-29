package Webtoo::Template;

use v5.12;
use Moo::Role;

requires qw(render);

has opts   => (is => 'ro', default => sub { {} });
has path   => (is => 'rw', default => sub { './views' });
has engine => (is => 'lazy');

1;
