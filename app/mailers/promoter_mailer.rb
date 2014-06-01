class PromoterMailer < ActionMailer::Base
  
  def invitation(invite)
    headers['X-MC-Template'] = 'invite'
    headers['X-MC-MergeVars'] = {
      code:       invite.id,
      invite_url: root_url(code: invite.id) }.to_json

    mail(to: "#{invite.full_name} <#{invite.email}>", 
      subject: t('email_subjects.invite'),
      body: '')
  end

  def reset_password(user)
    headers['X-MC-Template'] = 'invite'

    headers['X-MC-MergeVars'] = {
      token:      invite.id,
      invite_url: root_url(code: invite.id) }.to_json

  end
end
