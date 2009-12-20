YUMLME_URL="http://yuml.me/diagram/scruffy/class/"
FILENAME=File.join(RAILS_ROOT, 'doc','diagrams',"model.#{Time.now.strftime('%Y%m%d-%H%M%S')}.png")

def generate_diagram 
  require 'open-uri'
  FileUtils.mkdir_p File.dirname(FILENAME)
  File.open(FILENAME,'wb') do |f|
    f.write(open("#{YUMLME_URL}#{CGI.escape(YUMLmeRails.generate_diagram)}").read)
  end
end

namespace :yUMLmeRails do

  desc "Show model diagram"
  task :show => :environment do
    generate_diagram

    app=File.join(File.dirname(__FILE__), "..", "lib","shoes_app.rb")
    sh %{shoes #{app} #{FILENAME} } do |ok, res|
      puts res
      puts "shoes not found (status = #{res.exitstatus})" if !ok
    end
  end
  
  desc "Get yUML URL"
  task :url => :environment do
    puts YUMLME_URL << YUMLmeRails.generate_diagram
  end

  desc "Download yUML model diagram #{File.dirname(FILENAME)}"
  task :download => :environment do
    generate_diagram
  end
end




