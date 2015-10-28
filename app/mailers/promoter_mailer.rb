class PromoterMailer < ActionMailer::Base
  def invitation(invite)
    to = invite.name_and_email
    url = URI.join(root_url, 'sign-up/', invite.id)
    merge_vars = {
      code:       invite.id,
      invite_url: url,
      sponsor:    User.find(invite.sponsor_id).full_name }

    mail_chimp to, 'invite', merge_vars
  end

  def grid_invite(invite)
    to = invite.name_and_email
    url = URI.join(root_url, '/next/join/grid/', invite.id).to_s
    merge_vars = {
      gridkey:            invite.id,
      invite_url:         url,
      sponsor_first_name: invite.sponsor.first_name,
      sponsor_full_name:  invite.sponsor.full_name,
      sponsee_first_name: invite.first_name,
      sponsee_full_name:  invite.full_name }

    mail_chimp to, 'grid-invite', merge_vars
  end

  def product_invitation(customer)
    to = customer.name_and_email
    url = root_url + 'next/join/solar/' + customer.code
    sponsor = User.find(customer.user_id)
    merge_vars = { invite_url:          url,
                   sponsor_full_name:   sponsor.full_name,
                   customer_first_name: customer.first_name,
                   customer_full_name:  customer.full_name }

    mail_chimp to, 'solar-invite', merge_vars
  end

  def reset_password(user)
    to = user.name_and_email

    url = root_url + "next/login/#{user.reset_token}"

    merge_vars = { reset_url: url }

    mail_chimp to, 'reset-password', merge_vars
  end

  def new_quote(lead)
    to = lead.customer.name_and_email
    pdf_url = "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-home-solar-guide.pdf"
    merge_vars = {
      customer_full_name: lead.customer.full_name,
      sponsor_full_name:  lead.user.full_name,
      solar_guide_url:    pdf_url }

    mail_chimp to, 'customer-onboard-1', merge_vars
  end

  def notify_upline(user)
    # notifies an upline user that they have a new downline team member
    # used when a new user redeems his/her invite (on invites_controller)
    sponsor = user.sponsor
    to = sponsor.name_and_email
    merge_vars = { new_team_member: user.full_name }

    mail_chimp to, 'new-team-member', merge_vars
  end

  def welcome_new_user(user)
    # 'welcome' email when a new user redeems his/her invite
    # used when a new user redeems his/her invite (on invites_controller)
    to = user.name_and_email
    merge_vars = {
      powur_path_url:    "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-path.pdf",
      sponsor_full_name: user.sponsor.full_name,
      sponsor_phone:     user.sponsor.phone }

    mail_chimp to, 'welcome-new-user', merge_vars
  end

  def certification_purchase_processed(user)
    # notifies an advocate when their certification purchase has been processed
    to = user.name_and_email
    merge_vars = {}

    mail_chimp to, 'certification-purchase-processed', merge_vars
  end

  def team_leader_downline_certification_purchase(user)
    # notifies team leader when downline purchases certification
    team_leader = User.find(user.upline[-2])

    to = team_leader.name_and_email
    merge_vars = { team_leader: team_leader.full_name, downline_name: user.full_name }

    mail_chimp to, 'team-leader-downline-certification-purchase', merge_vars
  end

  private

  def mail_chimp(to, template, merge_vars = {})
    merge_vars[:logo_url] = "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-blue-logo.png"
    headers['X-MC-Template'] = template
    headers['X-MC-Tags'] = template
    headers['X-MC-MergeVars'] = merge_vars.to_json
    headers['X-MC-Track'] = 'opens, clicks_all'

    mail to:      to,
         subject: '',
         body:    ''
  end
end
