require "irs527/version"
require "pry"
require "irs527/form"
require "irs527/form_8871"
module Irs527
  class TextParser
    def self.parse(path)
      file = File.open(path)
      forms = []
      loop do
        begin
          line = file.readline.encode('UTF-8', invalid: :replace, replace: ' ')
        rescue EOFError
          break
        end
        if line[0] == "1"
          form = Form.new(line)
          form = form.parse_line

          forms << form
        end
      end
      binding.pry
    end
  end
end
