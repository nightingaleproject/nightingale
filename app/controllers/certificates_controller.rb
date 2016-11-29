# Certificates Controller
class CertificatesController < ApplicationController
  before_action :authenticate_user!

  def index
  end
end
