## Selenium::WebDriver

[![Build Status](https://travis-ci.org/azawawi/perl6-selenium-webdriver.svg?branch=master)](https://travis-ci.org/azawawi/perl6-selenium-webdriver)

This module provides the [Perl 6](http://perl6.org) bindings for the [Selenium WebDriver Wire ](https://code.google.com/p/selenium/wiki/JsonWireProtocol) protocol.

***Note:*** This module is a work in progress. Please see [Status](https://github.com/azawawi/perl6-selenium-webdriver/blob/master/README.md#status).

## Example

```Perl6
use Selenium::WebDriver::PhantomJS;

my $driver = Selenium::WebDriver::PhantomJS;
$driver.url("http://google.com");
say "Title: "         ~ $driver.title;
say "URL: "           ~ $driver.url;
say "Source length: " ~ $driver.source.chars;
$driver.save_screenshot('test.png');
$driver.quit;
```

For more examples, please see the [examples](examples) folder.

## PhantomJS Installation

### Linux/Debian

To install phantomjs on debian, please type the following:
```
$ sudo apt-get install phantomjs
```

**CAUTION**: Also there are [prebuilt binaries](
https://bitbucket.org/ariya/phantomjs/downloads) for PhantomJS for Linux if the packaged version is a bit old.

### Windows

To install phantomjs on windows, please download a copy from
http://phantomjs.org/ and then make it available in your PATH environment
variable.

### Travis CI

Travis CI comes with [pre-installed PhantomJS](
http://docs.travis-ci.com/user/gui-and-headless-browsers/#Using-PhantomJS).
No special instructions are needed.

## Status

| Web Driver    | Status        |
| ------------- | ------------- |
| PhantomJS     | working       |
| Firefox       | Pending       |
| Chrome        | Pending       |
| Safari        | Pending       |
| Opera         | Pending       |
| MSIE          | Pending       |
| MSEdge        | Pending       |

## Installation

To install it using Panda (a module management tool bundled with Rakudo Star):

```
$ panda update
$ panda install Selenium::WebDriver
```

## Testing

To run tests:

```
$ prove -e perl6
```

## Author

Ahmad M. Zawawi, azawawi on #perl6, https://github.com/azawawi/

## License

Artistic License 2.0
