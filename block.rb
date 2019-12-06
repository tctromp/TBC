require "json"

def recieve_block(env)
  puts "Recieve Block"

  response = false
  message = "Block's format is not valid"

  block = JSON.parse(env['rack.input'].read) rescue nil

if block.kind_of?(Hash)
	if block_is_valid?(block)
		save_block(block)
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
	return hash_is_enough_small?(block) && included_transactions_are_valid?(block) && !block_is_duplicated?(block)
end

def block_is_duplicated?(block)
duplicated_flag = false
	File.open("./block.txt").each do |post_block|
		if JSON.parse(post_block)["hash"] == block["hash"]
			duplicated_flag = true
			break
		end
	end
	return duplicated_flag
end

def hash_is_enough_small?(block)
	block["hash"].start_with?("000")
end

def included_transactions_are_valid?(block)
	transactons_are_valid = true
	block["transactions"].each do |transaction|
		unless enough_token?(transaction)
			transactons_are_valid = false
			break
		end
	end
	return transactons_are_valid
end

def enough_token?(transaction) 
	enough_flag = true
	CSV.read("./ledger.csv", headers: true).each do |account|
		if transaction["from"] == account.to_hash["address"] && account.to_hash["amount"].to_i <= transaction["value"].to_i
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

def save_block(block)
	key = ["hash", "nonce", "parent_hash", "transactions"]
	values = [block["hash"], block["nonce"], block["parent_hash"], block["transactions"]]
	p block["parent_hash"]
	p block["transactions"]
	block_json = [key, values].transpose.to_h
	
	File.open("./block.txt", "a") do |file|
		file.puts(block_json.to_json)
	end
end