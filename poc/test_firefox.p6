#!/usr/bin/env perl6

use v6;

use lib 'lib';
use File::Which;
use File::Temp;
use JSON::Tiny;
use Selenium::WebDriver::Wire;

my ($directory, $dirhandle) = tempdir;

# unzip webdriver.xpi
my $webdriver-xpi = "lib/Selenium/WebDriver/Firefox/extension/webdriver.xpi";

my $profile-path = "$directory/my-profile";
my $extension-id = "fxdriver@googlecode.com";
my $extension-path = "$profile-path/extensions/$extension-id";
my $prefs-file-name = "$profile-path/user.js";

# Read firefox json-formatted preferences
my $firefox-prefs = "lib/Selenium/WebDriver/Firefox/extension/prefs.json";
my $prefs = from-json($firefox-prefs.IO.slurp);

$profile-path.IO.mkdir;

# Modify port...
my $webdriver-firefox-port = 54243;
$prefs<mutable><webdriver_firefox_port> = $webdriver-firefox-port;

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

say $directory;
say $profile-path;
say $extension-path;

run "unzip", "-d", $extension-path, $webdriver-xpi;

# run "pcmanfm", $profile-path;

# Setup firefox environment
# %*ENV<XRE_CONSOLE_LOG> = "firefox.log";
%*ENV<XRE_PROFILE_PATH> = $profile-path;
%*ENV<MOZ_CRASHREPORTER_DISABLE> = "1";
%*ENV<MOZ_NO_REMOTE> = "1";
%*ENV<NO_EM_RESTART> = "1";

say "Launching firefox";

my $firefox = which("firefox");
say "Firefox found at '$firefox'";
my $p = Proc::Async.new($firefox);
$p.start;

sleep 5;

say "Creating connection!";
my $driver = Selenium::WebDriver::Wire.new(
  :port($webdriver-firefox-port),
  :url-prefix("/hub"));
$driver.url("http://doc.perl6.org");

say "Done!";

