class PromoterMailer < ActionMailer::Base
  def invitation(invite)
    to = "#{invite.full_name} <#{invite.email}>"
    merge_vars = { code: invite.id, invite_url: root_url(code: invite.id) }

    mail_chimp to, :invite, merge_vars
  end

  def reset_password(user)
    to = "#{user.full_name} <#{user.email}>"
    merge_vars = { reset_url: new_password_url(token: user.reset_token) }

    mail_chimp to, 'reset-password', merge_vars
  end

  def new_quote(quote)
    to = "#{quote.customer.full_name} <#{quote.customer.email}>"
    quote_url = customer_quote_url(quote.user.url_slug, quote.url_slug)
    merge_vars = {
      promoter_name: quote.user.full_name,
      quote_url:     quote_url }

    mail_chimp to, 'customer-onboard', merge_vars
  end

  def notify_upline(user)
    # notifies an upline user that they have a new downline team member
    # used when a new user redeems his/her invite (on invites_controller)
    sponsor = user.sponsor
    to = "#{sponsor.full_name} <#{sponsor.email}>"
    merge_vars = { new_team_member: user.full_name }

    mail_chimp to, 'new-team-member', merge_vars
  end

  def welcome_new_user(user)
    # 'welcome' email when a new user redeems his/her invite
    # used when a new user redeems his/her invite (on invites_controller)
    to = "#{user.full_name} <#{user.email}>"
    merge_vars = {}

    mail_chimp to, 'welcome-new-user', merge_vars
  end

  private

  def mail_chimp(to, template, merge_vars = {})
    merge_vars[:logo_url] = \
      ActionController::Base.helpers.image_url('emails/logo.png')
    headers['X-MC-Template'] = template
    headers['X-MC-MergeVars'] = merge_vars.to_json

    mail to:      to,
         subject: t("email_subjects.#{template}"),
         body:    ''
  end
end
