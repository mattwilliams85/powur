class SellerBonus < Bonus
  store_accessor :meta_data,
                 :first_n, :first_n_amount

  def meta_data_fields
    { first_n: :integer, first_n_amount: :decimal }
  end

  def first_n
    super && super.to_i
  end

  
end
