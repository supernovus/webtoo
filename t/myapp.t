#!/usr/bin/perl

use v5.12;
use strict;
use warnings;
use lib qw(lib t/lib);
use Test::More tests => 32;
use Plack::Test;
use MyApp;
use HTTP::Request::Common qw(GET PUT POST DELETE);
use JSON 2.0;

my $app = MyApp->new();

test_psgi $app->psgi, sub {
  my $cb  = shift;
  my $ct = 'application/json';

  my $res = $cb->(GET "/");
  is $res->code, 200, "Default controller status";
  is $res->content, 'Hello world', "Default controller body";

  $res = $cb->(GET "/?name=Bob");
  is $res->content, 'Hello Bob', "Default controller with parameter.";

  my $user = {name => "Timothy Totten", dob => "1979-06-22"};
  $res = $cb->(PUT "/users/tim", 
    Content_Type => $ct, 
    Content => encode_json $user
  );
  is $res->code, 200, "Created new user";
#  diag $res->content;
  my $json = decode_json $res->content;
  ok $json->{success}, "JSON returned success";

  $user = {name => "Nancy Prime", dob => "1983-05-21"};
  $res = $cb->(PUT "/users/nancy",
    Content_Type => $ct,
    Content => encode_json $user
  );
  is $res->code, 200, "Created a second user";

  $res = $cb->(GET "/users/");
  is $res->code, 200, "User list";
#  diag $res->content;
  $json = decode_json $res->content;
  ok $json->{success}, "JSON returned success";
  my $users = $json->{users};
  is @{$users}, 2, "proper number of users";
  is $users->[1], 'tim', "proper user";

  $res = $cb->(GET "/users/tim");
  is $res->code, 200, "get a user";
#  diag $res->content;
  $json = decode_json $res->content;
  is $json->{user}{dob}, '1979-06-22', "user dob is correct";
  is $json->{user}{name}, 'Timothy Totten', "user name is correct";

  $user = {name=>"Tim Totten", role=>"admin"};
  $res = $cb->(POST "/users/tim",
    Content_Type => $ct,
    Content => encode_json $user
  );
  is $res->code, 200, "update a user";
#  diag $res->content;
  $json = decode_json $res->content;
  is $json->{user}{dob}, '1979-06-22', "user dob still correct";
  is $json->{user}{name}, 'Tim Totten', "user name updated";
  is $json->{user}{role}, 'admin', "user role added";

  $res = $cb->(PUT "/users/nancy",
    Content_Type => $ct,
    Content => encode_json $user
  );
  is $res->code, 409, "Cannot overwrite an existing user.";
#  diag $res->content;
  $json = decode_json $res->content;
  is $json->{success}, 0, "errors return non-success";
  is $json->{error}, 'user_exists', "proper error message returned";

  $res = $cb->(DELETE "/users/nancy");
  is $res->code, 200, "Deleted a user";
#  diag $res->content;
  $json = decode_json $res->content;
  ok $json->{success}, "JSON returned success";

  $res = $cb->(GET "/users/nancy");
  is $res->code, 404, "cannot get non-existent user";
#  diag $res->content;
  $json = decode_json $res->content;
  is $json->{success}, 0, "JSON returned non-success";
  is $json->{error}, 'invalid_user', "proper error message returned";

  $res = $cb->(POST "/users/nancy",
    Content_Type => $ct,
    Content => encode_json $user
  );
  is $res->code, 404, "cannot update non-existent user";
#  diag $res->content;
  $json = decode_json $res->content;
  is $json->{success}, 0, "JSON returned non-success";
  is $json->{error}, 'invalid_user', "proper error message returned";

  $res = $cb->(GET "/users/");
#  diag $res->content;
  $json = decode_json $res->content;
  $users = $json->{users};
  is @{$users}, 1, "number of users updated properly";
  is $users->[0], 'tim', "proper user still listed";

  $res = $cb->(GET "/hello?name=Joe");
  is $res->code, 200, "response from a template-powered controller";
#  diag $res->content;
  is $res->content, "Hello Joe, how are you?", "template output";

};
