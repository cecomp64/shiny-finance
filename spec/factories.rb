FactoryGirl.define do
  factory :transaction do
    action_id 1
    quantity 20
    price 10.0
    amount 200.0
    symbol "GE"
    fees 8.95
    user

    trait :buy do
      action_id 1
    end

    trait :sell do
      action_id 2
    end

    trait :ge do
      symbol "GE"
    end

    trait :nvda do
      symbol "NVDA"
    end

    factory :buy_ge, traits: [:buy, :ge]
    factory :buy_nvda, traits: [:buy, :nvda]
    factory :sell_ge, traits: [:sell, :ge]
    factory :sell_nvda, traits: [:sell, :nvda]
  end

  factory :lot do
    #transactions
    user

    factory :lot_with_transactions do
      ignore do
        transactions_count 10
      end

      after(:create) do |lot, evaluator|
        create_list(:transaction, evaluator.transactions_count, :buy, :ge, lot: lot, user: lot.user, price: (10+(10 * (rand - 0.5))) )
        create_list(:transaction, evaluator.transactions_count, :sell, :ge, lot: lot, user: lot.user, price: (10+(10 * (rand - 0.5))) )
      end
    end
  end

  factory :user, aliases: [:carl] do
    name "Carl Svensson"
    email "carl.svensson@example.com"
    password "carlcarl"
    password_confirmation "carlcarl"

    # Auto generate some set of transactions
    factory :user_with_transactions do
      ignore do
        transactions_count 10
      end

      after(:create) do |user, evaluator|
        create_list(:transaction, evaluator.transactions_count, :buy, :ge, user: user)
        create_list(:transaction, evaluator.transactions_count, :sell, :ge, user: user)
      end
    end

    factory :user_with_lots do
      ignore do
        lots_count 1
      end

      after(:create) do |user, evaluator|
        create_list(:lot_with_transactions, evaluator.lots_count, user: user)
      end
    end
  end

end
