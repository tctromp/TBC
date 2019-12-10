require "httpclient"
require "json"
require "openssl"
require "csv"
require 'fileutils'
require "./connecter.rb"
require "./block.rb"

node_urls = ["http://127.0.0.1:4000"]

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

# Block.create_block(node_urls)
Transaction.create_transaction(query, node_urls)

# while true
#     Block.create_block(node_urls)
#     create_transaction(node_urls)
# end