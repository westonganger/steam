require 'spec_helper'

describe Locomotive::Steam::Liquid::Filters::Misc do

  include ::Liquid::StandardFilters
  include Locomotive::Steam::Liquid::Filters::Base
  include Locomotive::Steam::Liquid::Filters::Misc

  it 'returns the input string every n occurences' do
    expect(str_modulo('foo', 0, 3)).to eq ''
    expect(str_modulo('foo', 1, 3)).to eq ''
    expect(str_modulo('foo', 2, 3)).to eq 'foo'
    expect(str_modulo('foo', 3, 3)).to eq ''
    expect(str_modulo('foo', 4, 3)).to eq ''
    expect(str_modulo('foo', 5, 3)).to eq 'foo'
  end

  it 'returns default values if the input is empty' do
    expect(default('foo', 42)).to eq 'foo'
    expect(default('', 42)).to eq 42
    expect(default(nil, 42)).to eq 42
  end

  describe 'index' do

    let(:array)     { [1, 2, 3, 4] }
    let(:position)  { 2 }
    subject { index(array, position) }

    it { is_expected.to eq 3 }

  end

  describe 'split' do

    let(:string) { nil }
    subject { split(string, ',') }

    it { is_expected.to eq [] }

    context 'a not nil value' do

      let(:string) { 'foo,bar'}

      it { is_expected.to eq %w(foo bar) }

    end

  end

  describe 'random' do

    context 'from an integer' do

      subject { random(4) }
      it { is_expected.to be_a_kind_of(Integer) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

    context 'from a string' do

      subject { random('4') }
      it { is_expected.to be_a_kind_of(Integer) }
      it { is_expected.to satisfy { |n| n >=0 && n < 4 } }

    end

  end

  it 'returns a random number' do
    random_number = random(4)
    expect(random_number.class).to eq Integer
  end

  describe '#map' do

    context 'to_liquid' do

      subject { map(['4', '5'], 'to_liquid') }
      it { is_expected.to eq(['4', '5']) }

    end

    context 'to_i' do

      subject { map(['4', '5'], 'to_i') }
      it { is_expected.to eq([4, 5]) }

    end

    context 'to_f' do

      subject { map(['4.3', '5.2'], 'to_f') }
      it { is_expected.to eq([4.3, 5.2]) }

    end

    context 'property' do

      subject { map([{ 'title' => 'a' }, { 'title' => 'b' }], 'title') }
      it { is_expected.to eq(['a', 'b']) }

    end

  end

  describe '#hexdigest' do

    let(:key)     { 'key' }
    let(:data)    { 'The quick brown fox jumps over the lazy dog' }
    let(:digest)  { nil }

    subject { hexdigest(data, key, digest) }

    it 'returns the authentication code as a hex-encoded string' do
      expect(subject).to eq 'de7c9b85b8b78aa6bc8a7a36f70a90701c9db4d9'
    end

  end

  describe '#shuffle' do

    let(:array) { [1, 2, 3, 4] }

    subject { 5.times.map{ shuffle(array) } }

    it 'returns an array in a random order' do
      expect(subject.all?{|x| x == array}).to eq(false)
      expect(subject.all?{|x| x.sort == array}).to eq(true)
    end

  end

end
