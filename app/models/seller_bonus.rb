class SellerBonus < Bonus
  typed_store :meta_data, first_n: :integer, first_n_amount: :money
end
