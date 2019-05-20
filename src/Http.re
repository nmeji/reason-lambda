[@bs.deriving abstract]
type response = {
  statusCode: int,
  body: string,
};

let buildResponse = (~statusCode, ~body) => {
  return response(statusCode, body);
};