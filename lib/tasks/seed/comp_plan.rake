namespace :powur do
  namespace :seed do

    RANKS = {
      1 => { title: 'Direct Seller' },
      2 => { title: 'Local Grid' },
      3 => { title: 'Community Grid' },
      4 => { title: 'City Grid' },
      5 => { title: 'Regional Grid' },
      6 => { title: 'State Grid Leader' },
      7 => { title: 'National Grid' },
      8 => { title: 'Game Changer' } }

    GROUPS = {
      1 => {
        title:       'Direct Sellers',
        description: 'You have taken the FIT training',
        rank_id:     1 },
      2 => {
        title:       'Certified Local Grid Advocates',
        description: 'Advocates that have been certified.',
        rank_id:     2 } }

    REQUIREMENTS = {
      1 => [
        { event_type: :course_completion,
          product_id: 2 } ],
      2 => [
        { event_type: :course_completion,
          product_id: 3 },
        { event_type: :personal_sales,
          product_id: 1,
          time_span:  :lifetime } ] }

    def group_id(rank_id)
      "rank_#{rank_id}_requirements"
    end

    task ranks: :environment do
      Rank.destroy_all
      RANKS.each do |id, attrs|
        Rank.create!(attrs.merge(id: id))
        puts "Created rank #{id}"
      end
    end

    task user_groups: :environment do
      UserGroup.destroy_all
      GROUPS.each do |id, attrs|
        rank_id = attrs.delete(:rank_id)
        group = UserGroup.create!(attrs.merge(id: group_id(rank_id)))
        group.ranks_user_groups.create!(rank_id: rank_id)
        puts "Created group #{group.id}"
      end
    end

    task requirements: :environment do
      UserGroupRequirement.destroy_all
      REQUIREMENTS.each do |id, attr_list|
        user_group_id = group_id(id)
        attr_list.each do |attrs|
          UserGroupRequirement.create!(attrs.merge(user_group_id: user_group_id))
        end
        puts "Created requirements for #{user_group_id}"
      end
    end

    task plan: [ :ranks, :user_groups, :requirements ] do
    end

  end
end