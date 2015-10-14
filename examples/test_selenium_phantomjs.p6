#!/usr/bin/env perl6

use v6;
use HTTP::Tinyish;
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
say $method;
    my $response;
    if ( $method eq "POST" ) {

        my $http = HTTP::Tinyish.new;
        my $url = "$(URL)$command";
        my $content = to-json($params);

        $response = $http.post:
          $url,
          headers => { "Content-Type" => "application/json;charset=UTF-8", "Content-Length" => $content.chars },
          content => $content,
        ;
        say "done!";
    }
    elsif ( $method eq "GET" ) {
        $response = LWP::Simple.get( "$(URL)$command" );
    }
    else {
        die qq{Unknown method "$method"};
    }
    
    my $result;
    if ( $response.defined ) {
      say $response.perl;
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
