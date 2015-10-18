#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver::PhantomJS;
use Selenium::WebDriver::Keys;

my $driver = Selenium::WebDriver::PhantomJS.new;

$driver.set-url("http://google.com");
say "Title: "         ~ $driver.get-title;
say "URL: "           ~ $driver.get-url;
say "Source length: " ~ $driver.get-source.chars;

my $search-box = $driver.find-element-by-name( 'q' );
$search-box.send-keys("Perl 6");
$search-box.send-keys(%KEYS<ENTER>);
say "Search box contents: "  ~ $search-box.get-text.perl;
$search-box.submit;

say "Title (After search): " ~ $driver.get-title;

$driver.save-screenshot('test.png');

LEAVE {
  say 'Cleanup';
  $driver.quit if $driver.defined;
}
