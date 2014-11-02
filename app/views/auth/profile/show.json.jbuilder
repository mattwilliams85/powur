siren json

json.partial! 'item', user: @user, detail: false

profile_json.list_entities(profile_path, @profile)

profile_json.user_entities(@user)

profile_json.update_action(profile_path, @user)



