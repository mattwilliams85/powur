namespace :powur do
  namespace :seed do
    def load_yaml(file_name)
      YAML.load_file(Rails.root.join('db', 'seed', "#{file_name}.yml"))
    end

    def fetch_plan_data(version)
      load_yaml("comp_plan_v#{version}")
    end

    def bonus_data
      @bonus_data ||= load_yaml('bonuses')
    end

    def create_bonus_from_attrs(bonus_attrs)
      bonus_amounts = bonus_attrs.delete('bonus_amounts')
      id = bonus_attrs['id']
      if id && (bonus = Bonus.find_by(id: id))
        bonus_attrs.delete('id')
        bonus.update_attributes(bonus_attrs)
        bonus.bonus_amounts.delete_all
      else
        bonus = Bonus.create!(bonus_attrs)
      end

      return unless bonus_amounts
      bonus_amounts.each do |attrs|
        bonus.bonus_amounts.create!(attrs)
      end
    end

    task :ranks, [ :v ] => :environment do |_t, args|
      plan_data = fetch_plan_data(args[:v])

      Rank.destroy_all
      plan_data['ranks'].each do |attrs|
        rank = Rank.from_attrs(attrs)
        puts "Created rank #{rank.id} : #{rank.title}"
      end
    end

    task bonuses: :environment do
      bonus_data['bonuses'].each do |bonus_attrs|
        Bonus.create_or_update_bonus_from_attrs(bonus_attrs)
      end
    end

    task bonus_payments: :environment do
      BonusCalculator.run_all
    end

    task plan: [ :ranks, :user_groups ] do
    end

    task user_ranks: :environment do
      puts 'Calculating Lead Totals...'
      UserTotals.calculate_all!
      puts 'Populating User Ranks...'
      Rank.rank_users
    end
  end
end
