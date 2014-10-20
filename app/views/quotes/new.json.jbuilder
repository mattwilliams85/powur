siren json

klass :quote

actions \
  action(:create, :post, quote_path)
    .field(:first_name, :text)
    .field(:last_name, :text)
    .field(:email, :email)
    .field(:phone, :text)
    .field(:promoter, :hidden, value: @sponsor.url_slug)
