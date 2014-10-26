quote_klass json

user_entities(@quote)

actions update_action(user_quote_path(@quote)),
        resend_action(resend_user_quote_path(@quote))

self_link user_quote_path(@quote)
