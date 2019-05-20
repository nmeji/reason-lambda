open Belt;

[@bs.deriving abstract]
type helloResponse = { message: string };

let hello = (_event, _context, callback) => {
  let payload = (message) => {
    helloResponse(~message=message)
    |. Js.Json.stringifyAny
    |. Option.getExn;
  };
  callback(Js.Nullable.null, Http.buildResponse(
    ~statusCode = 200,
    ~body = payload("Hello, world!"),
  ));
};