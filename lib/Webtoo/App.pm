package Webtoo::App;

use v5.12;
use Moo;
use Router::Simple;
use Webtoo::Subpath;
use Webtoo::Context;
use Plack::Util;
use Carp;

with 'Webtoo::Dispatch';

has router => ( is => 'ro', default => sub { return Router::Simple->new(); } );
has view_engines => ( is => 'ro', default => sub { return {} } );
has controllers => ( is => 'ro', default => sub { return {} } );
has default => ( is => 'rw' );
has controller_path => ( is => 'rw' );

sub request {
  my ($self, $path, $def, $opts) = @_;
  if (!ref $def) {
    $def = { controller => $def };
  }
  $self->router->connect($path, $def, $opts);
  return $self;
}

sub at {
  my ($self, $basepath, $basedef, $baseopt) = @_;
  if (!ref $basedef) {
    $basedef = { controller => $basedef };
  }
  my $submapper = $self->router->submapper($basepath, $basedef, $baseopt);
  return Webtoo::Subpath->new(parent => $self, submapper => $submapper);
}

sub add_view_engine {
  my ($self, %opts) = @_;
  my ($name, $engine, $classname, $path, $options);

  if (exists $opts{options}) {
    $options = $opts{options};
  }
  if (exists $opts{path}) {
    $path = $opts{path};
  }

  if (exists $opts{object}) {
    $engine    = $opts{object};
    $classname = ref $engine;
  }
  elsif (exists $opts{type}) {
    $classname = Plack::Util::load_class($opts{type}, 'Webtoo::Template');
    my %constructor;
    if ($path) {
      $constructor{path} = $path;
    }
    if ($options) {
      $constructor{opts} = $options;
    }
    $engine = $classname->new(%constructor);
  }
  else {
    croak "Invalid view engine specification.";
  }

  if (exists $opts{name}) {
    $name = $opts{name};
  }
  else {
    $name = lc($classname);
    $name =~ s/.*?:://g;
  }

  $self->view_engines->{$name} = $engine;

}

sub add_controller {
  my ($self, %opts) = @_;
  my ($name, $controller, $classname);

  if (exists $opts{object}) {
    $controller = $opts{object};
    $classname  = ref $controller;
  }
  elsif (exists $opts{class}) {
    $classname  = Plack::Util::load_class($opts{class}, $self->controller_path);
    my %constructor = (app => $self);
    if (exists $opts{views}) {
      my $viewname = $opts{views};
      if (exists $self->view_engines->{$viewname}) {
        $constructor{views} = $self->view_engines->{$viewname};
      }
      else {
        carp "Invalid view engine '$viewname' requested for $classname.";
      }
    }
    $controller = $classname->new(%constructor);
  }
  else {
    croak "Invalid controller specification.";
  }

  if (exists $opts{name}) {
    $name = $opts{name};
  }
  else {
    $name = lc($classname);
    $name =~ s/.*?:://g;
  }

  $self->controllers->{$name} = $controller;

  if ($opts{default}) {
    $self->default($name);
  }
}

sub dispatch {
  my ($self, $env) = @_;
  my $route = $self->router->match($env);
  if (!$route) {
    $route = { controller => $self->default };
  }
  my $cname = $route->{controller};
  if (!exists $self->controllers->{$cname}) {
    croak "No such controller '$cname' found.";
  }
  my $controller = $self->controllers->{$cname};
  my $action = "handle";
  if (exists $route->{action}) {
    $action = $route->{action};
  }
  if (!$controller->can($action)) {
    croak "Invalid action '$action' specified.";
  }
  my $context = Webtoo::Context->new(
    env  => $env,
    app  => $self,
    ctrl => $controller,
    info => $route,
  );
  $controller->$action($context);
  $context->res->finalize;
}

sub psgi {
  my ($self) = @_;
  return sub {
    return $self->dispatch(shift);
  }
}

## End of file.
1;