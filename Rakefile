require 'launchy'

desc 'Start a local server and open it in your browser'
task :server do
  Thread.new do
    sleep 1
    puts 'Opening in browser...'
    Launchy.open 'http://localhost:5000/'
  end

  puts 'Running local server...'
  sh 'ruby -run -e httpd . -p 5000'
end
