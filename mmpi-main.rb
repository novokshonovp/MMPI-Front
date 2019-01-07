require 'sinatra'
require 'json'
require 'byebug'
require 'sinatra/reloader'
require_relative './lib/appservices'
require_relative './lib/cache'
require_relative './lib/consts'
require 'gon-sinatra'
include ERB::Util

class Main < Sinatra::Base
  register Gon::Sinatra
  PATH_TO_QUIZ = {male: './data/q_mmpi_male_ru.csv',
                  female: './data/q_mmpi_female_ru.csv',
                  boy: './data/q_mmpi_boy_ru.csv',
                  girl: './data/q_mmpi_girl_ru.csv'}.freeze

  configure do
    enable :sessions
    set :bind, '0.0.0.0'
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
    redirect '/' if session[:key].nil?
    begin
      additional_info = {firstname: params[:firstname], age: params[:age], grade: params[:grade]}
      service = AppServices.new(PATH_TO_QUIZ[session[:sex]], Main.cache,
                                session[:key], session[:sex], additional_info)
    #rescue
    #  return 'Отсуствует библиотека утверждений по данному запросу.'
    end
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
    @result = AppServices.new
                         .load_result(params[:key])
    return 'Нет файла с результатами для данного идентификатора.' if @result.nil?
    gon.scales = @result.scales.map { |klass, object| [klass.to_sym, object.t_grade] }.to_h
    erb :result
  end

  def self.cache
    @cache ||= Cache.new
  end
end
