package MyApp;

use v5.12;
use Moo;

extends 'Webtoo::App';

sub BUILD {
  my ($self) = @_;
  $self->controller_path('MyApp::Controllers');
  $self->add_view_engine(
    type => 'TT',
    path => './t/views'
  );
  $self->add_controller(class => 'Unknown',   default => 1);
  $self->add_controller(class => 'Hello',     name    => 'test');
  $self->add_controller(class => 'HelloPage', views   => 'tt');
  $self->add_controller(class => 'Users');
  $self->GET('/', 'test');
  $self->GET('/hello', 'hellopage');
  $self->at     ('/users', 'users')
       ->GET    ('/',      'user_list')
       ->GET    ('/:user', 'get_user')
       ->POST   ('/:user', 'update_user')
       ->PUT    ('/:user', 'new_user')
       ->DELETE ('/:user', 'delete_user');
}

1;
