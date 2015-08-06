class PromoterMailer < ActionMailer::Base
  def invitation(invite)
    to = "#{invite.full_name} <#{invite.email}>"
    # url = root_url(code: invite.id)
    url = root_url + "sign-up/" + invite.id
    merge_vars = { code: invite.id, invite_url: url, sponsor: User.find(invite.sponsor_id).full_name }

    mail_chimp to, :invite, merge_vars
  end

  def reset_password(user)
    to = "#{user.full_name} <#{user.email}>"

    url = root_url + "reset-password/#{user.reset_token}"

    merge_vars = { reset_url: url }

    mail_chimp to, 'reset-password', merge_vars
  end

  def new_quote(quote)
    to = "#{quote.customer.full_name} <#{quote.customer.email}>"
    merge_vars = {
      promoter_name: quote.user.full_name,
      solar_guide_url: "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-home-solar-guide.pdf" }

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
    merge_vars = {
      powur_path_url: "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-path.pdf",
      sponsor:        user.sponsor.full_name,
      sponsor_phone:  user.sponsor.phone
    }

    mail_chimp to, 'welcome-new-user', merge_vars
  end

  def certification_purchase_processed(user)
    # notifies an advocate when their certification purchase has been processed
    to = "#{user.full_name} <#{user.email}>"
    merge_vars = {}

    mail_chimp to, 'certification-purchase-processed', merge_vars
  end

  def team_leader_downline_certification_purchase(user)
    # notifies team leader when downline purchases certification
    team_leader = User.find(user.upline[-2])

    to = "#{team_leader.full_name} <#{team_leader.email}>"
    merge_vars = { team_leader: team_leader.full_name, downline_name: user.full_name }

    mail_chimp to, 'team-leader-downline-certification-purchase', merge_vars
  end

  private

  def mail_chimp(to, template, merge_vars = {})
    merge_vars[:logo_url] = "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-blue-logo.png"
    headers['X-MC-Template'] = template
    headers['X-MC-MergeVars'] = merge_vars.to_json

    mail to:      to,
         subject: t("email_subjects.#{template}"),
         body:    ''
  end
end
