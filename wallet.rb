require "csv"

class Wallet
  def self.get_amount(address)
    amount = 0
    Dir.children("./transactions").each do |file|
      CSV.read("./transactions/#{file}", headers: true).each do |transaction|
        if transaction["from_address"] == address
          amount -= transaction["value"].to_i
        end

        if transaction["to_address"] == address
          amount += transaction["value"].to_i
        end
      end
    end
    return amount
  end
end