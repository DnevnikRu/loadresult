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

  it 'timestamp save' do
    performance_result = create(:performance_result)
    performance_result.timestamp = 1453280230407
    performance_result.save
    expect(PerformanceResult.find(performance_result.id).timestamp).not_to be_nil
  end


end
