require 'sinatra'
require 'json'
require 'byebug'
require 'sinatra/reloader'
require_relative './lib/appservices'


include ERB::Util

class Main < Sinatra::Base
  PATH_TO_QUIZ = './data/q_mmpi_men_ru_3.csv'
  configure do
    enable :sessions
    set :cache, {}
  end

  before do
    if self.class.development?
      p "session_id: #{session['session_id']}"
      p params
      p "request.xhr?: #{request.xhr?}"
      p Main.cache[session[:key]].inspect
    end
  end

  get '/' do
    session[:key] = new_test_key unless request.xhr?
    service = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key], :men)
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
    service = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key], :men)
    service.save_result(session[:key])
    @test_link = "#{request.base_url}/result?key=#{session[:key]}"
    @key = session[:key]
    erb :finished
  end

  get '/result' do
    @result = AppServices.new(PATH_TO_QUIZ, Main.cache, session[:key], :men)
                         .load_result(params[:key])
    @result ||= 'Нет файла с результатами для данного идентификатора.'
    erb :result
  end

end

run Main.run!
