require "./transaction.rb"

app do |env|
  
  case env["REQUEST_PATH"]
  when "/transaction"
    recieve_transaction(env)
  when "/block"
    p "blockの処理"
    message = "Blockを送信"

    response_body = {
      "message": message
    }
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]

  else
    message = "Not Found"

    response_body = {
      "message": message
    }
    [200, {'Content-Type' => 'application/json'}, [response_body.to_json]]
  end
end

def recieve_block(env)

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
