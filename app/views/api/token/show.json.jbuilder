json.call(@token, :access_token, :token_type, :expires_in, :refresh_token)
json.user api_user_path
