require 'test_helper'

class StepTest < ActiveSupport::TestCase
  setup do
    @identity = Step.find_by(name: 'Identity')
    @medical = Step.find_by(name: 'Medical')
  end

  test 'steps have correct fields' do
    assert @identity.fields.key? 'decedentName'
    assert @identity.fields.key? 'akas'
    assert @identity.fields.key? 'ssn'
    assert @identity.fields.key? 'decedentAddress'
    assert @medical.fields.key? 'placeOfDeath'
    assert @medical.fields.key? 'datePronouncedDead'
    assert @medical.fields.key? 'cod'
    assert @medical.fields.key? 'pronouncerLicenseNumber'
  end

  test 'steps have correct params whitelist' do
    assert @identity.whitelist.reduce({}, :merge).key? 'decedentName'
    assert @identity.whitelist.reduce({}, :merge).key? 'akas'
    assert @identity.whitelist.reduce({}, :merge).key? 'ssn'
    assert @identity.whitelist.reduce({}, :merge).key? 'decedentAddress'
    assert @medical.whitelist.reduce({}, :merge).key? 'placeOfDeath'
    assert @medical.whitelist.reduce({}, :merge).key? 'datePronouncedDead'
    assert @medical.whitelist.reduce({}, :merge).key? 'cod'
    assert @medical.whitelist.reduce({}, :merge).key? 'pronouncerLicenseNumber'
  end
end
