Selenium::WebDriver
===============

[![Build Status](https://travis-ci.org/azawawi/perl6-selenium-webdriver.svg?branch=master)](https://travis-ci.org/azawawi/perl6-selenium-webdriver)

Note: This module is experimental at the moment. The target for it to work on
phantomjs and then Firefox, Chrome and IE web drivers.

This provides the Perl 6 bindings for Selenium WebDriver.

## Example

```Perl6
use Selenium::WebDriver;

my $driver = Selenium::WebDriver.new;
$driver.set_url("http://google.com");
$driver.quit;

```

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

    panda update
    panda install Selenium::WebDriver

## Testing

To run tests:

    prove -e perl6

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

Artistic License 2.0
