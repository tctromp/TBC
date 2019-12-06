require "./transaction.rb"
require "./block.rb"
require "./request.rb"

app do |env|
  case env["REQUEST_PATH"]
  when "/transaction"
    recieve_transaction(env)
  when "/block"
    recieve_block(env)
  else
    message = "Not Found"

    response_body = {
      "message": message
    }
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  end
end
