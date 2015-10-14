#!/usr/bin/env perl6

use v6;
use HTTP::UserAgent;
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
    say "POST $command with params " ~ $params.perl;

    my $response;
    if ( $method eq "POST" ) {

        my $url = "$(URL)$command";
        my $content = to-json($params);

        my $request = HTTP::Request.new(
          :POST($url),
          :Content-Length($content.chars)
          :Content-Type("application/json;charset=UTF-8")
        );
        $request.add-content($content);
        say "\nRequest is:\n" ~ $request.Str;

        my $ua = HTTP::UserAgent.new;
        $response = $ua.request($request);
        say $response.perl;
    }
    elsif ( $method eq "GET" ) {
        $response = LWP::Simple.get( "$(URL)$command" );
    }
    else {
        die qq{Unknown method "$method"};
    }
    
    my $result;
    if ( $response.defined ) {
        $result = from-json( $response );
    }
    else {
        warn "FAILED!";
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
