siren json

json.partial! 'item', user: @user, detail: true

json.properties do
  @user.contact.each { |k,v| json.set! k,v }
end

links \
  link(:self, user_path(@user))