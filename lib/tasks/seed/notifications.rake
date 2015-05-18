namespace :powur do
  namespace :seed do

    task notifications: :environment do
      Notification.destroy_all

      path = Rails.root.join('db', 'seed', 'notifications.txt')
      File.open(path, 'r').each_line do |line|
        note = Notification.create!(content: line.strip)
        puts "Created notification: #{note.id} : #{note.content[0..50]}"
      end
    end

  end
end
