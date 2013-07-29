json.array!(@transactions) do |transaction|
  json.extract! transaction, :Date, :Action, :Quantity, :Symbol, :Description, :Price, :Amount, :Fees, :user_id
  json.url transaction_url(transaction, format: :json)
end
