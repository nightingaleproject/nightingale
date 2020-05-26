require 'test_helper'

class StepContentTest < ActiveSupport::TestCase
  setup do
    @sc1 = step_contents(:step_content_3)
    @sc2 = step_contents(:step_content_4)
  end

  test 'step contents render results and human readable properly' do
    assert @sc1.build_results[1][:humanReadable] == 'Example, Father'
    assert @sc1.build_results[2][:humanReadable] == 'Maiden, Mother'
    assert @sc2.build_results[0][:humanReadable] == 'Burial'
    assert @sc2.build_results[2][:humanReadable] == 'Example Funeral Home\\n2 Example St. \\nLowell, MIDDLESEX, Massachusetts\\n01852'
  end

  test 'step requirements were met by step contents' do
    assert @sc1.required_satisfied(@sc1.build_results)
    assert @sc2.required_satisfied(@sc2.build_results)
  end
end
