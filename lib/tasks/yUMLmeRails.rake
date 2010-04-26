YUMLME_URL="http://yuml.me/diagram/scruffy/class/"
FILENAME=File.join(Rails.root, 'doc','diagrams',"model.#{Time.now.strftime('%Y%m%d-%H%M%S')}.png")

def generate_diagram(file=FILENAME)
  require 'open-uri'
  FileUtils.mkdir_p File.dirname(file)
  File.open(file,'wb') do |f|
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
  task :download, :filename, :needs => :environment do |t, args|  
    args.with_defaults(:filename => FILENAME)
    generate_diagram args[:filename]
  end                                 
  
end
                                     

