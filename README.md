NAME
====

CroX::HTTP::FallbackPassthru - dumb passthru proxy middleware for Cro

SYNOPSIS
========

    use Cro::HTTP::Router;
    use Cro::HTTP::Server;
    use CroX::HTTP::FallbackPassthrue;

    my $application = route { ... };
    my $fallback = CroX::HTTP::FallbackPassthru.new(
        forward-uri => Cro::Uri.parse('http://localhost:12345'),
    );

    my Cro::Service $service = Cro::HTTP::Server.new(
        host        => 'localhost',
        port        => 8080,
        application => $application,
        after       => ($fallback,),
    );

    $service.start;

DESCRIPTION
===========

You should probably only ever use this in development. In production there are smarter ways to do reverse proxying. However, if you need a dumb reverse proxy during development, this can do it.

Basically, this is Cro middleware that will try to forward the request on to another server when the router for this application returns a 404. The forwarding is done by making a client call from this server to the forwarded server using the same request object. The response from the client is then passed back through.

METHODS
=======

In case you have some need to extend the middleware, here's a description of the methods.

method forward-uri
------------------

    has Cro::Uri $.forward-uri

This is the URI of the passthrough service.

method should-fallback
----------------------

    method should-fallback(Cro::HTTP::Response $res -> Bool)

Given a response, this determines if fallback to the proxied service should be performed. The default implementation just checks to see if the response status is 404 and returns True in that case. It returns False in all others.

method client-uri
-----------------

    method client-uri(Cro::HTTP::Request $req -> Cro::Uri)

Given a request, it creates the URI that should be contacted to perform the passthru proxying. This is done by appending the path and query of the request to this server to the URI returned by [method forward-uri](#method forward-uri).

method process
--------------

    method process(Supply $responses --> Supply)

This is the method that puts it altogeher.

