require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/json'
require 'digest/md5'
require 'json'
require 'pdf_forms'
require 'fileutils'

$forms ||= begin
             JSON.parse(File.read('state.json'))
           rescue => ex
             $stderr.puts "Error recovering state: #{ex.message}"
             {}
           end
$tmpdir = File.expand_path('../tmp', __FILE__)

def parse_field(field)
  field.map { |f| f.split(': ', 2) }.each_with_object({}) do |(k, v), hash|
    if hash[k]
      # Handle multiple FieldStateOptions by turning it into an array
      hash[k] = Array(hash[k])
      hash[k] << v
    else
      hash[k] = v
    end
  end
end

def parse_fields(text)
  text.strip.split('---')
    .map { |f| f.strip.split("\n") }
    .tap(&:shift)
    .map { |f| parse_field(f) }
end

def normalize_names(fields)
  fields.each do |field|
    field['FieldId'] = (field['FieldName'] || '').gsub(/[\[\]\._]/, '-')
  end
  fields
end

def save_state
  File.open('state.json', 'w') do |f|
    f.puts JSON.pretty_generate($forms)
  end
end

get '/' do
  haml :index
end

get '/tmp/:dir/:path' do |dir, path|
  send_file File.join($tmpdir, dir, path)
end

get '/form/:id' do |id|
  haml :index
end

get '/api/forms' do
  json $forms.keys
end

get '/api/fields/:id' do |id|
  json $forms[id]['fields']
end

post '/api/fieldnames/:id' do |id|
  names = params[:names]
  form = $forms[id]

  names.each do |field_id, field_human_name|
    form['fields'].detect { |f| f['FieldId'] == field_id }['FieldHumanName'] = field_human_name
  end

  save_state

  'ok'
end

post '/api/render/:id' do |id|
  fields = params[:fields]
  form = $forms[id]

  fields = fields.map do |field_id, field_value|
    field = form['fields'].detect { |f| f['FieldId'] == field_id }
    val = field_value

    [
      field['FieldName'],
      val,
    ]
  end

  dest_pdf = File.join($tmpdir, "#{Time.now.to_i}.pdf")

  PdfForms.new('/usr/local/bin/pdftk')
    .fill_form(File.join($tmpdir, 'src', id), dest_pdf, Hash[fields])

  dest = File.join($tmpdir, Time.now.to_i.to_s)
  Dir.mkdir(dest)

  `convert -density 90 #{dest_pdf} #{dest}/out.png`

  JSON.generate(
    dirname: File.basename(dest),
    files: Dir["#{dest}/out-*.png"].map { |f| File.basename(f) },
  )
end

post '/upload' do
  fields = `pdftk #{params[:pdf][:tempfile].path} dump_data_fields`
  formid = Digest::MD5.hexdigest(params[:pdf][:filename])
  src_dir = File.join($tmpdir, 'src')
  FileUtils.mkdir_p(src_dir)
  FileUtils.copy(params[:pdf][:tempfile], File.join(src_dir, formid))
  $forms[formid] = {
    'fields' => normalize_names(parse_fields(fields)),
    'path' => File.join(src_dir, formid),
  }
  redirect '/form/' + formid
end
