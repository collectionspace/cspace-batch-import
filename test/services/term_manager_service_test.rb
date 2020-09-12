# frozen_string_literal: true

require 'test_helper'

class TermManagerServiceTest < ActiveSupport::TestCase
  setup do
    @tm = TermManagerService.new(name: 'batch1', save_to_file: false)
    @terms = []
    @concepts = [
      {
        category: :authority,
        type: 'conceptauthorities',
        subtype: 'archculture',
        value: 'concept1',
        found: true
      },
      {
        category: :authority,
        type: 'conceptauthorities',
        subtype: 'archculture',
        value: 'concept1',
        found: true
      },
      {
        category: :authority,
        type: 'conceptauthorities',
        subtype: 'archculture',
        value: 'concept2',
        found: true
      }
    ]
    @persons = [
      {
        category: :authority,
        type: 'personauthorities',
        subtype: 'person',
        value: 'person1',
        found: true
      },
      {
        category: :authority,
        type: 'personauthorities',
        subtype: 'person',
        value: 'person2',
        found: false
      },
      {
        category: :authority,
        type: 'personauthorities',
        subtype: 'person',
        value: 'person2',
        found: false
      }
    ]
    @places = [
      {
        category: :authority,
        type: 'placeauthorities',
        subtype: 'place1',
        value: 'place',
        found: true
      },
      {
        category: :authority,
        type: 'placeauthorities',
        subtype: 'place2',
        value: 'place',
        found: false
      }
    ]
    @terms.concat(@concepts, @persons, @places)
  end

  test 'can depdulicate terms' do
    @concepts.each { |term| @tm.add(term) }
    assert_equal 2, @tm.found['conceptauthorities'].size
    @persons.each { |term| @tm.add(term) }
    assert_equal 1, @tm.not_found['personauthorities'].size
  end

  test 'can return totals for terms' do
    @terms.each { |term| @tm.add(term) }
    assert_equal 2, @tm.found['conceptauthorities'].size
    assert_equal 0, @tm.not_found['conceptauthorities'].size
    assert_equal 1, @tm.found['personauthorities'].size
    assert_equal 1, @tm.not_found['personauthorities'].size
    assert_equal 1, @tm.found['placeauthorities'].size
    assert_equal 1, @tm.not_found['placeauthorities'].size
    assert_equal 4, @tm.total_found
    assert_equal 2, @tm.total_not_found
  end
end
