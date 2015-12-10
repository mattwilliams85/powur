namespace :powur do
  namespace :leads do
    task reset_contracted: :environment do
      leads = Lead.contracted

      leads.each do |lead|
        first_contracted = lead.distinct_update_dates(:contract).min
        next if first_contracted == lead.contracted_at
        puts "modifying contract date for lead #{lead.id}"
        lead.contracted_at = first_contracted
        lead.save!
      end
    end
  end
end
