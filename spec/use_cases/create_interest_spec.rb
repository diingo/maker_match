require 'spec_helper'

describe GladiatorMatch::CreateInterest do

  let(:result) { described_class.run(@params) }

  before do
    @params = { expertise: 'beginner', name: 'haskell'}
  end

  context 'error handling' do
    it 'ensures expertise is either beginner, intermediate, or advanced' do
      @params[:expertise] = 'awesome'

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_expertise)
    end

    it 'ensures name is not nil or blank' do
      @params[:name] = nil
      result = described_class.run(@params)

      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_name)

      @params[:name] = ''
      result = described_class.run(@params)
      expect(result.success?).to eq(false)
      expect(result.error).to eq(:invalid_name)
    end
  end

  it 'creates an interest' do
    expect(result.success?).to eq(true)

    expect(result.interest.name).to eq('haskell')
    expect(result.interest.expertise).to eq('beginner')
  end
end