require "resolv"
require "json"
require "httpclient"
require "csv"
require "openssl"
require "./connecter.rb"

class Transaction

  def self.recieve_transaction(env)
  puts "\nRecieved transaction"

    ip_addr = Resolv::DNS.new(:nameserver=>'ns1.google.com').getresources("o-o.myaddr.l.google.com", Resolv::DNS::Resource::IN::TXT)[0].strings[0]
    response = false
    message = "Transaction's format is not valid"

    transaction = JSON.parse(env['rack.input'].read) rescue nil
  
    if transaction.kind_of?(Hash)
      if transaction_is_valid?(transaction)
        save_transaction(transaction)
        # send_data("/transaction", transaction.to_json)
        message = "Confirmed"
      else
        message = "Rejected"
      end
      response = true
    end

    response_body = {
      "ip_addr": ip_addr,
      "responce": response,
      "message": message
    }

    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  end

  def self.transaction_is_valid?(transaction)
    !transaction_is_duplicated?(transaction)
    # return !transaction_is_duplicated?(transaction) && enough_token?(transaction)
  end

  def self.transaction_is_duplicated?(transaction)
    duplicated_flag = false
    Dir.children("./transactions").each do |file|
      if CSV.read("./transactions/#{file}", headers: true)["transaction_hash"].first == transaction["hash"]
        duplicated_flag = true
        puts "Transaction is duplicated: #{transaction["hash"]}"
        break
      end
    end
    return duplicated_flag
  end

  def self.enough_token?(transaction)
    enough_flag = true
    
    return enough_flag
  end

  def self.save_transaction(transaction)
    file_name = create_lastest_transaction_name()
    CSV.open("./transactions/#{file_name}","wb") do |csv|
      csv.puts ["from_address","to_address", "value", "transaction_hash", "time_stamp"]
      csv.puts [transaction["from"], transaction["to"], transaction["value"], transaction["hash"], transaction["time_stamp"]]
    end
    puts "Transaction is saved: #{transaction["hash"]}"
  end

  def self.create_lastest_transaction_name()
    last_file_number = 0
    Dir.children("./transactions").each do |file|
      last_file_number = file.slice(0..9).to_i if last_file_number <= file.slice(0..9).to_i
    end
    file_name = format("%010d", last_file_number + 1) + "_transaction.csv"
    return file_name
  end

  def self.create_transaction(query, node_urls)
    route = "/transaction"
    request_node(query, route, node_urls)
  end

  node_urls = ["http://127.0.0.1:4000"]

	def self.request_node(query, route, node_urls)
		node_urls.each do |url|
			res = HTTPClient.post(url+route, query)
			puts res.body
		end
	end
  
end
