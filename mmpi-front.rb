require 'sinatra'
require 'json'
require 'mmpi'
require 'byebug'

include Mmpi
include ERB::Util

configure do
  enable :sessions
  set :cache, {}
end
before do
  p "session_id: #{session['session_id']}"
  p params
  p "request.xhr?: #{request.xhr?}"
  p settings.cache[session['session_id']].inspect
end

def get_data(session_id)
  settings.cache[session_id] ||= Test.new(:men, 'data/q_mmpi_men_ru_3.csv')
  test = settings.cache[session_id]
  if test.finished?
    { finished: true, question: '', number: '' }
  else
    test.get_question.merge(finished: false)
  end
end

def put_data(params, session_id)
  raise 'Not existed quiz!' if settings.cache[session_id].nil?
  settings.cache[session_id].put_answer(params[:question] => params[:answer])
end

get '/' do
  put_data(params, session['session_id']) if request.xhr?
  @data = get_data(session['session_id'])
  if request.xhr?
    content_type :json
    JSON.dump(@data)
  else
    erb :mmpi
  end
end
