vcl 4.1;
import std;
import dynamic;

backend default {
	.host = "";
	.probe = { 
		.url = "/";
		.timeout = 1s;
		.interval = 30s;
		.window = 5;
		.threshold = 3; 
	}
}

sub vcl_backend_response {
	set beresp.ttl = 5m;

	if (bereq.url ~ "/postimage.php" || bereq.url ~ "/postimage.php") {
		set beresp.ttl = 24h;
	}

	set beresp.grace = 12h;
	// no keep - the grace should be enough for 304 candidates
}

sub vcl_init {
  new ddir = dynamic.director(
    port = "8000",
    ttl = 30s,
  );
}

sub vcl_recv {
	set req.backend_hint = ddir.backend("web");

	if (std.healthy(req.backend_hint)) {
		// change the behavior for healthy backends: Cap grace to 10s
		set req.grace = 10s;
	}
}
