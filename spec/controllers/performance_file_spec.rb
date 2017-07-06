require 'rails_helper'


describe PerformanceFileController do

  describe '#create' do
    let(:perfmon_file_path) { File.join(fixture_path, 'perfmon.csv') }

    it 'status code is 200' do
      post :create, :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
      expect(response.code).to eql('200')
    end

    it 'response contains id' do
      post :create, :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
      response_body = JSON.parse response.body
      expect(response_body['id']).not_to be_nil
    end

    it 'response contains url' do
      post :create, :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
      response_body = JSON.parse response.body
      expect(response_body['url']).not_to be_nil
    end

    it 'row added to table' do
      post :create, :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
      response_body = JSON.parse response.body
      expect(PerformanceFile.find_by(id: response_body['id']).file).not_to be_nil
    end
  end


  describe '#show' do

    let(:perfmon_file_path) { File.join(fixture_path, 'perfmon.csv') }


    it 'get request file' do
      post :create, :file => Rack::Test::UploadedFile.new(perfmon_file_path, 'text/csv')
      response_body = JSON.parse response.body
      get :show, id: response_body['id']
      expect(response.body).to include('timeStamp,elapsed,label,grpThreads,allThreads')
    end



  end





end