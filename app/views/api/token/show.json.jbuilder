json.call(@token, :access_token, :token_type, :expires_in)
json.refresh_token(@token.refresh_token) unless local_assigns[:refresh] == false
json.session api_session_path(v: params[:v])
