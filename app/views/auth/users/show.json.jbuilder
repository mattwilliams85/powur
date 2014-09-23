siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  @user.contact.each { |k,v| json.set! k,v }
end

links \
  link(:self, user_path(@user)),
  link(:children, downline_user_path(@user)),
  link(:ancestors, upline_user_path(@user))
  link(:profile, profile_path())