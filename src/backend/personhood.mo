import Types "mo:passport-client-dfinity/lib/Types";
import V "../lib/Verifier";
import Conf "../../Config";

actor Main {
    public shared({caller}) func scoreBySignedEthereumAddress({address: Text; signature: Text; nonce: Text;}): async Text {
        // A real app would store the verified address somewhere instead of just returning the score to frontend.
        // Use `extractItemScoreFromBody` or `extractItemScoreFromJSON` to extract score.
        let body = await* V.scoreBySignedEthereumAddress({
            address;
            signature;
            nonce;
            scorerId = Conf.scorerId;
            transform = removeHTTPHeaders;
        });
        let score = extractItemScoreFromBody(body);
        await* setVotingData(caller, null, { // TODO: Provide partition hint, not `null`.
            points = score;
            lastChecked = Time.now();
            ethereumAddress = address;
        });
    };

    public shared func submitSignedEthereumAddressForScore({address: Text; signature: Text; nonce: Text;}): async Text {
        // A real app would store the verified address somewhere instead of just returning the score to frontend.
        // Use `extractItemScoreFromBody` or `extractItemScoreFromJSON` to extract score.
        let body = await* V.submitSignedEthereumAddressForScore({
            address;
            signature;
            nonce;
            scorerId = Conf.scorerId;
            transform = removeHTTPHeaders;
        });
        let score = extractItemScoreFromBody(body);
        await* setVotingData(caller, null, { // TODO: Provide partition hint, not `null`.
            points = score;
            lastChecked = Time.now();
            ethereumAddress = address;
        });
    };

    public shared func getEthereumSigningMessage(): async {message: Text; nonce: Text} {
        await* V.getEthereumSigningMessage({transform = removeHTTPHeaders});
    };

    public shared query func removeHTTPHeaders(args: Types.TransformArgs): async Types.HttpResponsePayload {
        V.removeHTTPHeaders(args);
    };
}