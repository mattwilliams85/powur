class CodedBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent,
                 :installed_percent, :first_n, :nth_proposal,
                 :after_purchase, :upline, :include_user, :available_amount

  def create_payments!(calculator)
    relevant_lead_statuses.each_with_object({}) do |status, report|
      leads = calculator.status_leads(status)
      report[status] = leads.each_with_object({}) do |lead, result|
        result[lead] = create_lead_payments(calculator, lead, status)
      end
    end
  end

  def payment_amounts
    bonus_amounts.entries.first.amounts
  end

  def first_n
    meta_data['first_n'] && meta_data['first_n'].to_i
  end

  def nth_proposal
    meta_data['nth_proposal'] && meta_data['nth_proposal'].to_i
  end

  def after_purchase
    meta_data['after_purchase'] && meta_data['after_purchase'].to_i
  end

  def available_amount
    BigDecimal.new(meta_data['available_amount'])
  end

  def sponsor?
    meta_data['upline'] == 'sponsor'
  end

  private

  def percent_allocated(status)
    meta_data["#{status}_percent"] && meta_data["#{status}_percent"].to_f
  end

  def relevant_lead_statuses
    [ :converted, :contracted, :installed ].select do |status|
      percent_allocated(status) && percent_allocated(status) > 0
    end
  end

  def coded?(user)
    CodedBonus.calculate_sponsor_codes(user) unless user.coded_user_id?
    user.coded_user_id?
  end

  def qualified_lead_number?(number)
    return false if first_n && number > first_n
    return true unless nth_proposal
    number == nth_proposal
  end

  def lead_after_purchase?(lead, status)
    return unless after_purchase
    purchased_at = lead.user.purchased_at(after_purchase)
    purchased_at && purchased_at <= lead.status_date(status)
  end

  def new_bonus_payment(calculator, lead, status)
    payment = bonus_payments.new(
      pay_period_id: calculator.pay_period.id,
      user_id:       lead.user.coded_user_id)

    if first_n || nth_proposal
      payment.lead_number = lead.status_count_at_time(status, after_purchase)
    end

    payment
  end

  def lead_payment_amount(status, lead_number = nil)
    if first_n || nth_proposal
      payment_amounts[lead_number - 1] * percent_allocated(status)
    else
      available_amount * percent_allocated(status)
    end
  end

  def create_lead_payments(calculator, lead, status)
    return :not_coded unless coded?(lead.user)

    payment = new_bonus_payment(calculator, lead, status)
    return :before_purchase unless lead_after_purchase?(lead, status)
    unless qualified_lead_number?(payment.lead_number)
      return "invalid_lead_number (#{payment.lead_number})"
    end
    payment.amount = lead_payment_amount(status, payment.lead_number)

    payment.save!
    payment.bonus_payment_leads.create!(lead_id: lead.id, status: :converted)
    payment
  end

  class << self
    def calculate_sponsor_codes(user)
      return unless user.sponsor_id?

      if user.sponsor.sponsor_id? && !user.sponsor.coded_user_id?
        calculate_sponsor_codes(user.sponsor)
      end

      siblings = User
        .where(sponsor_id: user.sponsor_id)
        .purchased(3)
        .order('product_receipts.purchased_at ASC')
        .pluck(:id)

      sequence = siblings.index(user.id) || return
      coded_user_id =
        if (sequence + 1).odd? # keep line
          user.sponsor_id
        else # pass line
          user.sponsor.coded_user_id
        end
      return if coded_user_id.nil?

      user.update_attributes!(coded_user_id: coded_user_id)
    end

    def calculate_and_report(pay_period_id)
      results = first.create_payments!(BonusCalculator.new(pay_period_id))

      CSV.open("/tmp/coded_bonus_leads-#{pay_period_id}.csv", 'w') do |csv|
        csv << %w(id converted user sponsor coded_to status lead_number)
        results[:converted].each do |lead, result|
          user = "#{lead.user.full_name} (#{lead.user.id})"
          if lead.user.sponsor_id
            sponsor = "#{lead.user.sponsor.full_name} (#{lead.user.sponsor_id})"
          end
          row = [ lead.id, lead.converted_at, user,
                  sponsor, lead.user.coded_user_id ]
          if result.is_a?(BonusPayment)
            row.push(result.amount, result.lead_number)
          else
            row.push(result, nil)
          end
          csv << row
        end
      end
    end

    def user_node_name(user)
      "#{user.full_name} (#{user.id})"
    end

    def graph_coded_users
      graph = GraphViz.new(:G, type: :digraph)

      nodes = {}
      users = User.coded
        .includes(:coded_user, :sponsor)
        .references(:coded_user, :sponsor)
      users.each do |user|
        nodes[user.id] ||= graph.add_nodes(user_node_name(user))
        nodes[user.coded_user_id] ||= graph
          .add_nodes(user_node_name(user.coded_user))
        # if user.sponsor_id?
        #   nodes[user.sponsor_id] ||= graph.add_nodes(user_node_name(user.sponsor))
        # end
      end

      users.each do |user|
        graph.add_edges(nodes[user.id], nodes[user.coded_user_id])
      end

      graph.output(png: '/tmp/coded_graph.png')
    end

  end
end
