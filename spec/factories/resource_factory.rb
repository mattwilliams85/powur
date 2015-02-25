FactoryGirl.define do
  factory :resource do
    user_id 1
    title 'Title'
    description 'Description'
    file_original_path 'http://eyecuelab.com/doc.pdf'
    file_type 'application/pdf'
    is_public true
  end
end
