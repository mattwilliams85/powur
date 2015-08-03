namespace :powur do
  namespace :seed do
    def plan_data
      @plan_data ||= begin
        YAML.load_file(Rails.root.join('db', 'seed', 'comp_plan.yml'))
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

    task plan: [ :ranks, :user_groups ] do
    end
  end
end
