class PromoterMailer < ActionMailer::Base
  
  def invitation(invite)
    to = "#{invite.full_name} <#{invite.email}>"
    merge_vars = { code: invite.id, invite_url: root_url(code: invite.id) }

    mail_chimp to, :invite, merge_vars
  end

  def reset_password(user)
    to = "#{user.full_name} <#{user.email}>"
    merge_vars = { reset_url: new_login_password_url(token: user.reset_token) } 

    mail_chimp to, 'reset-password', merge_vars
  end

  private

  def mail_chimp(to, template, merge_vars = {})
    merge_vars[:logo_url] = \
      ActionController::Base.helpers.image_url('emails/logo.png')
    headers['X-MC-Template'] = template
    headers['X-MC-MergeVars'] = merge_vars.to_json

    mail \
      to:       to,
      subject:  t("email_subjects.#{template}"),
      body:     ''
  end
end
