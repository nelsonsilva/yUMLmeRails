YUMLME_URL = 'http://yuml.me/diagram/scruffy;dir:LR;/class/'
FILENAME   = File.join(Rails.root, 'doc','diagrams',"#{Time.now.strftime('%Y%m%d-%H%M%S')}-model.png")

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
    sh %{if [ -x /usr/bin/eog ]; then eog #{FILENAME}; else open #{FILENAME}; fi & } do |ok, res|
      puts res
      puts "no eog (Gnome) nor open (Mac OS X) commands found" if !ok
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
