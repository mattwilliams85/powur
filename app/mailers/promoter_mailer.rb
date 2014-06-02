class PromoterMailer < ActionMailer::Base
  
  def invitation(invite)
    headers['X-MC-Template'] = 'invite'
    headers['X-MC-MergeVars'] = {
      code:       invite.id,
      invite_url: root_url(code: invite.id) }.to_json

    mail( to:       "#{invite.full_name} <#{invite.email}>", 
          subject:  t('email_subjects.invite'),
          body:     '')
  end

  def reset_password(user)
    headers['X-MC-Template'] = 'reset_password'
    headers['X-MC-MergeVars'] = {
      url: new_login_password_path(token: user.reset_token) }.to_json

    mail( to:       "#{invite.full_name} <#{invite.email}>",
          subject:  t('email_subjects.reset_password'),
          body:     '')
  end
end
