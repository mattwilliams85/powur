# json.tree @user.create_downline_tree
def populateTree(parent, j)
  @downline.each do |user|
    if user.upline.length - 1 == parent.upline.length && user.upline.include?(parent.id)
      # @downline.delete_at(@downline.index(parent))
      j.set!(user.id) do
        j.id user.id
        j.first_name user.first_name
        j.last_name user.last_name
        j.created_at user.created_at.to_f * 1000
        j.children do |i|
            populateTree(user, i)
        end
      end
    end
  end
end

json.set!(@user.id) do 
  json.id @user.id
  json.first_name @user.first_name
  json.last_name @user.last_name
  json.created_at @user.created_at.to_f * 1000
  json.children do |j|
    populateTree(@user, j)
  end
end