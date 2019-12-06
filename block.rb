def recieve_block(env)
  puts "Recieve Block"

  response = false
  message = "Block's format is not valid"

  block = JSON.parse(env['rack.input'].read) rescue nil

  if block.kind_of?(Hash)
    if block_is_valid?(block)
        message = "Block is valid"
    else
        message = "Block is invalid"
    end
    response = true
  end

  response_body = {
      "message": message
  }
  [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
end

def block_is_valid?(block)
  return block["hash"].start_with?("000")
end