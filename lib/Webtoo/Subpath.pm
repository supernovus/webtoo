package Webtoo::Subpath;

use v5.12;
use Moo;

with 'Webtoo::Dispatch';

has parent    => (is => 'ro', required => 1);
has submapper => (is => 'ro', required => 1);

sub request {
  my ($self, $path, $def, $opts) = @_;
  if (!ref $def) {
    $def = { action => $def };
  }
  $self->submapper->connect($path, $def, $opts);
  return $self;
}

1;
