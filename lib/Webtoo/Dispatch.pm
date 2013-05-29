package Webtoo::Dispatch;

use Moo::Role;

requires qw(request);

sub GET {
  my ($self, $path, $def) = @_;
  $self->request($path, $def, {method => 'GET'});
}

sub POST {
  my ($self, $path, $def) = @_;
  $self->request($path, $def, {method => 'POST'});
}

sub PUT {
  my ($self, $path, $def) = @_;
  $self->request($path, $def, {method => 'PUT'});
}

sub DELETE {
  my ($self, $path, $def) = @_;
  $self->request($path, $def, {method => 'DELETE'});
}

sub HEAD {
  my ($self, $path, $def) = @_;
  $self->request($path, $def, {method => 'HEAD'});
}

1;

