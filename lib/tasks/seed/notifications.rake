namespace :powur do
  namespace :seed do

    task news_posts: :environment do
      NewsPost.destroy_all

      path = Rails.root.join('db', 'seed', 'news_posts.txt')
      File.open(path, 'r').each_line do |line|
        note = NewsPost.create!(content: line.strip)
        puts "Created news_post: #{note.id} : #{note.content[0..50]}"
      end
    end

  end
end
