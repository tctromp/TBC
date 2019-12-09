require "resolv"
require "json"
require "httpclient"
require "csv"
require "openssl"
require "active_record"
require "./connecter.rb"

ActiveRecord::Base.establish_connection(
	:adapter=>"mysql2",
	:host  =>"localhost",
	:database =>"tbc",
	:username=>"root",
	:password=>"",
)

class Transaction < ActiveRecord::Base

  def self.recieve_transaction(env)
  puts "Recieved transaction"

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
    return !transaction_is_duplicated?(transaction)
    # return !transaction_is_duplicated?(transaction) && enough_token?(transaction)
  end

  def self.transaction_is_duplicated?(transaction)
    duplicated_flag = false

    Transaction.all.each do |post_transaction|
      if post_transaction.transaction_hash == transaction["hash"]
        duplicated_flag = true
        puts "Transaction is duplicated: #{transaction["hash"]}"
        break
      end
    end
    return duplicated_flag
  end

# 十分な通貨を持っているか確認
  def self.enough_token?(transaction)
    enough_flag = true
    CSV.read("./ledger.csv", headers: true).each do |account|
      if account.to_hash["address"] == transaction["from"] && account.to_hash["amount"].to_i <= transaction["value"].to_i
        enought_flag = false
        break
      end
    end
    return enough_flag
  end

  def self.save_transaction(transaction)
    Transaction.create(from_address: transaction["from"], to_address: transaction["to"], value: transaction["value"], transaction_hash: transaction["hash"], time_stamp: transaction["time_stamp"])
    puts "Transaction is saved: #{transaction["hash"]}"
  end
  

end
