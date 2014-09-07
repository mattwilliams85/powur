siren json

klass :rank_achievements, :list

json.entities @rank_achievements, partial: 'item', as: :rank_achievement

if paging?
  actions \
    action(:list, :get, @rank_achievements_path).
      field(:page, :number, value: paging[:current_page], min: 1, max: paging[:page_count], required: false).
      field(:sort, :select, options: paging[:sorts], value: paging[:current_sort], required: false)
end

links link(:self, @rank_achievements_path)
