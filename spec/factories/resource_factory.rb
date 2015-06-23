FactoryGirl.define do
  factory :resource do
    user_id 1
    title 'Title'
    description 'Description'
    file_original_path 'http://eyecuelab.com/doc.pdf'
    is_public true
    topic_id 1
  end

  factory :resource_topic do
    title 'Title'
  end
end
