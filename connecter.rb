def routing(env)
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

def send_data(type, json_data)
  node_urls = ["http://127.0.0.1:4001"]

  node_urls.each do |url|
    client = HTTPClient.new
    response = client.post(url + type, json_data)
  end
end