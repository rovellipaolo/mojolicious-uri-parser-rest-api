#!/usr/bin/perl

use Mojolicious::Plugin::Config;
use Mojolicious::Lite -signatures;

use FindBin '$Bin';
use lib "$Bin/lib";
use URI::Parser;

use constant {
    DEFAULT_CONFIG_PATH => 'app.conf',
    DEFAULT_LOG_LEVEL   => 'info',
};

$|++;

# Routes:

get '/status' => sub ($self) {
    my $controller = $self->openapi->valid_input or return;
    $self->log_request($controller);

    $controller->render(
        openapi => {
            message => 'REST API up and running... long live and prosper!'
        },
        status => 200
    );
  },
  'status';

post '/parse' => sub ($self) {
    my $controller = $self->openapi->valid_input or return;
    $self->log_request( $controller,
            $controller->req->url->{path}{path} . "?"
          . $controller->req->url->{query} );

    my $force = $self->param('force');
    my $body  = $controller->req->json;
    my $uri   = $body->{uri};

    my $parser = URI::Parser->new( log => $controller->log );
    if ( !$force && !$parser->is_valid($uri) ) {
        $controller->render(
            openapi => {
                errors =>
                  [ { message => "Not a valid URI: $uri", path => '/uri' } ],
                status => 400
            },
            status => 400
        );
        return;
    }

    my $info = $parser->parse($uri);
    $controller->render( openapi => $info, status => 200 );
  },
  'parse';

# Helpers:

helper log_request => sub ( $self, $controller, $endpoint = undef ) {
    if ( !defined($endpoint) ) {
        $endpoint = $controller->req->url->{path}{path};
    }
    $controller->log->info( 'Received '
          . $controller->req->method() . ' '
          . $endpoint
          . ' request from '
          . ( $self->remote_addr // "unknown" ) );
};

# Plugins:

plugin 'Config'  => { file => DEFAULT_CONFIG_PATH };
plugin 'OpenAPI' => { url  => app->config->{openapi_path} };
plugin 'RemoteAddr';

my $log_level = lc( app->config->{log_level} // DEFAULT_LOG_LEVEL );
app->log->level($log_level);
app->log->info("Log level: $log_level");
app->log->info( 'OpenAPI definition: ' . app->config->{openapi_path} );
app->start();
