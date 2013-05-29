package MyApp::Controllers::Users;

use v5.12;
use Moo;

with 'Webtoo::Controller';

has users => (is => 'ro', default => sub { return {} } );

sub err {
  my ($message) = @_;
  return {"success"=>0, "error"=>$message};
}

sub ok {
  my (%data) = @_;
  $data{"success"} = 1;
  return \%data;
}

sub user_list {
  my ($self, $c) = @_;
  $c->status(200);
  my @users = sort keys $self->users;
  my $response = ok(users => \@users);
  $c->send_json($response);
}

sub get_user {
  my ($self, $c) = @_;
  my $username = $c->info->{user};
  if (exists $self->users->{$username}) {
    $c->status(200);
    my $user = $self->users->{$username};
    my $response = ok(user => $user);
    $c->send_json($response);
  }
  else {
    $c->status(404);
    $c->send_json(err 'invalid_user');
  }
}

sub new_user {
  my ($self, $c) = @_;
  my $username = $c->info->{user};
  if (exists $self->users->{$username}) {
    $c->status(409);
    $c->send_json(err 'user_exists');
  }
  else {
    $c->status(200);
    my $userdata = $c->json_data;
    $self->users->{$username} = $userdata;
    $c->send_json(ok);
  }
}

sub update_user {
  my ($self, $c) = @_;
  my $username = $c->info->{user};
  if (exists $self->users->{$username}) {
    my $user = $self->users->{$username};
    $c->status(200);
    my $newdata = $c->json_data;
    foreach my $key (keys $newdata) {
      $user->{$key} = $newdata->{$key};
    }
    my $response = ok(user => $user);
    $c->send_json($response);
  }
  else {
    $c->status(404);
    $c->send_json(err 'invalid_user');
  }
}

sub delete_user {
  my ($self, $c) = @_;
  my $username = $c->info->{user};
  $c->status(200);
  delete $self->users->{$username};
  $c->send_json(ok);
}

1;
