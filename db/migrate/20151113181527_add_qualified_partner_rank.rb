class AddQualifiedPartnerRank < ActiveRecord::Migration
  def up
    path = Rails.root.join('db', 'seed', 'comp_plan.yml')
    ranks = YAML.load_file(path)['ranks']

    ranks.each { |attrs| Rank.from_attrs(attrs) }
  end
end
