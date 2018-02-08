require 'simplecov'
SimpleCov.start
require_relative '../lib/cache.rb'

Example = Struct.new(:name, :address) do
  def greeting
    "Hello #{name}!"
  end
end

include Mmpi
describe Cache do
  let(:cache) { Cache.new }
  let(:key) { "spec_key"}
  let(:object) { Example.new("Dave", "123 Main") }
  after { cache.delete(key) }
  describe '#get' do
    before { cache.set(key,object) }
    subject { cache.get(key).name }
    it { is_expected.to eq("Dave") }
  end

  describe '#set' do
    before { cache.set(key, object) }
    subject { cache.exist?(key) }
    it { is_expected.to be true }
  end
  describe '#delete' do
    before { cache.set(key, object) }
    it { expect(cache.exist?(key)).to be true
        cache.delete(key)
        expect(cache.exist?(key)).to be false
        }
  end
  describe 'exist' do
    subject { cache.exist?(key) }
    context 'when exist' do
      before { cache.set(key, object) }
      it { is_expected.to be true }
    end
    context 'when not exist' do
      it { is_expected.to be false }
    end
  end
end
