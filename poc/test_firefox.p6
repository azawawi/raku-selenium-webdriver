#!/usr/bin/env perl6

use v6;

use lib 'lib';
use File::Which;
use File::Temp;

my ($directory,$dirhandle) = tempdir(:!unlink);

# unzip webdriver.xpi
my $webdriver-xpi = "/home/azawawi/perl6-selenium-webdriver/lib/Selenium/WebDriver/Firefox/extension/webdriver.xpi";

my $profile-path = "$directory/my-profile";
my $extension-id = "fxdriver@googlecode.com";
my $extension-path = "$profile-path/extensions/$extension-id";

$extension-path.IO.mkdir;

say $directory;
say $profile-path;
say $extension-path;

run "unzip", "-d", $extension-path, $webdriver-xpi;

run "pcmanfm", $profile-path;

# Setup firefox environment
%*ENV<XRE_PROFILE_PATH> = $profile-path;
%*ENV<MOZ_CRASHREPORTER_DISABLE> = "1";
%*ENV<MOZ_NO_REMOTE> = "1";
%*ENV<NO_EM_RESTART> = "1";

say "Launching firefox";

my $firefox = which("firefox");
say "Firefox found at '$firefox'";
my $p = Proc::Async.new($firefox);
$p.start;

#sleep 5;
