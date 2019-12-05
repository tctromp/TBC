require "httpclient"
require "json"
require "openssl"

node_urls = ["http://127.0.0.1:4000"]
client = HTTPClient.new

from = "0xa3e639fd35"
to = "0xccb9ef3c64"
value = 100
time_stamp = Time.now.to_s

digest = OpenSSL::Digest.new("sha256")
transaction_hash = digest.update(from + to + value.to_s + time_stamp).to_s.slice(1..10)

query = {
    "from": from, 
    "to": to,
    "value": value,
    "time_stamp": time_stamp,
    "transaction_hash": transaction_hash
}.to_json

node_urls.each do |url|
    res = client.post(url, query)
    puts res.body
end