require 'sinatra'
require 'sinatra/reloader' if development?

def parse_fields(fields)
  fields.strip.split('---')
    .map { |f| f.strip.split }
    .tap(&:shift)
    .map { |f| Hash[f.each_slice(2).to_a] }
end

get '/' do
  haml :index
end

post '/upload' do
  fields = `pdftk #{params[:pdf][:tempfile].path} dump_data_fields`
  puts parse_fields(fields).inspect
end
