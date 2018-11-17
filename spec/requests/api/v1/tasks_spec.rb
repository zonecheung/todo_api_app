require 'rails_helper'

describe 'Tasks', 'GET /api/v1/tasks', type: :request do
  let!(:task1) { FactoryBot.create(:task, title: 'james') }
  let!(:task2) do
    FactoryBot.create(:task, title: 'buchanan', tags: %w[steve rogers])
  end
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

  it 'should have correct number of tags in the tasks' do
    get api_v1_tasks_path
    expect(response.body).to(
      have_json_size(0).at_path('data/0/relationships/tags/data')
    )
    expect(response.body).to(
      have_json_size(2).at_path('data/1/relationships/tags/data')
    )
    expect(response.body).to(
      have_json_size(0).at_path('data/2/relationships/tags/data')
    )
  end
end

describe 'Tasks', 'GET /api/v1/tasks/:id', type: :request do
  let!(:task) do
    FactoryBot.create(:task, title: 'avengers', tags: %w[infinity war])
  end

  it 'should be successful' do
    get api_v1_task_path(task)
    expect(response).to have_http_status(200)
  end

  it 'should return correct task' do
    get api_v1_task_path(task)
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  it 'should have correct number of tags in the task' do
    get api_v1_task_path(task)
    expect(response.body).to(
      have_json_size(2).at_path('data/relationships/tags/data')
    )
  end

  context 'when task can\'t be found' do
    it 'should return :not_found status' do
      get api_v1_task_path(0)
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      get api_v1_task_path(0)
      expect(response.body).to(
        be_json_eql('"Task #0 not found."').at_path('errors/base/0')
      )
    end
  end
end

describe 'Tasks', 'POST /api/v1/tasks', type: :request do
  let(:params) do
    {
      data: {
        type: 'undefined', id: 'undefined',
        attributes: { title: 'avengers', tags: %w[infinity war] }
      }
    }
  end

  it 'should be successful' do
    post api_v1_tasks_path, params: params
    expect(response).to have_http_status(:created)
  end

  it 'should increase the tasks record count' do
    expect { post api_v1_tasks_path, params: params }.to(
      change(Task, :count).by(1)
    )
  end

  it 'should increase the taggings record count' do
    expect { post api_v1_tasks_path, params: params }.to(
      change(Tagging, :count).by(2)
    )
  end

  it 'should increase the tags record count' do
    expect { post api_v1_tasks_path, params: params }.to(
      change(Tag, :count).by(2)
    )
  end

  it 'should return the created object in json' do
    post api_v1_tasks_path, params: params
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  it 'should also return the tags of created object in json' do
    post api_v1_tasks_path, params: params
    expect(response.body).to(
      have_json_size(2).at_path('data/relationships/tags/data')
    )
  end

  context 'when task can\'t be created' do
    before(:each) do
      params[:data][:attributes][:title] = ''
    end

    it 'should return 422 status' do
      post api_v1_tasks_path, params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should not change the tasks record count' do
      expect { post api_v1_tasks_path, params: params }.not_to(
        change(Task, :count)
      )
    end

    it 'should not change the tags record count' do
      expect { post api_v1_tasks_path, params: params }.not_to(
        change(Tag, :count)
      )
    end

    it 'should return the error message in json' do
      post api_v1_tasks_path, params: params
      expect(response.body).to have_json_path('errors/title')
    end
  end
end

describe 'Tasks', 'PATCH /api/v1/tasks/:id', type: :request do
  let!(:task) do
    FactoryBot.create(:task, title: 'justiceleague', tags: %w[batman superman])
  end
  let(:params) do
    {
      data: {
        type: 'tasks', id: task.id,
        attributes: { title: 'avengers', tags: %w[ironman batman] }
      }
    }
  end

  it 'should be successful' do
    patch api_v1_task_path(task), params: params
    expect(response).to have_http_status(200)
  end

  it 'should not increase the taggings record count' do
    expect { patch api_v1_task_path(task), params: params }.not_to(
      change(Tagging, :count)
    )
  end

  it 'should increase the tags record count' do
    expect { patch api_v1_task_path(task), params: params }.to(
      change(Tag, :count).by(1)
    )
  end

  it 'should return the updated object in json' do
    patch api_v1_task_path(task), params: params
    expect(response.body).to(
      be_json_eql('"avengers"').at_path('data/attributes/title')
    )
  end

  it 'should also return the tags of updated object in json' do
    patch api_v1_task_path(task), params: params
    expect(response.body).to(
      have_json_size(2).at_path('data/relationships/tags/data')
    )
  end

  context 'when task can\'t be updated' do
    before(:each) do
      params[:data][:attributes][:title] = ''
    end

    it 'should return 422 status' do
      patch api_v1_task_path(task), params: params
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return the error message in json' do
      patch api_v1_task_path(task), params: params
      expect(response.body).to have_json_path('errors/title')
    end
  end

  context 'when task can\'t be found' do
    it 'should return :not_found status' do
      patch api_v1_task_path(0), params: params
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      patch api_v1_task_path(0), params: params
      expect(response.body).to(
        be_json_eql('"Task #0 not found."').at_path('errors/base/0')
      )
    end
  end
end

describe 'Tasks', 'DELETE /api/v1/tasks/:id', type: :request do
  let!(:task) do
    FactoryBot.create(:task, title: 'justiceleague', tags: %w[batman superman])
  end

  it 'should be successful' do
    delete api_v1_task_path(task)
    expect(response).to have_http_status(200)
  end

  it 'should change the tasks record count' do
    expect { delete api_v1_task_path(task) }.to(
      change(Task, :count).by(-1)
    )
  end

  it 'should not change the taggings record count' do
    expect { delete api_v1_task_path(task) }.to(
      change(Tagging, :count).by(-2)
    )
  end

  it 'should not change the tags record count' do
    expect { delete api_v1_task_path(task) }.not_to(
      change(Tag, :count)
    )
  end

  it 'should return blank hash in json' do
    delete api_v1_task_path(task)
    expect(response.body).to eql({}.to_json)
  end

  context 'when task can\'t be destroyed' do
    # Have to use mock object because we don't have before_destroy hook.
    let(:task) { FactoryBot.build_stubbed(:task) }

    before(:each) do
      allow(task).to receive(:errors).and_return(base: %w[foo bar])
      allow(task).to receive(:destroy).and_return(false)
      allow(Task).to receive(:find_by_id).and_return(task)
    end

    it 'should return 422 status' do
      delete api_v1_task_path(task)
      expect(response).to have_http_status(:unprocessable_entity)
    end

    it 'should return the error message in json' do
      delete api_v1_task_path(task)
      expect(response.body).to have_json_path('errors')
    end
  end

  context 'when task can\'t be found' do
    it 'should return :not_found status' do
      delete api_v1_task_path(0)
      expect(response).to have_http_status(:not_found)
    end

    it 'should return an error message' do
      delete api_v1_task_path(0)
      expect(response.body).to(
        be_json_eql('"Task #0 not found."').at_path('errors/base/0')
      )
    end
  end
end
