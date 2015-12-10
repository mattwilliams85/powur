siren json

klass :session

json.properties do
  json.join_grid_step1_youtube_embed_url(
    SystemSettings.get!('join_grid_step1_youtube_embed_url'))
  json.join_grid_step2_youtube_embed_url(
    SystemSettings.get!('join_grid_step2_youtube_embed_url'))
  json.preview_video_embed_url(
    SystemSettings.get!('preview_video_embed_url'))
end
