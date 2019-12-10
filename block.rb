require "json"
require "active_record"
require "./transaction.rb"

class Block
	def self.recieve_block(env)
		puts "\nRecieve Block"

		response = false
		message = "Block's format is not valid"
		
		block = JSON.parse(env['rack.input'].read) rescue nil

		if block.kind_of?(Hash)
			if block_is_valid?(block)
				save_block(block)
				# send_data("/block", block.to_json)
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

	def self.block_is_valid?(block)
		true
		# return hash_is_enough_small?(block) && included_transactions_are_valid?(block) && !block_is_duplicated?(block) && has_parent_block?(block)
	end

	def self.block_is_duplicated?(block)
		duplicated_flag = false
		File.open("./block.txt").each do |post_block|
			if JSON.parse(post_block)["hash"] == block["hash"]
				duplicated_flag = true
				break
			end
		end
		return duplicated_flag
	end

	def self.has_parent_block?(block)
		has_parent_flag = false
		File.open("./block.txt").each do |post_block|
			if JSON.parse(post_block)["hash"] == block["parent_hash"]
				has_parent_flag = true
				break
			end
		end
		return has_parent_flag
	end

	def self.hash_is_enough_small?(block)
		block["hash"].start_with?("000")
	end

	def self.included_transactions_are_valid?(block)
		transactons_are_valid = true
		block["transactions"].each do |transaction|
			unless enough_token?(transaction)
				transactons_are_valid = false
				break
			end
		end
		return transactons_are_valid
	end

	def self.enough_token?(transaction) 
		enough_flag = true
		CSV.read("./ledger.csv", headers: true).each do |account|
			if transaction["from"] == account.to_hash["address"] && account.to_hash["amount"].to_i <= transaction["value"].to_i
				enough_flag = false
				break
			end
			return enough_flag
		end 
	end

	def self.account_is_recognized?(transaction)
		recognized_flag = false

		CSV.read("./ledger.csv", headers: true).each do |account|
			if transaction["from"] == account.to_hash["address"]
				recognized_flag = true
				break
			end
			return enough_flag
		end 
	end

	def self.save_block(block)		
		dir_name = create_lastest_block_name()
		Dir.mkdir("blocks/#{dir_name}")

		transaction_counter = 0
		block["transactions"].each do |transaction|
			FileUtils.copy("./transactions/#{transaction}", "blocks/#{dir_name}/")
			transaction_counter = transaction.slice(0..9).to_i
		end

		CSV.open("blocks/#{dir_name}/header.csv","w") do |csv|
			csv.puts ["hash","nonce","parent_hash"]
			csv.puts [block["hash"], block["nonce"], block["parent_hash"]]
		end

		CSV.open("./transaction_counter.csv", "w") do |csv|
			csv.puts [transaction_counter]
			p transaction_counter
		end

		puts "Saved Block"
	end

	def self.create_block(node_urls)
    block_contents = mining().to_hash

    query = {
        "hash": block_contents[:hash],
        "nonce": block_contents[:nonce],
        "parent_hash": block_contents[:parent_hash],
        "transactions": block_contents[:transactions]
			}.to_json

    route = "/block"
			request_node(query, route, node_urls)
	end

	def self.mining
		sum = 0
		nonce = 0
		transactions = []

			files = Dir.children("./transactions").sort_by! do |file|
				file.slice(0..9).to_i
			end

			transaction_counter = CSV.read("./transaction_counter.csv")[0][0].to_i

			files.slice(transaction_counter, 5).each do |file|
				sum += CSV.read("./transactions/#{file}", headers: true)["transaction_hash"].first.to_i
				transactions.push(file)
			end
			parent_hash = "fffff"
			
		while true
			hash = OpenSSL::Digest.new("sha256").update((nonce + sum).to_s).to_s.slice(1..10)
				if hash.start_with?("00000")
					break
				end
					nonce += 1
			end
			return {"hash": hash, "nonce": nonce, "parent_hash": parent_hash, "transactions": transactions}
	end

	node_urls = ["http://127.0.0.1:4000"]

	def self.request_node(query, route, node_urls)
		node_urls.each do |url|
			res = HTTPClient.post(url+route, query)
			puts res.body
		end
	end

	def self.create_lastest_block_name
		last_block_number = 0
		Dir.children("./blocks").each do |dir|
			last_block_number = dir.slice(0..9).to_i if last_block_number <= dir.slice(0..9).to_i
		end
		return format("%010d", last_block_number + 1) + "_block"
	end

end