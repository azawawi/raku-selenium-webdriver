
use v6;

=begin pod
=end pod
class Selenium::WebDriver {
  use HTTP::UserAgent;
  use JSON::Tiny;
  use MIME::Base64;

  has Int         $.port is rw;
  has Str         $.session_id is rw;
  has Proc::Async $.process is rw;

=begin pod
=end pod
  submethod BUILD( Int :$port = 5555 ) {
    self.port = $port;
    self.process = self.new_phantomjs_process;

    my $result = self.new_session;
    die "Cannot instaniate session" unless $result.defined;

    self.session_id = $result<sessionId>;
    die "Session id is not defined" unless self.session_id.defined;
  }

=begin pod
=end pod
  method new_phantomjs_process {
    my $process = Proc::Async.new('phantomjs', "--webdriver=" ~ $.port);
    $process.start;

    return $process;
  }


=begin pod
=end pod
  # POST /session
  method new_session {
    return self.execute_command(
      "POST",
      "/session",
      {
          "desiredCapabilities"  => {},
          "requiredCapabilities" => {},
      }
    );
  }

=begin pod
=end pod
  # POST /session/:sessionId/url
  method set_url(Str $url) {
    return self.execute_command(
      "POST",
      "/session/$(self.session_id)/url",
      {
          url => $url,
      }
    );
  }

=begin pod
=end pod
  method quit {
    $.process.kill if $.process.defined;
  };

=begin pod
=end pod
  # GET /session/:sessionId/screenshot
  method get_screenshot() {
    return self.execute_command( "GET", "/session/$(self.session_id)/screenshot", {} );
  }

=begin pod
=end pod
  method save_screenshot(Str $filename) {
    my $result = self.get_screenshot();
    die "get_screenshot return result is not defined" unless $result.defined;
    $filename.IO.spurt(MIME::Base64.decode( $result<value> ));
  }

=begin pod
=end pod
  submethod execute_command(Str $method, Str $command, Hash $params) {
    say "POST $command with params " ~ $params.perl;

    my $ua = HTTP::UserAgent.new;
    my $url = "http://127.0.0.1:" ~ self.port ~ $command;
    my $response;
    if ( $method eq "POST" ) {
        my $content = to-json($params);
        my $request = HTTP::Request.new(
          :POST($url),
          :Content-Length($content.chars),
          :Content-Type("application/json;charset=UTF-8"),
          :Connection("close"),
        );
        $request.add-content($content);
        $response = $ua.request($request);
    }
    elsif ( $method eq "GET" ) {
      $response = $ua.get( $url );
    }
    else {
      die qq{Unknown method "$method"};
    }

    my $result;
    if ( $response.is-success ) {
        $result = from-json( $response.content );
    }
    else {
        warn "FAILED: " ~ $response.status-line;
    }

    return $result;
  }

}
