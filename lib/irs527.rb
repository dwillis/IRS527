require "irs527/version"

module Irs527

  class TextParser

    def self.parse(path)
      file_8871 = File.open('8871.txt', 'w')
      file_8872 = File.open('8872.txt', 'w')
      file_skeda = File.open('skeda.txt', 'w')
      file_skedb = File.open('skedb.txt', 'w')
      f = File.open(path).readlines
      f.each do |line|
        if line[0..1] == "1|"
          file_8871.write(line)
        elsif line[0..1] == "2|"
          file_8872.write(line)
        elsif line[0..1] == "A|"
          file_skeda.write(line)
        elsif line[0..1] == "B|"
          file_skedb.write(line)
        end
      end
      file_8871.close
      file_8872.close
      file_skeda.close
      file_skedb.close
    end
  end

end
