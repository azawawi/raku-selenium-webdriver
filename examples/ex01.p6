#!/usr/bin/env perl6

use v6;

use lib 'lib';
use Test;
plan 6;
use Selenium::WebDriver::PhantomJS;
use Selenium::WebDriver::Keys;

# Create new phantomjs webdriver. Please note phantomjs must be already
# installed
my $driver = Selenium::WebDriver::PhantomJS.new;

# Navigate to google.com
$driver.url("http://google.com");
ok $driver.title ~~ "Google", "Google in title";
ok $driver.url ~~ / ^ 'http://' .+? 'google'/, "google.com in selected url";

# Find search box and then type "Perl 6" in it
my $search-box = $driver.find-element-by-name( 'q' );
$search-box.send-keys("Perl 6");
$search-box.send-keys(%Keys<ENTER>);

ok $search-box.tag-name eq 'input', "Search box must be an <input>";
ok $search-box.enabled,             "Search box is enabled";

# Submit form
$search-box.submit;

# Verify that our submission worked
ok $driver.title ~~ /'Perl 6'/, "Perl 6 in search results page";

# Take a screenshot
my $filename = 'output.png';
$driver.save-screenshot($filename);
ok $filename.IO ~~ :e, "$filename exists";

LEAVE {
  diag 'WebDriver cleanup';
  $driver.quit if $driver.defined;
}
