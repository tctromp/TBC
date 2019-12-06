require "httpclient"
require "json"
require "openssl"

node_urls = ["http://127.0.0.1:4000"]

def create_transaction(node_urls)
    from = "0xa3e639fd35"
    to = "0xccb9ef3c64"
    value = 100
    time_stamp = Time.now.to_s

    route = "/transaction"

    digest = OpenSSL::Digest.new("sha256")
    transaction_hash = digest.update(from + to + value.to_s + time_stamp).to_s.slice(1..10)

    query = {
        "from": from, 
        "to": to,
        "value": value,
        "time_stamp": time_stamp,
        "hash": transaction_hash
    }.to_json

    request_node(query, route, node_urls)
end

def create_block(node_urls)
    transactions = [{from: "0xa3e639fd35", to: "b", value: 1000000, hash: "abc", time_stamp: "2019-12-05 17:40:01 +0900"},
                {from: "0xa3e639fd35", to: "b", value: 1, hash: "defg", time_stamp: "2019-12-05 17:40:01 +0900"}]
    query = {
        "hash": "0000cdf",
        "nonce": 100,
        "parent_hash": "00000",
        "transactions": transactions
    }.to_json

    route = "/block"

    request_node(query, route, node_urls)
end

def request_node(query, route, node_urls)
    node_urls.each do |url|
        res = HTTPClient.post(url+route, query)
        puts res.body
    end
end

# def create_block_contents
#   sum = 0
#   nonce = 0
#   transactions = []
#   block_hash = ""
#   CSV.read("./transactions.csv", headers: true).each do |transaction|
#     sum += transaction.to_hash["hash"].hex
#     transactions.push(transaction)
#   end

#   while true
#     block_hash = OpenSSL::Digest.new("sha256").update(nonce.to_s + sum.to_s).to_s
#     if block_hash.start_with?("0000")

#       break
#     end
#     nonce += 1
#   end
#   return nonce, block_hash, transactions
# end

# create_transaction(node_urls)
# create_block(node_urls)