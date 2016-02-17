require 'rails_helper'

describe PerformanceResult do

  it 'belong to results' do
    result = create(:result, version: 'test')
    perfomance_result = create(:performance_result, result_id: result.id)
    expect(perfomance_result.result.version).to eql('test')
  end

  it 'save big value' do
    create(:performance_result, value: 6143854356)
  end


end
