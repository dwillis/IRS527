module Irs527
  class FormList
    attr_reader :forms

    def self.load(csv_file, file, type=nil)
      form_paths = {}

      records = CSV.readlines(csv_file)
      records = type.nil? ? records : records.select { |r| r.include?(type) }

      records.each do |row|
        ein = row.shift
        name = row.shift

        form_paths[ein] = {
          name: name,
          forms: {
            form_8871: [],
            form_8872: []
          }
        }

        row.each_slice(3) do |chunk|
          form_paths[ein][:forms][chunk[0].to_sym] << ->() {
            Utility.parse_form(IO.read(file, chunk[1].to_i, chunk[2].to_i))
          }
        end
      end
      new(form_paths, file)
    end

    def initialize(forms, file)
      @forms = forms
      @file  = file
    end

    def query(ein)
      Query.new(@forms[ein], ein) if !@forms[ein].nil?
    end

    def names
      @names ||= @forms.map { |ein, org| {name: org[:name], ein: ein} }
    end

    def find_by_name(name)
      names.select { |org| org[:name] =~ Regexp.new(name) }
    end

    def [](ein)
      @forms[ein]
    end
  end
end