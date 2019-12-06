require "resolv"
require "json"
require "httpclient"
require "csv"
require "openssl"

def recieve_transaction(env)
  puts "Recieved transaction"

    ip_addr = Resolv::DNS.new(:nameserver=>'ns1.google.com').getresources("o-o.myaddr.l.google.com", Resolv::DNS::Resource::IN::TXT)[0].strings[0]
    response = false
    message = "Transaction's format is not valid"

    transaction = JSON.parse(env['rack.input'].read) rescue nil
  
    if transaction.kind_of?(Hash)
      if transaction_is_valid?(transaction)
        save_transaction(transaction)
        send_transaction(transaction)
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

def transaction_is_valid?(transaction)
  return !transaction_is_duplicated?(transaction) && enough_token?(transaction)
end

def transaction_is_duplicated?(transaction)
  duplicated_flag = false

  CSV.read("./transactions.csv", headers: true).each do |post_transaction|
    if post_transaction.to_hash["hash"] == transaction["hash"]
      duplicated_flag = true
      puts "Transaction is duplicated: #{transaction["hash"]}"
      break
    end
  end
  return duplicated_flag
end

def enough_token?(transaction)
  enough_flag = true
  CSV.read("./ledger.csv", headers: true).each do |account|
    if account.to_hash["address"] == transaction["from"] && account.to_hash["amount"].to_i <= transaction["value"].to_i
      enought_flag = false
      break
    end
  end
  return enough_flag
end

def save_transaction(transaction)
  CSV.open("./transactions.csv","a") do |log|
    log.puts [transaction["from"], transaction["to"], transaction["value"], transaction["hash"], transaction["time_stamp"]]
  end
  puts "Transaction is saved: #{transaction["hash"]}"
end

def send_transaction(transaction)
  node_urls = ["http://127.0.0.1:4001/transaction"]

  node_urls.each do |url|
    client = HTTPClient.new
    query  = transaction.to_json
    response = client.post(url, query)
  end
end
