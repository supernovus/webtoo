package Webtoo::Template::TT;

use v5.12;
use Moo;
use Template;

with 'Webtoo::Template';

sub _build_engine {
  my $self = shift;
  my $opts = $self->opts;
  if (!exists $opts->{INCLUDE_PATH}) {
    $opts->{INCLUDE_PATH} = $self->path;
  }
  return Template->new($opts);
}

sub render {
  my ($self, $template, $data, %opts) = @_;
  my $content = '';
  $self->engine->process($template, $data, \$content, %opts);
  return $content;
}

1;
