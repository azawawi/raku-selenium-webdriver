
use v6;

unit class Selenium::WebDriver::WebElement;

has Str $.id is rw;
has $.driver is rw;

# POST /session/:sessionId/element/:id/click
method click {
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/click",
  );
}

# POST /session/:sessionId/element/:id/value
method send-keys(Str $keys) {
  say "/session/$($.driver.session-id)/element/$($.id)/value";
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/value",
    {
      "value" => $keys.split('');
    }
  );
}

# POST /session/:sessionId/element/:id/submit
method submit {
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/submit",
  );
}

# GET /session/:sessionId/element/:id/text
method get-text {
  return $.driver._execute-get(
    "element/$($.id)/text",
  );
}

method get-value {
  !!!
}

method clear {
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/clear",
  );
}
