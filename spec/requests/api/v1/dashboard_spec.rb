require "rails_helper"

RSpec.describe "Dashboard API", type: :request do
  describe "GET /api/v1/dashboard" do
    before do
      create(
        :employee,
        currency: "USD",
        annual_salary: 100_000
      )

      create(
        :employee,
        currency: "USD",
        annual_salary: 200_000
      )

      create(
        :employee,
        currency: "INR",
        annual_salary: 1_000_000
      )
    end

    it "returns dashboard metrics" do
      get "/api/v1/dashboard"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"]["total_employees"]).to eq(3)
      expect(body["data"]["payroll_by_currency"]["USD"]).to eq(300_000)
      expect(body["data"]["payroll_by_currency"]["INR"]).to eq(1_000_000)
    end
  end
end