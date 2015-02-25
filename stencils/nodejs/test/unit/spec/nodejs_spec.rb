require_relative 'spec_helper'

describe "|{ cookbook['name'] }|::|{ options['name'] }|" do
  let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }
end
