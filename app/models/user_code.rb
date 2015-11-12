class UserCode < ActiveRecord::Base
  belongs_to :user
  belongs_to :bonus
  belongs_to :coded_user, foreign_key: :coded_to, class_name: 'User'

  scope :bonus_user, lambda { |bonus_id, user_id|
    where(bonus_id: bonus_id, user_id: user_id)
  }

  class Calculator
    attr_reader :bonus

    def initialize(bonus)
      @bonus = bonus
    end

    def code_user(user)
      return unless user.sponsor_id?

      sponsor = get_user(user.sponsor_id)
      sponsor_code = get_code(sponsor)

      index = sponsee_index(user.id, sponsor.id) || return
      code_to = calc_coded_to(index, user, sponsor_code) || return

      UserCode.create!(
        user_id:          user.id,
        bonus_id:         bonus.id,
        coded_to:         code_to,
        sponsor_sequence: index + 1)
    end

    def code_all
      codeless = users_needing_codes

      codeless.each do |user|
        users[user.id] ||= user
      end

      codeless.each do |user|
        codes[user.id] = (code_user(user) || false) if codes[user.id].nil?
      end
    end

    private

    def product_id
      bonus.after_purchase
    end

    def users
      @users ||= {}
    end

    def codes
      @codes ||= {}
    end

    def get_user(user_id)
      users[user_id] ||= User.find(user_id)
    end

    def fetch_or_calc_code(user)
      UserCode.bonus_user(bonus.id, user.id).first || code_user(user)
    end

    def get_code(user)
      return false unless user.sponsor_id

      if codes[user.id].nil?
        codes[user.id] = (fetch_or_calc_code(user) || false)
      end

      codes[user.id]
    end

    def sponsee_sequence(sponsor_id)
      User
        .where(sponsor_id: sponsor_id)
        .purchased(product_id)
        .order('product_receipts.purchased_at ASC')
        .pluck(:id)
    end

    def sponsee_index(user_id, sponsor_id)
      sequence = sponsee_sequence(sponsor_id)
      sequence.index(user_id)
    end

    def calc_coded_to(index, user, sponsor_code)
      if (index + 1).odd? # keep line
        user.sponsor_id
      else # pass line
        sponsor_code && sponsor_code.coded_to
      end
    end

    def users_needing_codes
      join = UserCode.where(bonus_id: bonus.id)
      User.purchased(product_id)
        .joins("left join (#{join.to_sql}) uc on uc.user_id = users.id")
        .where('uc.user_id IS NULL')
    end

    def eligible_for_code?(user)
      !users[user.id].nil? || bonus.eligible_for_code?(user)
    end
  end

  class << self
    def code_all(bonus_id)
      calc = UserCode::Calculator.new(Bonus.find(bonus_id))
      calc.code_all
    end
  end
end
