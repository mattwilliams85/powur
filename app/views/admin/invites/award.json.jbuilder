json.properties do
  json.call(@user,
            :available_invites,
            :lifetime_invites_count,
            :open_invites_count,
            :redeemed_invites_count,
            :submitted_proposals_count)
end