#!/usr/bin/perl

use strict;
use warnings;

use Mojo::File qw(curfile);
use Test::MockModule;
use Test::Mojo;
use Test::Spec;

my $sut = Test::Mojo->new( curfile()->dirname->sibling('app.pl') );

describe "POST /api/parse" => sub {

# TODO: Should mock the URI module instead of relying on real URI parser results!
    my $valid_uris = {

        # Generic URI parser (URI::_generic):
        '127.0.0.1' => {
            force             => 'true',
            expected_response => {
                fragment => undef,
                host     => undef,
                port     => undef,
                path     => '127.0.0.1',
                query    => undef,
                raw      => '127.0.0.1',
                scheme   => undef,
                userinfo => undef,
            }
        },
        'domain.tld' => {
            force             => 'true',
            expected_response => {
                fragment => undef,
                host     => undef,
                port     => undef,
                path     => 'domain.tld',
                query    => undef,
                raw      => 'domain.tld',
                scheme   => undef,
                userinfo => undef,
            }
        },
        'username@domain.tld' => {
            force             => 'true',
            expected_response => {
                fragment => undef,
                host     => undef,
                port     => undef,
                path     => 'username@domain.tld',
                query    => undef,
                raw      => 'username@domain.tld',
                scheme   => undef,
                userinfo => undef,
            }
        },

        # HTTP URI parser (URI::http):
        'http://127.0.0.1' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => '127.0.0.1',
                port     => 80,
                path     => '',
                query    => undef,
                raw      => 'http://127.0.0.1',
                scheme   => 'http',
                userinfo => undef,
            }
        },
        'http://domain.tld' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => 'domain.tld',
                port     => 80,
                path     => '',
                query    => undef,
                raw      => 'http://domain.tld',
                scheme   => 'http',
                userinfo => undef,
            }
        },
        'http://user:password@domain.tld:8080/path?key=value#fragment' => {
            force             => 'false',
            expected_response => {
                fragment => 'fragment',
                host     => 'domain.tld',
                port     => 8080,
                path     => '/path',
                query    => 'key=value',
                raw      =>
'http://user:password@domain.tld:8080/path?key=value#fragment',
                scheme   => 'http',
                userinfo => 'user:password',
            }
        },

        # HTTPS URI parser (URI::https):
        'https://127.0.0.1' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => '127.0.0.1',
                port     => 443,
                path     => '',
                query    => undef,
                raw      => 'https://127.0.0.1',
                scheme   => 'https',
                userinfo => undef,
            }
        },
        'https://domain.tld' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => 'domain.tld',
                port     => 443,
                path     => '',
                query    => undef,
                raw      => 'https://domain.tld',
                scheme   => 'https',
                userinfo => undef,
            }
        },
        'https://user:password@domain.tld:8080/path?key=value#fragment' => {
            force             => 'false',
            expected_response => {
                fragment => 'fragment',
                host     => 'domain.tld',
                port     => 8080,
                path     => '/path',
                query    => 'key=value',
                raw      =>
'https://user:password@domain.tld:8080/path?key=value#fragment',
                scheme   => 'https',
                userinfo => 'user:password',
            }
        },

        # FTP URI parser (URI::ftp):
        'ftp://domain.tld' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => 'domain.tld',
                port     => 21,
                path     => '',
                query    => undef,
                raw      => 'ftp://domain.tld',
                scheme   => 'ftp',
                userinfo => undef,
            }
        },

        # MAILTO URI parser (URI::mailto):
        'mailto:username@domain.tld' => {
            force             => 'false',
            expected_response => {
                fragment => undef,
                host     => undef,
                port     => undef,
                path     => 'username@domain.tld',
                query    => undef,
                raw      => 'mailto:username@domain.tld',
                scheme   => 'mailto',
                userinfo => undef,
            }
        },
    };

    it "returns 200 OK response when request contains a valid URI" => sub {
        for my $uri ( keys( %{$valid_uris} ) ) {
            $sut->post_ok( "/api/parse?force=" . $valid_uris->{$uri}{force},
                json => { uri => $uri } )->status_is(200)
              ->json_is( $valid_uris->{$uri}{expected_response} );
        }
    };

    it "returns 400 Bad Request response when request contains an invalid URI"
      => sub {
        my $invalid_uri = 'not-a-uri';
        $sut->post_ok( "/api/parse", json => { uri => $invalid_uri } )
          ->status_is(400)->json_is(
            {
                errors => [
                    {
                        message => "Not a valid URI: $invalid_uri",
                        path    => '/uri'
                    }
                ],
                status => 400
            }
          );
      };

    it "returns 400 Bad Request response when request contains an empty body" =>
      sub {
        $sut->post_ok( '/api/parse', json => {} )->status_is(400)->json_is(
            {
                errors =>
                  [ { message => 'Missing property.', path => '/body/uri' } ],
                status => 400
            }
        );
      };

    it "returns 400 Bad Request response when request contains no body" => sub {
        $sut->post_ok('/api/parse')->status_is(400)->json_is(
            {
                errors =>
                  [ { message => 'Missing property.', path => '/body' } ],
                status => 400
            }
        );
    };
};

if ( !caller() ) {
    runtests();
}
