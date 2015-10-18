#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver::PhantomJS;

my $driver = Selenium::WebDriver::PhantomJS.new;

$driver.set_url("http://google.com");
say "Title: "         ~ $driver.get_title;
say "URL: "           ~ $driver.get_url;
say "Source length: " ~ $driver.get_source.chars;

my $search_box = $driver.find_element_by_name( 'q' );
$search_box.send_keys("Perl 6\x0007");
sleep 1;
say "Search box contents: "  ~ $search_box.get_text.perl;
$search_box.submit;

sleep 1;
say "Title (After search): " ~ $driver.get_title;

$driver.save_screenshot('test.png');

LEAVE {
  say 'Cleanup';
  $driver.quit if $driver.defined;
}
