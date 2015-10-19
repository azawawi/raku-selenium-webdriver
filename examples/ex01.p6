#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver::PhantomJS;
use Selenium::WebDriver::Keys;

my $driver = Selenium::WebDriver::PhantomJS.new;

$driver.set-url("http://google.com");
say "Title: "         ~ $driver.title;
say "URL: "           ~ $driver.url;
say "Source length: " ~ $driver.source.chars;

my $search-box = $driver.find-element-by-name( 'q' );
$search-box.send-keys("Perl 6");
$search-box.send-keys(%Keys<ENTER>);
say "Search box contents: "  ~ $search-box.text.perl;
$search-box.submit;

say "Title (After search): " ~ $driver.title;

$driver.save-screenshot('test.png');

LEAVE {
  say 'Cleanup';
  $driver.quit if $driver.defined;
}
