#!/usr/bin/env perl

use Modern::Perl;
use LWP::UserAgent;
use JSON::Tiny qw(decode_json encode_json);
use MIME::Base64;
use Data::Printer;

#my $port = 5555;
#my $cmd = qq{phantomjs --webdriver=$port};


my $URL = "http://127.0.0.1:5555";

my $session_obj = session();
die "Cannot instaniate session" unless defined($session_obj);

my $session_id = $session_obj->{sessionId};
die "Session id is null" unless defined($session_id);

my $o;
$o = set_url( $session_id, "http://google.com" );

$o = get_screenshot($session_id);
open my $fh, ">", "screenshot01.png";
binmode($fh);
print $fh decode_base64( $o->{value} );
close $fh;

# POST /session
sub session {
    return execute_command(
        "POST",
        "/session",
        {
            "desiredCapabilities"  => {},
            "requiredCapabilities" => {},
        }
    );
}

sub execute_command {
    my $method  = shift or die "'method' parameter is not found";
    my $command = shift or die "'command' parameter is not found";
    my $params  = shift or die "'params' parameter is not found";

    my $ua = LWP::UserAgent->new(requests_redirectable   => ['GET', 'HEAD', 'POST']);
    my $res;
    if ( $method eq "POST" ) {
        $res = $ua->post( "$URL$command", Content => encode_json($params) );
    }
    elsif ( $method eq "GET" ) {
        $res = $ua->get( "$URL$command", Content => encode_json($params) );
    }
    else {
        die qq{Unknown method "$method"};
    }

    my $result;
    if ( $res->is_success ) {
        $result = decode_json( $res->content );
    }
    else {
        warn "ERROR: " . $res->status_line;
    }

    #p($result);

    return $result;
}

# POST /session/:sessionId/url
sub set_url {
    my $session_id = shift or die q{'session_id' parameter is not found};
    my $url        = shift or die q{'url' parameter is not found};

    return execute_command(
        "POST",
        "/session/$session_id/url",
        {
            url => $url,
        }
    );
}

# GET /session/:sessionId/screenshot
sub get_screenshot {
    my $session_id = shift or die q{'session_id' parameter is not found};

    return execute_command( "GET", "/session/$session_id/screenshot", {} );
}

