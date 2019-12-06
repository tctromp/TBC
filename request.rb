require "httpclient"
require "json"
require "openssl"
require "csv"

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
    
    block_contents = mining().to_hash

    query = {
        "hash": block_contents[:hash],
        "nonce": block_contents[:nonce],
        "parent_hash": block_contents[:parent_hash],
        "transactions": block_contents[:transactions] #nilになってる
    }.to_json

    route = "/block"

    request_node(query, route, node_urls)
end

# def create_block(node_urls)
#     transactions = [{from: "0xa3e639fd35", to: "b", value: 1000000, hash: "abc", time_stamp: "2019-12-05 17:40:01 +0900"},
#                 {from: "0xa3e639fd35", to: "b", value: 1, hash: "defg", time_stamp: "2019-12-05 17:40:01 +0900"}]
#     query = {
#         "hash": "0000cdf",
#         "nonce": 100,
#         "parent_hash": "00000",
#         "transactions": transactions
#     }.to_json

#     route = "/block"

#     request_node(query, route, node_urls)
# end

def request_node(query, route, node_urls)
    node_urls.each do |url|
        res = HTTPClient.post(url+route, query)
        puts res.body
    end
end

def mining
    sum = 0
    nonce = 0
    transactions = []

    CSV.read("./transactions.csv", headers: true).each do |transaction|
        sum += transaction.to_hash["hash"].hex
        transactions.push(transaction.to_hash)
    end

    parent_hash = JSON.parse(File.open("./block.txt").to_a.last)["hash"]
    sum += parent_hash.to_i

    while true
        hash = OpenSSL::Digest.new("sha256").update((nonce + sum).to_s).to_s.slice(1..10)
        if hash.start_with?("00000")
            break
        end
        nonce += 1
    end
    return {"hash": hash, "nonce": nonce, "parent_hash": parent_hash, "transactions": transactions}
end

while true
    create_block(node_urls)
    create_transaction(node_urls)
end