require 'test_helper'

class CertificatesControllerTest < ActionDispatch::IntegrationTest
  test 'should redirect if not signed in' do
    get certificates_index_url
    assert_response :redirect
  end
end
