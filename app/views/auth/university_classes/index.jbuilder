siren json

klass :university_classes, :list
json.entities @university_classes, partial: 'item', as: :university_class

self_link request.path
