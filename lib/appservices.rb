require 'yaml'
require 'securerandom'
require 'mmpi'

include Mmpi

def new_test_key
  "#{Time.now.strftime('%Y_%m_%d_%H_%M')}_#{SecureRandom.urlsafe_base64}"
end

class String
  def to_b
    return true if self == 'true'
    return true if self == 'false'
    self.dup
  end
end

class AppServices
  RESULTS_DIR = './results'.freeze
  attr_reader :quiz

  def initialize(path_to_quiz = nil, cache = nil, key = nil, gender = nil)
    return if key.nil?
    @path_to_quiz = path_to_quiz
    @key = key
    @cache = cache
    if @cache.exist?(key)
      @quiz = @cache.get(@key)
    else
      @quiz = Test.new(gender, @path_to_quiz)
      @cache.set(@key, @quiz)
    end
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
    @quiz.put_answer(params[:question] => params[:answer].to_b)
    @cache.set(@key, @quiz)
    self
  end

  def save_result(key)
    File.write(path_to_result(key), @quiz.to_yaml)
    self
  end

  def load_result(key)
    return if key.nil?
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
