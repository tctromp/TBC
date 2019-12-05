require "resolv"
require "json"
require "httpclient"
require "csv"
require "openssl"

app do |env| 
  p "Recieved Transaction"
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

  # create_block()
end

def transaction_is_valid?(transaction)
  return !transaction_is_duplicated?(transaction) && enough_token?(transaction)
end

def transaction_is_duplicated?(transaction)
  duplicated_flag = false

  CSV.read("./transactions.csv").each do |post_transaction|
    if post_transaction[3] == transaction["transaction_hash"]
      duplicated_flag = true
      break
    end
  end
  return duplicated_flag
end

def enough_token?(transaction)
  enough_flag = true

  CSV.read("./ledger.csv").each do |account|
    if account[0] == transaction["from"] && account[1].to_i <= transaction["value"].to_i
      enought_flag = false
      break
    end
  end
  return enough_flag
end

def save_transaction(transaction)
  CSV.open("./transactions.csv","a") do |log|
    log.puts [transaction["from"], transaction["to"], transaction["value"], transaction["transaction_hash"], transaction["time_stamp"]]
  end
end

def send_transaction(transaction)
  node_urls = ["http://127.0.0.1:4001"]

  node_urls.each do |url|
    client = HTTPClient.new
    query  = transaction.to_json
    response = client.post(url, query)
    puts response.body
  end
end

# def create_block()
#   sum = 0
#   transactions =[]
#   CSV.read("./transactions.csv").each do |transaction|
#     sum += transaction[3].hex
#     transactions.push(transaction)
#   end

#  nonce = 0
#  hash = ""

#  while true do
#   hash = OpenSSL::Digest.new("sha256").update(sum + nonce).to_s
#   if hash.start_with("000")
#     #　トランザクションを消す処理
#     break
#   end
#   nonce ++
#  end
#  return hash, nonce, transactions
# end

bind 'tcp://127.0.0.1:4000'



