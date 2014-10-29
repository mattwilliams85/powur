siren json

quotes_json.item_init

quotes_json.detail_properties

quotes_json.user_entities(@quote)

actions quotes_json.update_action(user_quote_path(@quote)),
        quotes_json.resend_action(resend_user_quote_path(@quote))

self_link user_quote_path(@quote)
