
use v6;

unit class Selenium::WebDriver::X::Error is Exception;

has $.reason     is rw;
has $.screenshot is rw;
has $.class      is rw;

method message {
 return
   "\n" ~ ("-" x 80) ~ "\n"  ~
   "Error:\n"              ~
   "Reason:  \n"           ~ $.reason ~ "\n" ~
   "Type:  \n"             ~ $.class ~ "\n" ~
   "Has a screenshot:\n  " ~ $.screenshot.defined ~ "\n" ~
   ("-" x 80);
}
