require "json"
require "active_record"
require "./transaction.rb"

ActiveRecord::Base.establish_connection(
	:adapter=>"mysql2",
	:host  =>"localhost",
	:database =>"tbc",
	:username=>"root",
	:password=>"",
)

class Block < ActiveRecord::Base
	def self.recieve_block(env)
		puts "Recieve Block"

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
		new_block = Block.create(block_hash: block["hash"], nonce: block["nonce"], parent_hash: block["parent_hash"])
		block["transactions"].each do |transaction|
			Transaction.find_by(transaction_hash: transaction.hash).block_hash = new_block.block_hash unless Transaction.find_by(transaction_hash: transaction.hash).class != nil
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

		Transaction.all.limit(10).each do |transaction|
			sum += transaction.transaction_hash.hex
			transactions.push(transaction.to_json)
		end

    parent_hash = Transaction.last.transaction_hash

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

end