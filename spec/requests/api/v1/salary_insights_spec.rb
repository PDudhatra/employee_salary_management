require "rails_helper"


  RSpec.describe "Salary Insights API", type: :request do
    describe "GET /api/v1/salary_insights" do
      before do
        create(
          :employee,
          employee_code: "EMP00001",
          email: "one@acme.example.com",
          country: "India",
          department: "Engineering",
          currency: "INR",
          annual_salary: 1_000_000
        )

        create(
          :employee,
          employee_code: "EMP00002",
          email: "two@acme.example.com",
          country: "India",
          department: "Engineering",
          currency: "INR",
          annual_salary: 2_000_000
        )

        create(
          :employee,
          employee_code: "EMP00003",
          email: "three@acme.example.com",
          country: "India",
          department: "Sales",
          currency: "INR",
          annual_salary: 3_000_000
        )

        create(
          :employee,
          employee_code: "EMP00004",
          email: "four@acme.example.com",
          country: "United States",
          department: "Engineering",
          currency: "USD",
          annual_salary: 100_000
        )
      end

      it "returns salary statistics" do
        get "/api/v1/salary_insights",
            params: { currency: "INR" }

        expect(response).to have_http_status(:ok)

        body = JSON.parse(response.body)
        data = body["data"]

        expect(data["employee_count"]).to eq(3)
        expect(data["average_salary"]).to eq(2_000_000.0)
        expect(data["minimum_salary"]).to eq(1_000_000.0)
        expect(data["maximum_salary"]).to eq(3_000_000.0)
        expect(data["median_salary"]).to eq(2_000_000.0)
      end

      it "filters by country" do
        get "/api/v1/salary_insights",
            params: {
              country: "India",
              currency: "INR"
            }

        data = JSON.parse(response.body)["data"]

        expect(data["employee_count"]).to eq(3)
      end

      it "filters by department" do
        get "/api/v1/salary_insights",
            params: {
              department: "Engineering",
              currency: "INR"
            }

        data = JSON.parse(response.body)["data"]

        expect(data["employee_count"]).to eq(2)
        expect(data["average_salary"]).to eq(1_500_000.0)
      end

      it "filters by salary range" do
        get "/api/v1/salary_insights",
            params: {
              currency: "INR",
              min_salary: 1_500_000,
              max_salary: 2_500_000
            }

        data = JSON.parse(response.body)["data"]

        expect(data["employee_count"]).to eq(1)
        expect(data["average_salary"]).to eq(2_000_000.0)
      end

      it "returns null metrics when there are no matching employees" do
        get "/api/v1/salary_insights",
            params: {
              currency: "GBP"
            }

        data = JSON.parse(response.body)["data"]

        expect(data["employee_count"]).to eq(0)
        expect(data["average_salary"]).to be_nil
        expect(data["minimum_salary"]).to be_nil
        expect(data["maximum_salary"]).to be_nil
        expect(data["median_salary"]).to be_nil
      end
    end
  end