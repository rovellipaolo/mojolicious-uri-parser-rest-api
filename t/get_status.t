#!/usr/bin/perl

use strict;
use warnings;

use Mojo::File qw(curfile);
use Test::MockModule;
use Test::Mojo;
use Test::Spec;

my $sut = Test::Mojo->new( curfile()->dirname->sibling('app.pl') );

describe "GET /api/status" => sub {
    it "returns 200 OK response" => sub {
        $sut->get_ok('/api/status')->status_is(200)
          ->json_is(
            { message => 'REST API up and running... long live and prosper!' }
          );
    };
};

if ( !caller() ) {
    runtests();
}
