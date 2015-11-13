class CodedBonus < Bonus
  store_accessor :meta_data,
                 :converted_percent, :contracted_percent,
                 :installed_percent, :first_n, :nth_proposal,
                 :after_purchase, :upline, :include_user, :available_amount

  def create_payments!(calculator)
    reset!(calculator.pay_period.id)

    results = generate_bonus_payments(calculator)
    results.each do |status, status_results|
      status_results.each do |lead, result|
        next unless result.is_a?(BonusPayment)
        result.save!
        result.bonus_payment_leads.create!(lead_id: lead.id, status: status)
      end
    end
  end

  def report_payments(calculator)
    results = generate_bonus_payments(calculator)

    filename = name.gsub(/ /, '').underscore
    filename = "#{filename}-#{calculator.pay_period.id}"
    CSV.open("/tmp/#{filename}.csv", 'w') do |csv|
      csv << %w(id converted user sponsor coded_to status lead_number)

      results.each do |_status, status_results|
        status_results.each do |lead, result|
          user = "#{lead.user.full_name} (#{lead.user.id})"
          if lead.user.sponsor_id?
            sponsor = "#{lead.user.sponsor.full_name} (#{lead.user.sponsor_id})"
          end
          code = user_code(lead.user_id)
          row = [
            lead.id, lead.converted_at, user,
            sponsor, code && code.coded_to ]
          if result.is_a?(BonusPayment)
            row.push(result.amount, result.lead_number)
          else
            row.push(result, nil)
          end
          csv << row
        end
      end
    end
  end

  def generate_bonus_payments(calculator)
    UserCode.code_all(id)

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

  def eligible_for_code?(user)
    @eligibles ||= {}
    if @eligibles[user.id].nil?
      @eligibles[user.id] = ProductReceipt
        .where(product_id: after_purchase, user_id: user.id).exists?
    end
    @eligibles[user.id]
  end

  def user_codes
    @user_codes ||= UserCode.where(bonus_id: id).entries
  end

  def user_code(user_id)
    user_codes.detect { |c| c.user_id == user_id }
  end

  private

  def reset!(pay_period_id)
    bonus_payments.where(pay_period_id: pay_period_id).destroy_all
  end

  def percent_allocated(status)
    meta_data["#{status}_percent"] && meta_data["#{status}_percent"].to_f
  end

  def relevant_lead_statuses
    [ :converted, :contracted, :installed ].select do |status|
      percent_allocated(status) && percent_allocated(status) > 0
    end
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

  def new_bonus_payment(calculator, lead, code, status)
    payment = bonus_payments.new(
      pay_period_id: calculator.pay_period.id,
      user_id:       code.coded_to)

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
    return :before_purchase unless lead_after_purchase?(lead, status)

    code = user_code(lead.user_id)
    return :not_coded unless code

    payment = new_bonus_payment(calculator, lead, code, status)
    unless qualified_lead_number?(payment.lead_number)
      return "invalid_lead_number (#{payment.lead_number})"
    end
    payment.amount = lead_payment_amount(status, payment.lead_number)

    payment
  end

  class << self
    # def calculate_and_report(pay_period_id)
    #   results = first.create_payments!(BonusCalculator.new(pay_period_id))

    #   CSV.open("/tmp/coded_bonus_leads-#{pay_period_id}.csv", 'w') do |csv|
    #     csv << %w(id converted user sponsor coded_to status lead_number)
    #     results[:converted].each do |lead, result|
    #       user = "#{lead.user.full_name} (#{lead.user.id})"
    #       if lead.user.sponsor_id
    #         sponsor = "#{lead.user.sponsor.full_name} (#{lead.user.sponsor_id})"
    #       end
    #       row = [ lead.id, lead.converted_at, user,
    #               sponsor, lead.user.coded_user_id ]
    #       if result.is_a?(BonusPayment)
    #         row.push(result.amount, result.lead_number)
    #       else
    #         row.push(result, nil)
    #       end
    #       csv << row
    #     end
    #   end
    # end

    # def user_node_name(user)
    #   "#{user.full_name} (#{user.id})"
    # end

    # def graph_coded_users
    #   graph = GraphViz.new(:G, type: :digraph)

    #   nodes = {}
    #   users = User.coded
    #     .includes(:coded_user, :sponsor)
    #     .references(:coded_user, :sponsor)
    #   users.each do |user|
    #     nodes[user.id] ||= graph.add_nodes(user_node_name(user))
    #     nodes[user.coded_user_id] ||= graph
    #       .add_nodes(user_node_name(user.coded_user))
    #     # if user.sponsor_id?
    #     #   nodes[user.sponsor_id] ||= graph.add_nodes(user_node_name(user.sponsor))
    #     # end
    #   end

    #   users.each do |user|
    #     graph.add_edges(nodes[user.id], nodes[user.coded_user_id])
    #   end

    #   graph.output(png: '/tmp/coded_graph.png')
    # end

  end
end
