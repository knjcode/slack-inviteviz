require 'launchy'

desc 'Export history of invitations'
task :export do
  sh 'ruby export.rb'
end

desc 'Start a local server and open it in your browser'
task :server do
  Thread.new do
    sleep 4
    puts 'Opening in browser...'
    Launchy.open 'http://localhost:5000/'
  end

  puts 'Running local server...'
  sh 'ruby -run -e httpd . -p 5000'
end
