require 'rails_helper'


describe RequestsResult do

  it 'belongs to request' do
    result = create(:result, version: 'test')
    requests_result = create(:requests_result, result_id: result.id)
    expect(requests_result.result.version).to eql('test')
  end

end

