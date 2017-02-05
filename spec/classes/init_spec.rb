require 'spec_helper'
describe 'freeradius' do
  context 'with default values for all parameters' do
    it { should contain_class('freeradius') }
  end
end
