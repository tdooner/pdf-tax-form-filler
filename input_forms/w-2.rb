require 'active_support/core_ext/module/attribute_accessors'

class InputForm
  def self.inherited(subclass)
    subclass.cattr_accessor :fields
    subclass.fields = {}
  end

  def self.field(line, description)
    self.fields[line] = { description: description }
  end

  def initialize(values = {})
    @values = values
  end

  def prompt
    self.class.fields.each do |line, field|
      puts '[Line %-2s]: %s: ' % [line, field[:description]]
      @values[line] = gets.chomp
    end
  end

  def values
    @values
  end

  def value(line)
    @values[line]
  end

  def self.load_or_prompt(filename)
    if !File.exist?(filename)
      new.tap(&:prompt).tap do |form|
        File.open(filename, 'w') do |f|
          f.puts form.values.map { |line| line.join(',') }.join("\n")
        end
      end
    end

    new(File.read(filename).split("\n").map { |line| line.split(',') })
  end
end

class Input1099 < InputForm
end

class W2 < InputForm
  field '1', 'Wages, Tips, Other Compensation'
  field '2', 'Federal income tax withheld'
  field '3', 'Social Security Wages'
  field '4', 'Social Security tax withheld'
  field '5', 'Medicare Wages and Tips'
  field '6', 'Medicare Tax Withheld'
  field '7', 'Social Security Tips'
  field '8', 'Allocated Tips'
  field '9', 'Advanced EIC Payment'
  field '10', 'Dependent Care Benefits'
  field '11', 'Nonqualified Plans'
  field '12a', '(See Instructions for Box 12)'
  field '12b', '(See Instructions for Box 12)'
  field '12c', '(See Instructions for Box 12)'
  field '12d', '(See Instructions for Box 12)'
  field '13', '(Checkbox Value)' # TODO: build checkboxes
  field '14', 'Other'
  field '15a', 'Employer State'
  field '15b', 'Employer State ID Number'
  field '16', 'State Wages, Tips'
  field '17', 'State Income Tax'
  field '18', 'Local Wages, Tips'
  field '19', 'Local Income Tax'
  field '20', 'Locality Name'
end

if __FILE__ == $0
  W2.load_or_prompt('tom_cache/2015-w2.csv')
end
