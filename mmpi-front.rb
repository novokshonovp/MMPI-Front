require 'sinatra'
require 'json'
require 'byebug'
require 'sinatra/reloader'
require_relative './lib/appservices'
require_relative './lib/cache'
require 'gon-sinatra'


include ERB::Util

class Main < Sinatra::Base
  register Gon::Sinatra
  PATH_TO_QUIZ = './data/q_mmpi_men_ru_3.csv'
  configure do
    enable :sessions
  end

  before do
    if self.class.development?
      p "session_id: #{session['session_id']}"
      p params
      p "request.xhr?: #{request.xhr?}"
    end
  end

  get '/' do
    session[:key] = new_test_key
    erb :mmpi_welcome
  end

  get '/mmpi' do
    session[:sex] = params[:sex].to_sym if params[:sex]
    service = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key], session[:sex])
    service.put_answer(params) if request.xhr?
    @data = service.get_question
    if request.xhr?
      content_type :json
      JSON.dump(@data)
    else
      erb :mmpi
    end
  end

  get '/finished' do
    service = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key])
    service.save_result(session[:key])
    @test_link = "#{request.base_url}/result?key=#{session[:key]}"
    @key = session[:key]
    erb :finished
  end

  get '/result' do
    @result = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key])
                         .load_result(params[:key])
    @result ||= 'Нет файла с результатами для данного идентификатора.'
    gon.scales = @result.scales.map { |klass, object| [klass.to_sym, object.t_grade] }.to_h
    erb :result
  end

  def self.cache
    @cache ||= Cache.new
  end
end

run Main.run!
