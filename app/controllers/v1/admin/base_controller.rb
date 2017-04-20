class V1::Admin::BaseController < ApplicationController
  before_action :authenticate_chief!
end
