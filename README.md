## Selenium::WebDriver

This module provides the [Perl 6](http://perl6.org) bindings for the [Selenium WebDriver Wire Protocol](https://github.com/SeleniumHQ/selenium/wiki/JsonWireProtocol).

***Note:*** This module is a work in progress. Please see its project status [here](https://github.com/azawawi/perl6-selenium-webdriver/blob/master/README.md#project-status).

## Build Status

| Operating System  |   Build Status  | CI Provider |
| ----------------- | --------------- | ----------- |
| Linux / Mac OS X  | [![Build Status](https://travis-ci.org/azawawi/perl6-selenium-webdriver.svg?branch=master)](https://travis-ci.org/azawawi/perl6-selenium-webdriver)  | Travis CI |
| Windows 7 64-bit  | [![Build status](https://ci.appveyor.com/api/projects/status/github/azawawi/perl6-selenium-webdriver?svg=true)](https://ci.appveyor.com/project/azawawi/perl6-selenium-webdriver/branch/master)  | AppVeyor |

## Example

```Perl6
use v6;
use Selenium::WebDriver::PhantomJS;

my $driver = Selenium::WebDriver::PhantomJS.new;
$driver.url("http://google.com");
say "Title: "         ~ $driver.title;
say "URL: "           ~ $driver.url;
say "Source length: " ~ $driver.source.chars;
$driver.save-screenshot('test.png');
LEAVE {
  $driver.quit if $driver.defined
};
```

For more examples, please see the [examples](examples) folder.

## PhantomJS Installation

### Linux/Debian

To install phantomjs on Debian, please type the following:
```
$ sudo apt-get install phantomjs
```

**CAUTION**: Also there are [prebuilt binaries](
https://bitbucket.org/ariya/phantomjs/downloads) for PhantomJS for Linux if the packaged version is a bit old.

### Windows

To install PhantomJS on windows, please download a copy from
[Here](http://phantomjs.org/) and then make it available in your PATH environment
variable.

### Mac OS

To install PhantomJS on mac os, the simplest solution is to use brew:
```
$ brew update
$ brew install phantomjs
```

### Travis CI

Travis CI comes with [pre-installed PhantomJS](
http://docs.travis-ci.com/user/gui-and-headless-browsers/#Using-PhantomJS).
No special instructions are needed.

## Project Status

| Web Driver    | Status        |
| ------------- | ------------- |
| PhantomJS     | **DONE** but needs more tests |
| Firefox       | **DONE** |
| Chrome        | **DONE** but needs external [chromedriver](https://sites.google.com/a/chromium.org/chromedriver/) |
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
$ prove -v -e "perl6 -Ilib"
```

## Author

Ahmad M. Zawawi, [azawawi](https://github.com/azawawi/) on #perl6

## License

MIT License
