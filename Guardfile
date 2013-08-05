group :development do

  guard 'bundler' do
    watch('Gemfile')
  end

  guard 'rack' do
    watch('Gemfile.lock')
    watch(%r{^(config|app|api)/.*})
  end

end

group :specs do
  guard 'rake', :task => 'spec:now' do
    watch(%r{^(config|app|api|models|lib|spec/api|spec/models)/.*})
  end
end