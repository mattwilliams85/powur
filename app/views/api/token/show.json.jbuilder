json.call(@token, :access_token, :token_type, :expires_in, :refresh_token)
json.session api_session_path(v: params[:v])
