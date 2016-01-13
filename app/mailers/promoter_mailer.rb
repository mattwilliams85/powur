class PromoterMailer < ActionMailer::Base
  def invitation(invite)
    to = invite.name_and_email
    url = URI.join(root_url, 'sign-up/', invite.id)
    sponsor = User.find(invite.sponsor_id)
    merge_vars = {
      # Old vars
      sponsor: sponsor.full_name,
      # New vars
      sponsor_full_name: sponsor.full_name,
      sponsor_photo: sponsor.avatar.url(:thumb),
      code: invite.id,
      invite_url: url }

    mail_chimp to, 'invite', merge_vars
  end

  def grid_invite(invite)
    url = URI.join(root_url, '/next/join/grid/', invite.id).to_s
    merge_vars = {
      gridkey:            invite.id,
      invite_url:         url,
      sponsor_first_name: invite.sponsor.first_name,
      sponsor_full_name:  invite.sponsor.full_name,
      sponsee_first_name: invite.first_name,
      sponsee_full_name:  invite.full_name,
      sponsor_photo:      invite.sponsor.avatar.url(:thumb) }

    result = mandrill(invite.email, invite.full_name, 'grid-invite', merge_vars)
    invite.update_column(:mandrill_id, result.first['_id'])
  end

  def product_invitation(lead)
    url = lead.getsolar_page_url
    sponsor = User.find(lead.user_id)
    merge_vars = { invite_url:          url,
                   sponsor_full_name:   sponsor.full_name,
                   sponsor_photo:       sponsor.avatar.url(:thumb),
                   customer_first_name: lead.first_name,
                   customer_full_name:  lead.full_name }

    result = mandrill(lead.email, lead.full_name, 'solar-invite', merge_vars)
    lead.update_column(:mandrill_id, result.first['_id'])
  end

  def reset_password(user)
    to = user.name_and_email

    url = root_url + "next/login/#{user.reset_token}"

    merge_vars = { reset_url: url }

    mail_chimp to, 'reset-password', merge_vars
  end

  def new_quote(lead)
    to = lead.name_and_email
    pdf_url = "https://s3.amazonaws.com/#{ENV["AWS_BUCKET"]}/emails/powur-home-solar-guide.pdf"
    merge_vars = {
      customer_full_name: lead.full_name,
      sponsor_full_name:  lead.user.full_name,
      sponsor_photo:      lead.user.avatar.url(:thumb),
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
      sponsor_phone:     user.sponsor.phone,
      sponsor_photo:     user.sponsor.avatar.url(:thumb) }

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
    merge_vars = {
      team_leader:   team_leader.full_name,
      downline_name: user.full_name }

    mail_chimp to, 'team-leader-downline-certification-purchase', merge_vars
  end

  def lead_mistmatch(to, merge_vars)
    mail_chimp to, 'lead-data-correction', merge_vars
  end

  private

  def logo_url
    "https://s3.amazonaws.com/#{ENV['AWS_BUCKET']}/emails/powur-blue-logo.png"
  end

  def mail_chimp(to, template, merge_vars = {})
    merge_vars.merge!({
      current_year: Date.today.year,
      logo_url: logo_url })

    headers['X-MC-Template'] = template
    headers['X-MC-Tags'] = template
    headers['X-MC-MergeVars'] = merge_vars.to_json
    headers['X-MC-Track'] = 'opens, clicks_all'

    mail to:      to,
         subject: '',
         body:    ''
  end

  def mandrill(email, name, template, merge_vars = {})
    merge_vars.merge!({
      current_year: Date.today.year,
      logo_url: logo_url })

    mandrill = Mandrill::API.new(ENV['MANDRILL_API_KEY'])
    merge_vars = merge_vars.map { |k, v| { 'name' => k.to_s.upcase, 'content' => v } }
    template_content = []
    message = {
      'track_clicks'    => true,
      'tracking_domain' => nil,
      'from_email'      => 'noreply@powur.com',
      'to'              => [ { 'email' => email, 'name' => name } ],
      'from_name'       => 'Powur',
      'merge'           => true,
      'tags'            => [template],
      'merge_vars'      => [{ 'rcpt' => email, 'vars' => merge_vars }],
      'merge_language'  => 'mailchimp',
      'track_opens'     => true
    }
    mandrill.messages.send_template(
      template,
      template_content,
      message)
  end
end
