require 'test_helper'

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get certificates_index_url
    assert_response :success
  end

end
