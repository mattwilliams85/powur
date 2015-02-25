require 'spec_helper'

describe Resource, type: :model do
  describe '@create' do
    context 'required fields presence validations' do
      it 'returns error messages' do
        resource = Resource.new
        resource.valid?
        expect(resource.errors.messages).to eq({
          user_id: ["User is required"],
          title: ["Title is required"],
          description: ["Description is required"],
          file_original_path: ["File original path is required"],
          file_type: ["File type is required", "File type can't be accepted"]
        })
      end
    end
  end
end
