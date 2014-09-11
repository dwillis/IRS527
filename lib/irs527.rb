require "irs527/version"
require "irs527/form"
require "irs527/form/form_list"
require "irs527/form/form_8871"
require "irs527/form/form_8872"
require "irs527/query"
require "net/http"
require "csv"
require "zip"

module Irs527
  class Utility
    def self.retrieve_data(path)
      if !File.file?("#{path}/data.zip")
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
      end

      Zip::File.open("#{path}/data.zip") do |zip|
        zip.each do |entry|
          @file = File.basename(entry.name)
          entry.extract("#{path}/#{File.basename(entry.name)}")
          puts "File extracted to #{path} as #{@file}"
        end
      end

      File.delete("#{path}/data.zip")
      return @file
    end

    def self.generate_index(path, output)
      file = File.open(path)
      file_detail = file.readline
      offset = file_detail.bytesize

      records = {}
      loop do
        break if file.eof?
        offset = file.pos
        line = file.readline.encode('UTF-8', invalid: :replace, replace: ' ')

        if line[0..1] == "1|" || line[0..1] == "2|"
          form = Form.new(line.split("|"))
          @ein = form.type[:ein]
          name = form.type[:name]
          type = form.type[:form_type]
          if records[@ein]
            records[@ein][:forms] << { offset: offset, length: line.length, type: type }
          else
            records[@ein] = {forms: [{ offset: offset, length: line.length, type: type }], name: name }
          end
        else
          records[@ein][:forms][-1][:length] += line.length
        end
      end

      CSV.open("#{output}", "w") do |csv|
        records.each do |ein,entry|
          name = entry[:name]
          forms = entry[:forms]
          csv << [ein, name] + forms.map { |form| [ form[:type], form[:length], form[:offset] ] }.flatten
        end
      end
    end

    def self.parse_form(data_chunk)
      forms = data_chunk.split("\n").map { |form| form.split("|") }

      primary_form = Form.new(forms.shift)
      while primary_form.incomplete?
        primary_form << forms.shift
      end

      primary_form = primary_form.create!

      forms.each do |form|
        if Form.valid?(form)
          form = Form.new(form)
          form.update(primary_form)
        end
      end

      primary_form.line = ''
      return primary_form
    end
  end
end
