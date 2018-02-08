require 'yaml'
require 'securerandom'
require 'mmpi'

include Mmpi

def new_test_key
  "#{Time.now.strftime("%Y_%m_%d_%H_%M")}_#{SecureRandom.urlsafe_base64}"
end

class AppServices
  RESULTS_DIR='./results'
  attr_reader :quiz

  def initialize(path_to_quiz, cache, key, gender = nil)
    @path_to_quiz = path_to_quiz
    @quiz = cache[key].nil? ? Test.new(gender, @path_to_quiz) : cache[key]
    cache[key] ||= @quiz
  end
  def get_question
    if @quiz.finished?
      { finished: true, question: '', number: '' }
    else
      @quiz.get_question.merge(finished: false)
    end
  end

  def put_answer(params)
    raise 'Not existed quiz!' if @quiz.nil?
    @quiz.put_answer(params[:question] => params[:answer])
    self
  end

  def save_result(key)
    File.write(path_to_result(key), @quiz.to_yaml)
    self
  end

  def load_result(key)
    path = path_to_result(key)
    @test = YAML.load_file(path) if File.exist?(path)
    Result.new(@test.answers, @test.gender) unless @test.nil?
  end

  def finished?
    @quiz.nil? ? false : @quiz.finished?
  end

  private

  def path_to_result(key)
    "#{RESULTS_DIR}/#{key}.yaml"
  end
end
