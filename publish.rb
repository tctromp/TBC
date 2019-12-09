require "httpclient"
require "json"
require "openssl"
require "csv"
require "./connecter.rb"
require "./block.rb"

node_urls = ["http://127.0.0.1:4000"]

def create_transaction(node_urls)
    from = "0xa3e639fd35"
    to = "0xccb9ef3c64"
    value = 10
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

def request_node(query, route, node_urls)
    node_urls.each do |url|
        res = HTTPClient.post(url+route, query)
        puts res.body
    end
end

while true
    Block.create_block(node_urls)
    create_transaction(node_urls)
end