namespace :yUMLmeRails do
  desc "Show model diagram"
  task :app do
       system "shoes app.rb"
   end    

   desc "Get yUML URL"
   task :model_diagram_url => :environment do
        puts "http://yuml.me/diagram/scruffy/class/" << YUMLmeRails.generate_diagram
   end
   
   desc "Download yUML model diagram"
   task :model_diagram => :environment do
       url="http://yuml.me/diagram/scruffy/class/" << YUMLmeRails.generate_diagram
       DIR="diagrams"
       FileUtils.mkdir_p DIR
       filename="#{DIR}/model_" << Time.new.strftime("%b_%d_%Y") << ".png"
       system "wget -O #{filename} #{url}" 
       # TODO - Make the following work
       #require 'open-uri'
       #open(, "wb").
       # write(open("http://yuml.me/diagram/scruffy/class/" << YUMLmeRails.generate_diagram))
   end
end
