require 'simplecov'
require_relative '../lib/appservices.rb'


describe AppServices do
  let(:app) { AppServices.new('./spec/fixtures/q_mmpi_men_ru_1.csv', cache, key, :men) }
  let(:cache) { Hash.new }
  let(:key) { 'test_key' }
  describe '#get_question' do
    subject { app.get_question }
    context 'when not finished' do
      it { is_expected.to eq ( { question:'Номер данного пункта следует обвести кружочком',
                              number: '14', finished: false} ) }
    end
    context 'when finished' do
      before do
        app.get_question
        app.put_answer( { question: '14', answer: true } )
      end
      it { is_expected.to eq ( { finished: true, question: '', number: '' } ) }
    end
  end

  describe '#put_answer' do
    before do
     app.get_question
     app.put_answer( { question: question, answer: true })
   end
    let(:question) { '14' }
    it { expect(cache[key].quiz[question][:answer]).to be true }
    it { expect(cache[key].quiz[question][:is_checked]).to be true }
  end

  describe '#finished?' do
    before { app.get_question }
    subject { app.finished? }
    context 'when finished' do
      before { app.put_answer( { question: '14', answer: true } ) }
      it { is_expected.to be true }
    end
    context 'when not finished' do
      it { is_expected.to be false}
    end
  end
  describe 'results' do
    before do
      app.put_answer( { question: '14', answer: true } )
      stub_const('AppServices::RESULTS_DIR', results_dir)
      allow(File).to receive(:open).with(path_to_result,'r:bom|utf-8').and_call_original
      expect(File).to receive(:write).with(path_to_result, app.quiz.to_yaml)
    end
    let(:path_to_result) { "#{AppServices::RESULTS_DIR}/#{key}.yaml"}
    context 'when save' do
      let(:results_dir) { './spec/tmp' }
      subject  {app.save_result(key) }
      it { is_expected.to eq(app) }
    end
    context 'when load' do
      let(:results_dir) { './spec/fixtures' }
      subject { app.load_result(key)}
      it { is_expected.to eq "text"}
    end
  end
end
