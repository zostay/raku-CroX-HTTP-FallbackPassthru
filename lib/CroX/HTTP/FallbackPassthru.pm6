use Cro::HTTP::Middleware;
use Cro::HTTP::Request;
use Cro::HTTP::Response;
use Cro::Uri::HTTP;

class CroX::HTTP::FallbackPassthru does Cro::HTTP::Middleware::Response {
    has Cro::Uri::HTTP $.forward-uri;

    method should-fallback(Cro::HTTP::Response $response --> Bool) {
        $response.status == 404
    }

    method client-uri(Cro::HTTP::Request $request --> Cro::Uri) {
        my $request-uri = URI.new($request.target);
        $!forward-uri.clone(
            path  => "$!forward-uri.path()/$request.path()",
            query => $request.query,
        );
    }

    method process(Supply:D $responses) {
        use Cro::HTTP::Client;

        my $client = Cro::HTTP::Client.new(
            :host($!forward-uri.host),
            :port($!forward-uri.port),
        );

        supply {
            whenever $responses -> $response {
                if self.should-fallback($response) && $response.request -> $request {
                    my $uri = self.client-uri($request),
                    my $res = await $client.request($request.method, $uri);
                    emit $res;
                }
                else {
                    emit $response;
                }
            }
        }
    }
}
