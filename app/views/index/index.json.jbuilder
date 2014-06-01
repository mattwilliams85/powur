siren json

klass :session

partial = if logged_in?
  'user'
elsif session[:code]
  'code'
else
  'anonymous'
end

json.partial "session/#{partial}"

