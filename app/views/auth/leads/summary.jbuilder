siren json

klass :leads, :summary

json.properties do
  @metrics_data.each_pair do |k, v|
    json.set! k, v
  end
end

self_link request.path
