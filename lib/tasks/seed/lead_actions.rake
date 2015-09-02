namespace :powur do
  namespace :seed do
    def load_yaml(file_name)
      YAML.load_file(Rails.root.join('db', 'seed', "#{file_name}.yml"))
    end

    def lead_actions_data
      @lead_actions_data ||= load_yaml('lead_actions')['lead_actions']
    end

    task lead_actions: :environment do
      LeadAction.delete_all
      lead_actions_data.each do |data|
        LeadAction.create!(data)
      end
    end
  end
end
