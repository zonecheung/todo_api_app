require 'rails_helper'

describe 'Tasks', 'GET /api/v1/tasks', type: :request do
  let!(:task1) { FactoryBot.create(:task, title: 'james') }
  let!(:task2) { FactoryBot.create(:task, title: 'buchanan') }
  let!(:task3) { FactoryBot.create(:task, title: 'barnes') }

  it 'should be_successful' do
    get api_v1_tasks_path
    expect(response).to have_http_status(200)
  end

  it 'should return 3 tasks' do
    get api_v1_tasks_path
    expect(response.body).to have_json_size(3).at_path('data')
  end

  it 'should have correct title in the tasks' do
    get api_v1_tasks_path
    expect(response.body).to(
      be_json_eql('"james"').at_path('data/0/attributes/title')
    )
    expect(response.body).to(
      be_json_eql('"buchanan"').at_path('data/1/attributes/title')
    )
    expect(response.body).to(
      be_json_eql('"barnes"').at_path('data/2/attributes/title')
    )
  end
end

describe 'Tags', 'GET /api/v1/tags/:id', type: :request do
  let!(:tag) { FactoryBot.create(:tag, title: 'avengers') }

  it 'should be successful' do
    get api_v1_tag_path(tag)
    expect(response).to have_http_status(200)
  end

  it 'should return correct tag' do
    get api_v1_tag_path(tag)
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  context 'when tag can\'t be found' do
    it 'should return :not_found status' do
      get api_v1_tag_path(0)
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      get api_v1_tag_path(0)
      expect(response.body).to(
        be_json_eql('"Tag #0 not found."').at_path('errors/base/0')
      )
    end
  end
end

describe 'Tags', 'POST /api/v1/tags', type: :request do
  let(:params) do
    {
      data: {
        type: 'undefined', id: 'undefined',
        attributes: { title: 'avengers' }
      }
    }
  end

  it 'should be successful' do
    post api_v1_tags_path, params: params
    expect(response).to have_http_status(:created)
  end

  it 'should increase the tag record count' do
    expect { post api_v1_tags_path, params: params }.to(
      change(Tag, :count).by(1)
    )
  end

  it 'should return the created object in json' do
    post api_v1_tags_path, params: params
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  context 'when tag can\'t be created' do
    before(:each) do
      params[:data][:attributes][:title] = ''
    end

    it 'should return 422 status' do
      post api_v1_tags_path, params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should not change the tag record count' do
      expect { post api_v1_tags_path, params: params }.not_to(
        change(Tag, :count)
      )
    end

    it 'should return the error message in json' do
      post api_v1_tags_path, params: params
      expect(response.body).to have_json_path('errors/title')
    end
  end
end

describe 'Tags', 'PATCH /api/v1/tags/:id', type: :request do
  let(:tag) { FactoryBot.create(:tag, title: 'justiceleague') }
  let(:params) do
    {
      data: {
        type: 'tags', id: tag.id,
        attributes: { title: 'avengers' }
      }
    }
  end

  it 'should be successful' do
    patch api_v1_tag_path(tag), params: params
    expect(response).to have_http_status(200)
  end

  it 'should return the updated object in json' do
    patch api_v1_tag_path(tag), params: params
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  context 'when tag can\'t be updated' do
    before(:each) do
      params[:data][:attributes][:title] = ''
    end

    it 'should return 422 status' do
      patch api_v1_tag_path(tag), params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return the error message in json' do
      patch api_v1_tag_path(tag), params: params
      expect(response.body).to have_json_path('errors/title')
    end
  end

  context 'when tag can\'t be found' do
    it 'should return :not_found status' do
      patch api_v1_tag_path(0), params: params
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      patch api_v1_tag_path(0), params: params
      expect(response.body).to(
        be_json_eql('"Tag #0 not found."').at_path('errors/base/0')
      )
    end
  end
end

describe 'Tags', 'DELETE /api/v1/tags/:id', type: :request do
  let!(:tag) { FactoryBot.create(:tag, title: 'justiceleague') }

  it 'should be successful' do
    delete api_v1_tag_path(tag)
    expect(response).to have_http_status(200)
  end

  it 'should change the tag record count' do
    expect { delete api_v1_tag_path(tag) }.to(
      change(Tag, :count).by(-1)
    )
  end

  it 'should return blank hash in json' do
    delete api_v1_tag_path(tag)
    expect(response.body).to eql({}.to_json)
  end

  context 'when tag can\'t be destroyed' do
    # Have to use mock object because we don't have before_destroy hook.
    let(:tag) { FactoryBot.build_stubbed(:tag) }

    before(:each) do
      allow(tag).to receive(:errors).and_return(base: %w[foo bar])
      allow(tag).to receive(:destroy).and_return(false)
      allow(Tag).to receive(:find_by_id).and_return(tag)
    end

    it 'should return 422 status' do
      delete api_v1_tag_path(tag)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return the error message in json' do
      delete api_v1_tag_path(tag)
      expect(response.body).to have_json_path('errors')
    end
  end

  context 'when tag can\'t be found' do
    it 'should return :not_found status' do
      delete api_v1_tag_path(0)
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      delete api_v1_tag_path(0)
      expect(response.body).to(
        be_json_eql('"Tag #0 not found."').at_path('errors/base/0')
      )
    end
  end
end
