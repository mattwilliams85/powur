siren json

json.partial! 'auth/profile/item', user: @user, detail: false

# profile_json.list_entities(profile_path, @profile)

profile_json.update_action(profile_path, @user)
