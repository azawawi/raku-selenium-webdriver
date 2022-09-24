use v6;
use Selenium::WebDriver::Wire;

unit class Selenium::WebDriver::BlackBerry is Selenium::WebDriver::Wire;

method new(
  Str $host,
  Int :$port   = 1338,
  Bool :$debug = False )
{
  self.bless: :$host, :$port, :$debug
}

method start {
  say "Launching BlackBerry Driver on $.host():$.port()" if self.debug;
}

method stop {
}

# GET /sessions
method sessions {
  my $result = self._execute-command( "GET", "/sessions" );

  return unless $result.defined;
  return $result;
}

# We just pick the first active session here, or create a new one.
method _new-session {
  my $sessions = self.sessions;
  if $sessions -> [$s] {
    return { sessionId => ~$s<id> }
  }

  return self._execute-command(
    "POST",
    "/session",
    {
        "desiredCapabilities"  => {},
        "requiredCapabilities" => {},
    }
  );
}
