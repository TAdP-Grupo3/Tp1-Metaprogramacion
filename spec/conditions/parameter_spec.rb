require 'rspec'
require_relative '../../src/aspects'
require_relative '../../spec/spec_helper'


describe '.has_parameters' do
  include Class_helper

  let(:test_class) do
    fake_class = Class.new
    self.add_method(:public, fake_class, :public_no_param) {}
    self.add_method(:public, fake_class, :public_one_param) { |x|}
    self.add_method(:private, fake_class, :private_no_param) {}
    self.add_method(:private, fake_class, :private_two_param) { |param1, param2, param3=0|}
  end

  let(:public_no_param) { self.get_public_method(test_class, :public_no_param) }
  let(:public_one_param) { self.get_public_method(test_class, :public_one_param) }
  let(:private_no_param) { self.get_private_method(test_class, :private_no_param) }
  let(:private_two_param) { self.get_private_method(test_class, :private_two_param) }

  context 'filter only by ammount' do

    it 'returns methods with no parameter' do
      expect(Aspects.has_parameters(0).match(test_class)).to contain_exactly(public_no_param, private_no_param)
    end

    it 'returns methods with one parameter' do
      expect(Aspects.has_parameters(1).match(test_class)).to contain_exactly(public_one_param)
    end

    it 'returns methods with three parameter' do
      expect(Aspects.has_parameters(3).match(test_class)).to contain_exactly(private_two_param)
    end

    it 'returns no methods' do
      expect(Aspects.has_parameters(100).match(test_class)).to be_empty
    end

  end

  context 'filter optional arguments only' do

    it 'returns methods with no optional parameters' do
      expect(Aspects.has_parameters(1, Aspects.optional).match(test_class)).to contain_exactly(private_two_param)
    end

  end

  context 'filter mandatory arguments only' do

    it 'returns methods with no optional parameters' do
      expect(Aspects.has_parameters(2, Aspects.mandatory).match(test_class)).to contain_exactly(private_two_param)
    end

  end

  context 'filter parameter name by regex' do

    it 'returns methods parameter named x' do
      expect(Aspects.has_parameters(1, /x/).match(test_class)).to contain_exactly(public_one_param)
    end

    it 'returns methods parameter/s named like param*' do
      expect(Aspects.has_parameters(3, /param/).match(test_class)).to contain_exactly(private_two_param)
    end

    it 'no method is return' do
      expect(Aspects.has_parameters(1, /regexLoco/).match(test_class)).to be_empty
    end

  end
end


