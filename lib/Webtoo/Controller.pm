package Webtoo::Controller;

use Moo::Role;

has app => ( is => 'ro', required => 1 );
has views => ( is => 'ro' );

1;

