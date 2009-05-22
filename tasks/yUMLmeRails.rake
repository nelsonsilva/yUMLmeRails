YUMLME_URL="http://yuml.me/diagram/scruffy/class/"
DIR=File.join(Dir.pwd, "diagrams")
FILENAME="#{DIR}/model_" << Time.new.strftime("%b_%d_%Y") << ".png"

def save_diagram url    
    FileUtils.mkdir_p DIR
    system "wget -O #{FILENAME} #{url}"
    FILENAME
end

namespace :yUMLmeRails do
  desc "Show model diagram"
  task :show => :environment do
    filename=save_diagram(YUMLME_URL << YUMLmeRails.generate_diagram)
    app=File.join(File.dirname(__FILE__), "..", "lib","shoes_app.rb")
    sh %{shoes #{app} #{filename} } do |ok, res|
        puts res
      if !ok
        puts "shoes not found (status = #{res.exitstatus})"
      end
    end
   end    

   desc "Get yUML URL"
   task :url => :environment do
        puts YUMLME_URL << YUMLmeRails.generate_diagram
   end
   
   desc "Download yUML model diagram"
   task :download => :environment do
       filename=save_diagram(YUMLME_URL << YUMLmeRails.generate_diagram)
       # TODO - Make the following work
       #require 'open-uri'
       #open(, "wb").
       # write(open("http://yuml.me/diagram/scruffy/class/" << YUMLmeRails.generate_diagram))
   end
end
