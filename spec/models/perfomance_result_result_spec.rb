require 'rails_helper'

describe PerfomanceResult do

  it 'belong to results' do
    result = create(:result, version: 'test')
    perfomance_result = create(:perfomance_result, result_id: result.id)
    expect(perfomance_result.result.version).to eql('test')
  end


end
