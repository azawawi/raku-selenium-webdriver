#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Test;
plan 5;
use Selenium::WebDriver::Chrome;

# Create new Chrome webdriver. Please note chromedriver must be already
# installed and configured in PATH
my $driver = Selenium::WebDriver::Chrome.new;

# Navigate to google.com
$driver.url( "http://google.com" );
ok $driver.title ~~ / 'Google' /,                "Google in title";
ok $driver.url   ~~ / ^ 'https://' .+? 'google'/, "google.com in url";

# Find search box and then type "Perl 6" in it
my $search-box = $driver.element-by-name( 'q' );
$search-box.send-keys( "Perl 6" );

ok $search-box.tag-name.lc eq 'input', "Search box must be an <input>";
ok $search-box.enabled,             "Search box is enabled";

# Submit form
$search-box.submit;

# Take a screenshot
my $filename = 'output.png';
$driver.save-screenshot( $filename );
ok $filename.IO ~~ :e, "$filename exists";

LEAVE {
  diag 'WebDriver cleanup';
  $driver.quit if $driver.defined;
}
