package MyApp::Controllers::Hello;

use v5.12;
use Moo;

with 'Webtoo::Controller';

sub handle {
  my ($self, $c) = @_;
  my $name = $c->param('name') // 'world';
  $c->status(200);
  $c->content_type('text/plain');
  $c->send("Hello $name");
}

1;
