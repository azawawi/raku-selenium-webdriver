
#
# JSON Wire Protocol Perl 6 implementation
# Please see 
# https://code.google.com/p/selenium/wiki/JsonWireProtocol
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
  my constant MAX-ATTEMPTS = 10;
  my $session;
  for 1..MAX-ATTEMPTS {
    # Try to create session
    $session = self._new-session;
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
method _new-session {
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
# GET /sessions
method sessions {
  my $result = self._execute-command( "GET", "/sessions" );

  return unless $result.defined;
  return $result<value>;
}

# GET /session/:sessionId
method capabilities {
  return self._execute-command( "GET", "/session/$(self.session-id)" );
}

# DELETE /session/:sessionId
method _delete_session {
  return self._execute-command( "DELETE", "/session/$(self.session-id)" );
}

# POST /session/:sessionId/timeouts
method _timeouts(Str $type, Int $timeout_millis) {
  return self._post(
    'timeouts',
    {
      type => $type,
      ms => $timeout_millis
    }
  );
}

method script-timeout(Int $timeout_millis) {
  return self._timeouts( 'script', $timeout_millis );
}

method implicit-timeout(Int $timeout_millis) {
  return self._timeouts( 'implicit', $timeout_millis );
}

method page-load-timeout(Int $timeout_millis) {
  return self._timeouts( 'page load', $timeout_millis );
}

# POST /session/:sessionId/timeouts/async_script
method async-script-timeout(Int $timeout_millis) {
  return self._post( 'timeouts/async_script', { ms => $timeout_millis } );
}

# POST /session/:sessionId/timeouts/implicit_wait
method implicit-wait-timeout(Int $timeout_millis) {
  return self._post( 'timeouts/implicit_wait', { ms => $timeout_millis } );
}

# GET /session/:sessionId/window_handle
method window-handle returns Str {
  return self._get( 'window_handle' );
}

# GET /session/:sessionId/window_handles
method window-handles returns Array {
  return self._get( 'window_handles' );
}

# GET /status
method status returns Hash {
  return self._get( 'status' );
}

# POST /session/:sessionId/execute
=begin markdown

    my $script = q{
      return arguments[0] + arguments[1];
    };
    my $result = $driver.execute( $script, [1, 2] );

=end markdown
method execute(Str $script, Array $args = []) {
  my $result = self._post( 'execute', { script => $script, args => $args } );
  return unless $result.defined;
  return $result<value>;
}

# POST /session/:sessionId/execute_async
=begin markdown

    my $script = q{
      var callback = arguments[arguments.length-1];
      callback( arguments[0] + arguments[1] );
    };
    my $result = $driver.execute-async( $script, [1, 2] );

=end markdown
method execute-async(Str $script, Array $args = []) {
  my $result = self._post( 'execute_async', { script => $script, args => $args } );
  return unless $result.defined;
  return $result<value>;
}

# GET /session/:sessionId/ime/available_engines
method ime-available-engines returns Array {
  return self._get( 'ime/available_engines' );
}

# GET /session/:sessionId/ime/active_engine
method ime-active-engine returns Str {
  return self._get( 'ime/active_engine' );
}

# GET /session/:sessionId/ime/activated
method ime-activated returns Bool {
  return self._get( 'ime/activated' );
}

# POST /session/:sessionId/ime/deactivate
method ime-deactivate {
  return self._post( 'ime/deactivate' );
}

# POST /session/:sessionId/ime/activate
method ime-activate(Str $engine) {
  return self._post( 'ime/activate', { engine => $engine } );
}

# POST /session/:sessionId/frame
method _frame(Any $id) {
  return self._post( 'frame', { id => $id } );
}

multi method frame(Str $id) {
  return self._frame($id);
}

multi method frame(Int $id) {
  return self._frame($id);
}

multi method frame(Selenium::WebDriver::WebElement $id) {
  return self._frame($id);
}

# POST /session/:sessionId/frame/parent
multi method frame-parent {
  return self._post( 'frame/parent' );
}

=begin markdown
=end markdown
# POST /session/:sessionId/url
multi method url(Str $url) {
  return self._post( "url", { url => $url } );
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
  return self._post(
    "moveto",
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
  return self._post( "click" );
}

=begin markdown
=end markdown
method quit {
  self._delete_session if self.session-id.defined;
  LEAVE {
    $.process.kill if $.process.defined;
  }
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
  return self._post( "forward" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/back
method back {
  return self._post( "back" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/refresh
method refresh {
  return self._post( "refresh" );
}

=begin markdown
=end markdown
# POST /session/:sessionId/element
method _find-element(Str $using, Str $value) {
  my $result = self._post(
    "element",
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

method _die(Str $method, Str $command, Any $message) {
  die ("-" x 80) ~
    "\nError while executing '$method $command':\n" ~
    "$message\n" ~
    ("-" x 80);
}
=begin markdown
=end markdown
method _execute-command(Str $method, Str $command, Hash $params = {}) {
  say "POST $command with params " ~ $params.perl if self.debug;

  my $ua = HTTP::UserAgent.new;
  $ua.timeout = 5;
  my $url = "http://127.0.0.1:" ~ self.port ~ $command;
  my $response;
  if ( $method eq 'POST' ) {
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
        self._die($method, $command, $_);
      }
    }
  }
  elsif ( $method eq 'GET' ) {
    $response = $ua.get( $url );

    CATCH {
      default {
        self._die($method, $command, $_);
      }
    }
  }
  elsif ( $method eq 'DELETE' ) {
    my $request = HTTP::Request.new(
      :DELETE($url),
      :Content-Type("application/json;charset=UTF-8"),
      :Connection("close"),
    );
    $response = $ua.request($request);

    CATCH {
      default {
        self._die($method, $command, $_);
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

method _post(Str $command, Hash $params = {}) {
  return self._execute-command(
    "POST",
    "/session/$(self.session-id)/$command",
    $params
  );
}
