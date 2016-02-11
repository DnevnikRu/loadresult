require 'rails_helper'

describe Result do
  it 'has a valid factory' do
    expect(build(:result)).to be_valid
  end

end
