# WIP WIP WIP
# I'm just trying to write this API down at the moment/pseudocode it,
# implementation will maybe follow. If it's not too hard.

require_relative 'input_forms/w-2.rb'
require 'json'

def load_definition(sha)
  JSON.parse(File.read('web-form-generator/state.json'))[sha]
end

form_1099s = [
  Input1099.new(
    'name' => 'Etrade',
    '1a' => '378.12',
    '1b' => '275.54',
    '2a' => '253.90',
  ),
  Input1099.new(
    'name' => 'Wealthfront',
    '1a' => '315.29',
    '1b' => '225.33',
    '6' => '15.11',
    '10' => '16.55',
  ),
]

class Form1040ScheduleB
  dollar_cents_field :dividend_1_amount, ['dividend_amount_1', 'dividend_amount_1_cents'],
    from: '1099', line: '1a', index: 0
  multi_field :dividend_1, ['dividend_payer_1', :dividend_1_amount]
  # TODO: just copy-paste that a ton of times

  # TODO: can this syntax be better
  calculate '6', [:+, { from: '1099', line: '1a' }]
end

class Form1040
  calculate '7', ['w2', '1']
  calculate '9a', ['1040-b', '6']
end

w2 = W2.load_or_prompt('tom_cache/2015-w2.csv')

form_1040 = load_definition('65450ef23695e831f540a492f15560f0')
form_1040.add_input_form('w2', w2)
form_1099s.each { |form| form_1040.add_input_form('1099', form) }
