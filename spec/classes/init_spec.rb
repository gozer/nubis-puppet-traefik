require 'spec_helper'
describe 'nubis_traefik' do
  context 'with default values for all parameters' do
    it { should contain_class('nubis_traefik') }
  end
end
