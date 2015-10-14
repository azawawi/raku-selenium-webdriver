#!/usr/bin/env perl6

use v6;
use HTTP::Client;
use JSON::Tiny;
use MIME::Base64;

#TODO run phantomjs command async
#my $port = 5555;
#my $cmd = qq{phantomjs --webdriver=$port};


constant URL = "http://127.0.0.1:5555";

my $session_obj = new_session;
die "Cannot instaniate session" unless defined($session_obj);

my $session_id = $session_obj<sessionId>;
die "Session id is null" unless defined($session_id);

my $o;
$o = set_url( $session_id, "http://google.com" );

$o = get_screenshot($session_id);
"screenshot01.png".IO.slurp(MIME::Base64.decode-str( $o<value> ));


# POST /session
sub new_session {
    return execute_command(
        "POST",
        "/session",
        {
            "desiredCapabilities"  => {},
            "requiredCapabilities" => {},
        }
    );
}


sub execute_command(Str $method, Str $command, Hash $params) {

    my $client = HTTP::Client.new;
    my $response;
    if ( $method eq "POST" ) {
        my $request = $client.post;
        $request.url("$(URL)$command");
        $request.set-content(to-json($params));
        $response = $request.run;
    }
    elsif ( $method eq "GET" ) {
        $response = $client.get( "$(URL)$command" );
    }
    elsif( $method eq 'DELETE') {
      $response = $client.delete( "$(URL)$command" );
    }
    else {
        die qq{Unknown method "$method"};
    }
    
    my $result;
    if ( $response.success ) {
        $result = from-json( $response.content );
    }
    else {
        warn "ERROR: " ~ $response.message;
    }

    say $result.perl;

    return $result;
}


# POST /session/:sessionId/url
sub set_url(Str $session_id, Str $url) {
    return execute_command(
        "POST",
        "/session/$session_id/url",
        {
            url => $url,
        }
    );
}

# GET /session/:sessionId/screenshot
sub get_screenshot(Str $session_id) {
    return execute_command( "GET", "/session/$session_id/screenshot", {} );
}
