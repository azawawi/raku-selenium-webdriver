#!/usr/bin/env perl6

use v6;
use lib 'lib';
use Selenium::WebDriver;

my $driver = Selenium::WebDriver.new;
$driver.set_url("http://google.com");
say "Title: " ~ $driver.get_title;
say "Length of HTML source: " ~ $driver.get_source.chars;
$driver.save_screenshot('test.png');
$driver.quit;
