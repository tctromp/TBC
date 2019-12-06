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
  return hash_is_enough_small?(block) && included_transactions_are_valid?(block)
end

def hash_is_enough_small?(block)
    block["hash"].start_with?("000")
end

def included_transactions_are_valid?(block)
    transactons_are_valid = true
    block["transactions"].each do |transaction|
        unless enough_token?(ransaction)
            transactons_are_valid = falsebreak
        end
    end
    return transactons_are_valid
end

def enough_token?(transaction) 
    enough_flag = true
    CSV.read("./ledger.csv", headers: true).each do |account|
        if transaction["from"] == account.to_hash["address"] && account.to_hash["amount"] <= transaction["value"].to_i
            enough_flag = false
            break
        end
        return enough_flag
    end 
end

def account_is_recognized?(transaction)
    recognized_flag = false

    CSV.read("./ledger.csv", headers: true).each do |account|
        if transaction["from"] == account.to_hash["address"]
            recognized_flag = true
            break
        end
        return enough_flag
    end 
end