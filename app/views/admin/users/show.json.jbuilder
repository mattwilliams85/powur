siren json

users_json.item_init

users_json.detail_properties

if params[:user_totals]
  json.properties do
    json.totals do
      json.team_counts do
        json.all User.with_ancestor(@user.id).count
        json.certified User.with_ancestor(@user.id).with_purchases.count
      end
      json.lead_counts do
        json.lifetime do
          json.submitted @user.leads.submitted.count
          json.installed @user.leads.installed.count
        end
        json.month do
          month_start = Time.zone.today.beginning_of_month
          json.submitted @user.leads.submitted(from: month_start).count
          json.installed @user.leads.installed(from: month_start).count
        end
      end
    end
  end
end

users_json.admin_entities

actions \
  users_json.update_action(admin_user_path(@user)),
  action(:eligible_parents, :get, eligible_parents_admin_user_path(@user)),
  action(:move, :post, move_admin_user_path(@user))
  .field(:parent_id,
         :select,
         required:  true,
         reference: { url:  eligible_parents_admin_user_path(@user),
                      id:   :id,
                      name: :full_name })

self_link admin_user_path(@user)
