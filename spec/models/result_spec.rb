require 'rails_helper'

describe Result do
  it 'has a valid factory' do
    expect(build(:result)).to be_valid
  end

  it 'invalid without version' do
    expect(build(:result, :version => nil)).not_to be_valid
  end

  it 'invalid without duration' do
    expect(build(:result, :duration => nil)).not_to be_valid
  end

  it 'invalid without rps' do
    expect(build(:result, :rps => nil)).not_to be_valid
  end

  it 'invalid without profile' do
    expect(build(:result, :profile => nil)).not_to be_valid
  end

  it 'invalid with test_run_date in wrong format' do
    expect(build(:result, :test_run_date => 'das')).not_to be_valid
  end

  it 'do not create not valid object' do
    expect{create(:result, :test_run_date => 'das')}.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'has many requests_result' do
     result = create(:result)
     create(:requests_result, result_id: result.id)
     create(:requests_result, result_id: result.id)
     expect(result.requests_results.count).to eql(2)
  end


end
