require 'rails_helper'


describe RequestsResult do

  it 'belongs to request' do
    result = create(:result, version: 'test')
    requests_result = create(:requests_result, result_id: result.id)
    expect(requests_result.result.version).to eql('test')
  end

  it 'save big value' do
    create(:requests_result, value: 6143854356)
  end

  it 'timestamp save' do
    requests_results = create(:requests_result)
    requests_results.timestamp = 1453280230407
    requests_results.save
    expect(RequestsResult.find(requests_results.id).timestamp).not_to be_nil
  end

end

