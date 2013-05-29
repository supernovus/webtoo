package MyApp::Controllers::Unknown;

use v5.12;
use Moo;

with 'Webtoo::Controller';

sub handle {
  my ($self, $c) = @_;
  $c->content_type('text/plain');
  $c->send("Page not found.");
}

1;
