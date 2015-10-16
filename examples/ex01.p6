#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver;

my $driver = Selenium::WebDriver.new;

$driver.set_url("http://google.com");
say "Title: "         ~ $driver.get_title;
say "URL: "           ~ $driver.get_url;
say "Source length: " ~ $driver.get_source.chars;

$driver.move_to('', 100, 100);
$driver.click;

$driver.save_screenshot('test.png');
$driver.quit;
