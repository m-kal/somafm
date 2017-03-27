require 'rails_helper'
require 'rspec'
require 'sfm'

describe Sfm do
  it 'exist' do
    sfm = Sfm.new()
    expect(sfm).to_not be_nil
  end
end