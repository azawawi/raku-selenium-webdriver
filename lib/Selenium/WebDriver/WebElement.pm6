
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
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/value",
    {
      "value" => $keys.split('');
    }
  );
}

# GET /session/:sessionId/element/:id/name
method tag-name {
  return $.driver._execute-get(
    "element/$($.id)/name",
  );
}

# GET /session/:sessionId/element/:id/selected
method selected {
  return $.driver._execute-get(
    "element/$.id/selected",
  );
}

# GET /session/:sessionId/element/:id/enabled
method enabled {
  return $.driver._execute-get(
    "element/$($.id)/enabled",
  );
}

# GET /session/:sessionId/element/:id/attribute/:name
method attr(Str $name) {
  return $.driver._execute-get(
    "element/$($.id)/attribute/$name",
  );
}

# GET /session/:sessionId/element/:id/equals/:other
method equals-by-id(Str $id) {
  return $.driver._execute-get(
    "element/$($.id)/equals/$id",
  );
}

# GET /session/:sessionId/element/:id/displayed
method displayed {
  return $.driver._execute-get(
    "element/$($.id)/displayed",
  );
}

# GET /session/:sessionId/element/:id/location
method location {
  return $.driver._execute-get(
    "element/$($.id)/location",
  );
}

# GET /session/:sessionId/element/:id/location_in_view
method location-in-view {
  return $.driver._execute-get(
    "element/$($.id)/location_in_view",
  );
}

# GET /session/:sessionId/element/:id/size
method size(Str $id) {
  return $.driver._execute-get(
    "element/$($.id)/size",
  );
}

# GET /session/:sessionId/element/:id/css/:propertyName
method css(Str $property-name) {
  return $.driver._execute-get(
    "element/$($.id)/css/$property-name",
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
method text {
  return $.driver._execute-get(
    "element/$($.id)/text",
  );
}

method clear {
  return $.driver._execute-command(
    "POST",
    "/session/$($.driver.session-id)/element/$($.id)/clear",
  );
}
