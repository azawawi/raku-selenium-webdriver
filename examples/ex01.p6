#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver::PhantomJS;

my $driver = Selenium::WebDriver::PhantomJS.new;

$driver.set_url("http://google.com");
say "Title: "         ~ $driver.get_title;
say "URL: "           ~ $driver.get_url;
say "Source length: " ~ $driver.get_source.chars;

$driver.move_to('', 100, 100);
$driver.click;

say $driver.find_element_by_name( 'q' ).perl;
say $driver.find_element_by_id( 'lst-ib' ).perl;

$driver.save_screenshot('test.png');

LEAVE {
  say 'Cleanup';
  $driver.quit if $driver.defined;
}
