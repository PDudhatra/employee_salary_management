module Api
  module V1
    class SalaryInsightsController < ApplicationController
      def show
        render json: {
          data: SalaryInsightsService.new(params).call
        }
      end
    end
  end
end