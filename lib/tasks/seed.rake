namespace :sunstand do
  namespace :seed do

    task ranks: :environment do
      Rank.create(id: 1, 'Advocate')
      Rank.create(id: 2, 'Consultant')
      3.upto(8).each { |i| Rank.create(id: i, "Rank #{i}") }
    end


    task qualification: [ :ranks ] do
      
    end
  end
end