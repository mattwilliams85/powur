namespace :powur do
  namespace :seed do

    def load_yaml(file_name)
      YAML.load_file(Rails.root.join('db', 'seed', "#{file_name}.yml"))
    end

    def plan_data
      @plan_data ||= load_yaml('comp_plan')
    end

    def bonus_data
      @bonus_data ||= load_yaml('bonuses')
    end

    def create_bonus_from_attrs(bonus_attrs)
      bonus_amounts = bonus_attrs.delete('bonus_amounts')
      bonus = Bonus.create!(bonus_attrs)
      return unless bonus_amounts
      bonus_amounts.each do |attrs|
        bonus.bonus_amounts.create!(attrs)
      end
    end

    task ranks: :environment do
      Rank.destroy_all
      plan_data['ranks'].each do |attrs|
        rank = Rank.create!(attrs)
        puts "Created rank #{rank.id} : #{rank.title}"
      end
    end

    task user_groups: :environment do
      UserGroup.destroy_all
      plan_data['groups'].each do |attrs|
        rank_id = attrs.delete('rank_id')
        requirements = attrs.delete('requirements')
        group = UserGroup.create!(attrs)
        group.ranks_user_groups.create!(rank_id: rank_id)
        requirements.each do |req_attrs|
          next unless Product.find_by(id: req_attrs['product_id'].to_i)
          group.requirements.create!(req_attrs)
        end
        puts "Created group #{group.title} : #{group.id}"
      end
    end

    task bonuses: :environment do
      bonus_data['bonuses'].each do |bonus_attrs|
        create_bonus_from_attrs(bonus_attrs)
      end
    end

    task plan: [ :ranks, :user_groups ] do
    end

    task user_ranks: :environment do
      puts 'Calculating Lead Totals...'
      LeadTotals.calculate_all!
      puts 'Populating User Ranks...'
      Rank.rank_users
    end
  end
end
