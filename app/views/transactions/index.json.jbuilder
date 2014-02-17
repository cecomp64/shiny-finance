json.array!(@transactions) do |transaction|
  json.extract! transaction, :date, :action, :quantity, :symbol, :description, :price, :amount, :fees, :user_id
  json.url transaction_url(transaction, format: :json)
end
