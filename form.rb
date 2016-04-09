require 'ostruct'
require 'prawn'
require 'tempfile'

class Form
  def self.load_definition(definition)
    new(definition)
  end

  # TODO: validate that definition.file exists
  def initialize(definition)
    @definition = definition
  end

  # TODO: validate that only valid fields are given
  def fill(fields)
    @fields = fields
  end

  def render_to_file(file)
    Tempfile.open do |f|
      d = Prawn::Document.new(margin: 0)

      @definition.fields.each do |field_name, field|
        value = @fields.fetch(field_name)
        coords = field.fetch(:coordinates)

        d.text_box String(value), at: coords
      end

      d.render_file f.path

      # TODO: Check exit code
      # TODO: Handle nonexistence of pdftk.
      `pdftk #{f.path} background #{@definition.file} output #{file}`
    end
  end
end

# TODO: This should be in a JSON file along with the form itself.
definition = OpenStruct.new(
  file: 'forms/2015/usa-1040.pdf',
  fields: {
    first_name: {
      # TODO: Does anything else need to be in this hash? If not, maybe promote
      # the coordinates array to top-level.
      # Ideas:
      #   description - The text of the line, or label text
      #   field_group - For checkboxes, only allow one to be checked (or maybe
      #                 this is better validated at a higher level of
      #                 abstraction?)
      #                 For split text inputs (like SSN) it could provide a good
      #                 abstraction that allows calling programs to not have to
      #                 be concerned about splitting the values manually.
      #   align - Text alignment of the field (left, right)
      #   type - text or checkbox
      #   font_size - Size of font
      #               (or maybe this should be autodetermined by the height of
      #               the input)
      #   size - width and height of this field
      coordinates: [45, 709],
    },
    last_name: {
      coordinates: [221, 709],
    },
    line_7: {
      coordinates: [485, 444],
    }
  },
)

f = Form.load_definition(definition)
f.fill(
  first_name: 'Thomas',
  last_name: 'Dooner',
  line_7: 1234,
)
f.render_to_file('combined.pdf')

puts "Rendered into #{File.expand_path('../combined.pdf', __FILE__)}"
