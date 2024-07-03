package URI::Parser;

use strict;
use warnings;
use feature qw(signatures);

use Mojo::Base -base;

use URI;
use Data::Validate::URI qw(is_uri);

no warnings qw(experimental::signatures);

has 'log';

sub is_valid ( $self, $uri ) {
    return is_uri($uri);
}

sub parse ( $self, $uri ) {
    $self->log->debug("Parsing URI: $uri");
    my $info = URI->new($uri);
    return {
        fragment => $info->fragment,
        host     => $self->_is_http_or_ftp_uri($info) ? $info->host : undef,
        port     => $self->_is_http_or_ftp_uri($info) ? $info->port : undef,
        path     => $info->path,
        query    => $info->query,
        raw      => $info->as_string // $uri,
        scheme   => $info->scheme,
        userinfo => $self->_is_http_or_ftp_uri($info) ? $info->userinfo : undef,
    };
}

sub _is_http_or_ftp_uri ( $self, $info ) {
    return $info->scheme && $info->scheme =~ /^(http|ftp)(s)?$/;
}

1;
