
use v6;

use Selenium::WebDriver::Wire;
use File::Which;
use File::Temp;
use File::Zip;
use Find::Bundled;
use JSON::Tiny;

unit class Selenium::WebDriver::Firefox is Selenium::WebDriver::Wire;

has Proc::Async $.process    is rw;

method start {
  # firefox webdriver extension needs this weird url prefix
  self.url-prefix = "/hub";

  # Find webdriver extension resources in our module installed location
  say 'Finding webdriver location using Find::Bundled' if self.debug;
  my $path = 'Selenium/WebDriver/Firefox/extension';
  my $webdriver-xpi = Find::Bundled.find( 'webdriver.xpi', $path );
  fail "Cannot find webdriver.xpi" unless $webdriver-xpi.defined;
  my $firefox-prefs = Find::Bundled.find( 'prefs.json', $path );
  fail "Cannot find prefs.json" unless $firefox-prefs.defined;

  # Create a temporary folder for our temporary firefox profile
  my ($directory, $dirhandle) = tempdir;

  # unzip webdriver.xpi
  my $profile-path = "$directory/perl6-selenium-webdriver";
  my $extension-path = "$profile-path/extensions/fxdriver@googlecode.com";
  my $prefs-file-name = "$profile-path/user.js";

  # Read firefox json-formatted preferences
  my $prefs = from-json($firefox-prefs.IO.slurp);

  # Create temporary profile path
  $profile-path.IO.mkdir;

  # Modify mutable port that were loaded from prefs.json
  $prefs<mutable><webdriver_firefox_port> = self.port;

  # Write a user.js file in profile path
  my $fh = $prefs-file-name.IO.open(:w);
  for $prefs<frozen>.kv -> $k, $v {
    my $value = to-json($v);
    $fh.say(qq{user_pref("$k", $value);});
  }
  for $prefs<mutable>.kv -> $k, $v {
    my $value = to-json($v);
    $fh.say(qq{user_pref("$k", $value);});
  }
  $fh.close;

  $extension-path.IO.mkdir;

  # Unzip the webdriver extension (XPI file format is simply a ZIP archive)
  say "unzipping $webdriver-xpi into $extension-path";
  my $zip-file = File::Zip.new(file-name => $webdriver-xpi);
  $zip-file.unzip(directory => $extension-path);

  # Setup firefox environment
  # %*ENV<XRE_CONSOLE_LOG> = "firefox.log";
  %*ENV<XRE_PROFILE_PATH> = $profile-path;
  %*ENV<MOZ_CRASHREPORTER_DISABLE> = "1";
  %*ENV<MOZ_NO_REMOTE> = "1";
  %*ENV<NO_EM_RESTART> = "1";

  say "Launching firefox" if self.debug;

  # Find firefox process in PATH
  my $firefox = which("firefox");
  die "Cannot find firefox in your PATH" unless $firefox.defined;

  # Run it asynchrously
  say "Firefox found at '$firefox'" if self.debug;
  my $p = Proc::Async.new($firefox);
  $p.start;

  # And store the process to be able to kill it when we're done
  self.process = $p;
}

method stop {
  self.process.kill if self.process.defined;
}
