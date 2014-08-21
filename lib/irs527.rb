require "irs527/version"
require "irs527/form"
require "irs527/form_8871"
require "irs527/form_8872"
require "net/http"
module Irs527

  class Utility
    def self.retrieve_data(path)
      Net::HTTP.start("forms.irs.gov") do |http|
        req = Net::HTTP::Get.new("/app/pod/dataDownload/fullData")
        size = 0
        http.request(req) do |res|
          open("#{path}/data.zip", "w") do |io|
            res.read_body do |chunk|
              size += chunk.bytesize
              io.write(chunk)
              if Time.now.sec % 30 == 0
                puts "#{size.fdiv(1024**2)} MB d/l'ed"
              end
            end
          end
        end
      end

      Zip::File.open("#{path}/data.zip") do |zip|
        zip.each do |entry|
          @file = entry.name
          entry.extract("./#{entry.name}")
          puts "File extracted to #{path} as #{entry.name}"
        end
      end

      return @file
    end

    def self.parse(path)
      file = File.open(path)
      forms = []
      file_detail = file.readline.chomp.split("|")
      loop do
        begin
          line = file.readline.encode('UTF-8', invalid: :replace, replace: ' ')
        rescue EOFError
          break
        end

        line = line.chomp.split("|")
        if !line.empty?
          if ("BEARD12".include?(line[0]) && line[0] != "")
            form = Form.new(line)
            if form.supplementary?
              primary_form = forms.last
              form.update(primary_form)
            else
              forms << form.parse_line
            end
          else
            primary_form = forms.last
            if primary_form.incomplete?
              primary_form.truncated = line
              forms[-1] = primary_form.parse_line
            end
          end
        end
      end

      file.close
      return forms
    end
  end
end
