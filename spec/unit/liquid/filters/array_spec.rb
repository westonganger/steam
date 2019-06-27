require 'spec_helper'

describe 'Locomotive::Steam::Liquid::Filters::Array' do

  include ::Liquid::StandardFilters
  include Locomotive::Steam::Liquid::Filters::Base
  include Locomotive::Steam::Liquid::Filters::Array

  describe '#pop' do

    let(:array) { ['a', 'b', 'c'] }

    subject { pop(array) }

    it { is_expected.to eq(['a', 'b']) }

    context 'removing last n elements' do

      subject { pop(array, 2) }

      it { is_expected.to eq(['a']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#push' do

    let(:array) { ['a', 'b', 'c'] }

    subject { push(array, 'd') }

    it { is_expected.to eq(['a', 'b', 'c', 'd']) }

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#shift' do

    let(:array) { ['a', 'b', 'c'] }

    subject { shift(array) }

    it { is_expected.to eq(['b', 'c']) }

    context 'removing n first elements' do

      subject { shift(array, 2) }

      it { is_expected.to eq(['c']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  describe '#unshift' do

    let(:array) { ['a', 'b', 'c'] }

    subject { unshift(array, '1') }

    it { is_expected.to eq(['1', 'a', 'b', 'c']) }

    context 'adding n elements' do

      subject { unshift(array, ['1', '2']) }

      it { is_expected.to eq(['1', '2', 'a', 'b', 'c']) }

    end

    context 'passing a non array input' do

      let(:array) { 'Hello world' }
      it { is_expected.to eq('Hello world') }

    end

  end

  context("group_by filter") do
    it("successfully group array of Jekyll::Page's") do
      let(:array) { ['a', 'b', 'a', 'c'] }

      grouping = group_by(array, "layout")

      grouping.each do |g|
        expect(["default", "nil", ""].include?(g["name"])).to eq(true)

        case g["name"]
        when "default" then
          expect(g["items"].is_a?(Array)).to eq(true)

          qty = Utils::Platforms.really_windows? ? (4) : (5)

          expect(g["items"].size).to eq(qty)
        when "nil" then
          expect(g["items"].is_a?(Array)).to eq(true)
          expect(g["items"].size).to eq(2)
        when "" then
          expect(g["items"].is_a?(Array)).to eq(true)

          qty = Utils::Platforms.really_windows? ? (15) : (16)

          expect(g["items"].size).to eq(qty)
        else
          # do nothing
        end
      end
    end

    it("include the size of each grouping") do
      grouping = @filter.group_by(@filter.site.pages, "layout")

      grouping.each do |g| 
        expect(g["size"]).to eq(g["items"].size)
      end
    end
  end

  context("group_by_exp filter") do
    it("successfully group array of Jekyll::Page's") do
      groups = @filter.group_by_exp(@filter.site.pages, "page", "page.layout | upcase")

      groups.each do |g|
        expect(["DEFAULT", "NIL", ""].include?(g["name"])).to eq(true)

        case g["name"]
        when "DEFAULT" then
          expect(g["items"].is_a?(Array)).to eq(true)
          qty = Utils::Platforms.really_windows? ? (4) : (5)
          expect(g["items"].size).to eq(qty)
        when "nil" then
          expect(g["items"].is_a?(Array)).to(eq(true))
          expect(g["items"].size).to eq(2)
        when "" then
          expect(g["items"].is_a?(Array)).to(eq(true))
          qty = Utils::Platforms.really_windows? ? (15) : (16)
          expect(g["items"].size).to eq(qty)
        else
          # do nothing
        end
      end
    end

    it("include the size of each grouping") do
      groups = @filter.group_by_exp(@filter.site.pages, "page", "page.layout")
      groups.each { |g| expect(g["size"]).to eq(g["items"].size) }
    end

    it("allow more complex filters") do
      items = [{ "version" => "1.0", "result" => "slow" }, { "version" => "1.1.5", "result" => "medium" }, { "version" => "2.7.3", "result" => "fast" }]
      result = @filter.group_by_exp(items, "item", "item.version | split: '.' | first")
      expect(result.size).to eq(2)
    end

    it("be equivalent of group_by") do
      actual = @filter.group_by_exp(@filter.site.pages, "page", "page.layout")
      expected = @filter.group_by(@filter.site.pages, "layout")
      expect(actual).to eq(expected)
    end

    it("return any input that is not an array") do
      expect(@filter.group_by_exp("some string", "la", "le")).to eq("some string")
    end

    it("group by full element (as opposed to a field of the element)") do
      items = ["a", "b", "c", "d"]
      result = @filter.group_by_exp(items, "item", "item")
      expect(result.length).to eq(4)
      expect(result.first["items"]).to eq(["a"])
    end

    it("accept hashes") do
      hash = { 1 => "a", 2 => "b", 3 => "c", 4 => "d" }
      result = @filter.group_by_exp(hash, "item", "item")
      expect(result.length).to eq(4)
    end
  end

end
