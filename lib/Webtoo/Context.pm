package Webtoo::Context;

use v5.12;
use Moo;
use JSON 2.0;
use Plack::Request;
use Plack::Util;
use Carp;

has env  => (is => 'ro', required => 1); ## The PSGI environment.
has app  => (is => 'ro', required => 1); ## The Webtoo::App subclass instance.
has ctrl => (is => 'ro', required => 1); ## The Controller instance.
has info => (is => 'ro', required => 1); ## The routing info and params.

## The request object. Generated when requested.
has req  => (is => 'lazy', handles => [
  'param', 'method', 'path', 'body', 'content', 'uri'
]);

## The response object. Generated when requested.
has res  => (is => 'lazy', handles => [
  'status', 'header', 'redirect', 'location',
  'content_type', 'content_length', 'content_encoding',
]);

## The normal JSON mime type is application/json.
## You can override that here if you want.
has json_mime => (is => 'rw', default => sub { 'application/json' } );

## Build the Request object.
sub _build_req {
  my ($self) = @_;
  return Plack::Request->new($self->env);
}

## Build the Response object.
sub _build_res {
  my ($self) = @_;
  return $self->req->new_response();
}

## Send a response.
sub send {
  my $self = shift;
  $self->res->body(@_);
  $self->res->content_length(Plack::Util::content_length($self->res->body));
}

## Send a JSON response.
sub send_json {
  my ($self, $data) = @_;
  $self->res->content_type($self->json_mime);
  $self->send(encode_json($data));
}

## Get JSON data sent to us.
sub json_data {
  my ($self) = @_;
  return decode_json $self->req->content;
}

## Render a template, and return the rendered content.
sub render_view {
  my ($self, $template, $data, %opts) = @_;
  if (ref $self->ctrl->views && $self->ctrl->views->can('render')) {
    return $self->ctrl->views->render($template, $data, %opts);
  }
  else {
    croak "Attempt to use render_view in a controller without an engine.";
  }
}

## Render a template, and send the content as a response.
sub render {
  my $self = shift;
  my $content = $self->render_view(@_);
  $self->send($content);
}

1;
