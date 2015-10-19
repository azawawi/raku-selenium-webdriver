
#
# JSON Wire Protocol Perl 6 implementation
# Please see 
# https://code.google.com/p/selenium/wiki/JsonWireProtocol#/session/:sessionId/forward
#

use v6;

=begin markdown
=end markdown
unit class Selenium::WebDriver::Wire;

use HTTP::UserAgent;
use JSON::Tiny;
use MIME::Base64;
use Selenium::WebDriver::WebElement;

has Bool        $.debug      is rw;
has Int         $.port       is rw;
has Str         $.session-id is rw;
has Proc::Async $.process    is rw;

=begin markdown
=end markdown
submethod BUILD( Int :$port = 5555, Bool :$debug = False ) {
  self.debug   = $debug;
  self.port    = $port;
  self.process = self.new-phantomjs-process;

  # Try to create a new phantomjs session for n times
  my constant MAX-ATTEMPTS = 3;
  my $session;
  for 1..MAX-ATTEMPTS {
    # Try to create session
    $session = self.new-session;
    last if $session.defined;

    CATCH {
      default {
        # Retry session creation failure after timeout
        say "Attempt $_ to create session" if self.debug;
        sleep 1;
      }
    }
  }

  # No session could be created
  die "Cannot obtain a session after $(MAX-ATTEMPTS) attempts" unless $session.defined;

  self.session-id = $session<sessionId>;
  die "Session id is not defined" unless self.session-id.defined;
}

=begin markdown
=end markdown
method new-phantomjs-process {
  say "Starting phantomjs process" if $.debug;
  my $process = Proc::Async.new(
    'phantomjs',
    "--webdriver=" ~ $.port,
    "--webdriver-loglevel=" ~ ($.debug ?? "DEBUG" !! "WARN"),
  );
  $process.start;

  return $process;
}

=begin markdown
=end markdown
# POST /session
method new-session {
  return self._execute-command(
    "POST",
    "/session",
    {
        "desiredCapabilities"  => {},
        "requiredCapabilities" => {},
    }
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/url
multi method url(Str $url) {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/url",
    {
        url => $url,
    }
  );
}

=begin markdown
=end markdown
# GET /session/:sessionId/url
multi method url {
  return self._get( 'url' );
}

=begin markdown
=end markdown
# GET /session/:sessionId/title
method title {
  return self._get( 'title' );
}

=begin markdown
=end markdown
# GET /session/:sessionId/source
method source {
  return self._get( 'source' );
}

=begin markdown
=end markdown
# POST /session/:sessionId/moveto
method move-to(Str $element, Int $xoffset, Int $yoffset) {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/moveto",
    {
        element => $element,
        xoffset => $xoffset,
        yoffset => $yoffset,
    }
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/click
method click {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/click",
  );
}

=begin markdown
=end markdown
method quit {
  #TODO kill session
  $.process.kill if $.process.defined;
};

=begin markdown
=end markdown
# GET /session/:sessionId/screenshot
method screenshot {
  return self._get('screenshot');
}

=begin markdown
=end markdown
method save-screenshot(Str $filename) {
  my $result = self.screenshot;
  $filename.IO.spurt(MIME::Base64.decode( $result ));
}


=begin markdown
=end markdown
# POST /session/:sessionId/forward
method forward {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/forward",
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/back
method back {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/back",
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/refresh
method refresh {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/refresh",
  );
}

=begin markdown
=end markdown
# POST /session/:sessionId/element
method _find-element(Str $using, Str $value) {
  my $result = self._execute-command(
    "POST",
    "/session/$(self.session-id)/element",
    {
      'using' => $using,
      'value' => $value,
    }
  );

  return unless $result.defined;
  return Selenium::WebDriver::WebElement.new(
    :id( $result<value><ELEMENT> ),
    :driver( self )
  );
}

=begin markdown
=end markdown
method find-element-by-class(Str $class) {
  return self._find-element( 'class name', $class );
}

=begin markdown
=end markdown
method find-element-by-css(Str $selector) {
  return self._find-element( 'css selector', $selector );
}

=begin markdown
=end markdown
method find-element-by-id(Str $id) {
  return self._find-element( 'id', $id );
}

=begin markdown
=end markdown
method find-element-by-name(Str $name) {
  return self._find-element( 'name', $name );
}

=begin markdown
=end markdown
method find-element-by-link-text(Str $link-text) {
  return self._find-element( 'link text', $link-text );
}

=begin markdown
=end markdown
method find-element-by-partial-link-text(Str $partial-link-text) {
  return self._find-element( 'partial link text', $partial-link-text );
}

=begin markdown
=end markdown
method find-element-by-tag-name(Str $tag-name) {
  return self._find-element( 'tag name', $tag-name );
}

=begin markdown
=end markdown
method find-element-by-xpath(Str $xpath) {
  return self._find-element( 'xpath', $xpath );
}

=begin markdown
=end markdown
method _execute-command(Str $method, Str $command, Hash $params = {}) {
  say "POST $command with params " ~ $params.perl if self.debug;

  my $ua = HTTP::UserAgent.new;
  $ua.timeout = 5;
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

    CATCH {
      default {
        say "Error while executing '$method $command': $_" if self.debug;
      }
    }
  }
  elsif ( $method eq "GET" ) {
    $response = $ua.get( $url );

    CATCH {
      default {
        say "Error while executing '$method $command': $_" if self.debug;
      }
    }
  }
  else {
    die qq{Unknown method "$method"};
  }

  # Since we didnt get a response here, return nothing
  return unless $response.defined;

  my $result;
  if ( $response.is-success ) {
      $result = from-json( $response.content );
  }
  else {
      warn "FAILED: " ~ $response.status-line if self.debug;
  }

  return $result;
}

method _get(Str $command) {
  my $result = self._execute-command(
    "GET",
    "/session/$(self.session-id)/$command",
  );

  return unless $result.defined;
  return $result<value>;
}
