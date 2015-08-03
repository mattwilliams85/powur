# namespace :powur do
#   namespace :report do

#     def quotes
#       @quotes ||= begin
#         query = Quote
#         if ENV['FROM_DATE']
#           from_date = DateTime.parse(ENV['FROM_DATE'])
#           query = query
#             .where('submitted_at is not null')
#             .where('submitted_at >= ?', from_date)
#         end
#         query
#       end
#     end

#     def user_totals
#       @user_totals ||= quotes.group(:user_id).order('count_all desc').count
#     end

#     def users_status_totals
#       @users_status_totals ||= quotes.group(:user_id, :status).count
#     end

#     def user_status_totals(user_id)
#       0.upto(7).map do |i|
#         users_status_totals[[ user_id, i ]] || 0
#       end
#     end

#     task most_leads: :environment do
#       users = User.find(user_totals.keys)

#       CSV.open('/tmp/most_leads.csv', 'w+') do |csv|
#         csv << %w(id name total).concat(Quote.statuses.keys)
#         user_totals.each do |user_id, count|
#           user = users.find { |u| u.id == user_id }
#           status_totals = user_status_totals(user_id)
#           csv << [ user_id, user.full_name, count ].concat(status_totals)
#         end
#       end
#     end
#   end
# end