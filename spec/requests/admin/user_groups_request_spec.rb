require 'spec_helper'

describe '/a/user_groups' do

  before :each do
    login_user
  end

  describe '/' do
    it 'renders the user groups' do
      create_list(:user_group, 3)

      get user_groups_path, format: :json
      expect_entities_count(3)
    end

    it 'renders a user group' do
      group = create(:user_group)

      get user_group_path(group.id), format: :json
      expect_classes('user_group')
    end

    it 'creates a user group' do
      post user_groups_path, id: 'bar', title: 'foo', format: :json

      expect_classes('user_group')
      expect_props(id: 'bar')
    end

    it 'deletes a user group' do
      group = create(:user_group)

      delete user_group_path(group.id), format: :json

      expect_entities_count(0)
    end
  end

  describe '/:id/requirements' do

    it 'creates a requirement' do
      group = create(:user_group)
      product = create(:product)

      post user_group_requirements_path(group.id),
           product_id: product.id,
           event_type: :purchase,
           quantity:   2,
           format:     :json

      list = json_body['entities']
        .find { |e| e['class'].include?('requirements') }
      expect(list['entities'].size).to eq(1)
    end

    let(:req) { create(:user_group_requirement) }
    let(:req_list) do
      json_body['entities'].find { |e| e['class'].include?('requirements') }
    end

    it 'updates a requirement' do
      patch user_group_requirement_path(req.id),
            event_type: :sale,
            quantity:   6,
            format:     :json

      req_item = req_list['entities'].first
      expect(req_item['properties']['event_type']).to eq('sale')
      expect(req_item['properties']['quantity']).to eq(6)
    end

    it 'deletes a requirement' do
      delete user_group_requirement_path(req.id), format: :json

      expect(req_list['entities'].size).to eq(0)
    end
  end

end
