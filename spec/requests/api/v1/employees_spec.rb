require "rails_helper"

RSpec.describe "Employees API", type: :request do
  describe "GET /api/v1/employees" do
    before do
      create_list(:employee, 30)
    end

    it "returns paginated employees" do
      get "/api/v1/employees", params: {
        page: 2,
        per_page: 10
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"].size).to eq(10)

      expect(body["pagination"]).to include(
        "page" => 2,
        "per_page" => 10,
        "total_count" => 30,
        "total_pages" => 3
      )
    end

    it "searches employees by name" do
      employee = create(
        :employee,
        first_name: "Pooja",
        last_name: "Dudhatra"
      )

      get "/api/v1/employees", params: {
        search: "Pooja"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"].size).to eq(1)
      expect(body["data"].first["id"]).to eq(employee.id)
    end

    it "filters employees by country" do
      create(:employee, country: "India")
      create(:employee, country: "Singapore")

      get "/api/v1/employees", params: {
        country: "India"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"]).not_to be_empty
      expect(body["data"].all? { |employee| employee["country"] == "India" }).to be(true)
    end

    it "filters employees by department" do
      create(:employee, department: "Engineering")
      create(:employee, department: "Finance")

      get "/api/v1/employees", params: {
        department: "Finance"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"]).not_to be_empty
      expect(
        body["data"].all? { |employee| employee["department"] == "Finance" }
      ).to be(true)
    end

    it "filters employees by employment status" do
      create(:employee, employment_status: "active")
      create(:employee, employment_status: "inactive")

      get "/api/v1/employees", params: {
        status: "inactive"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"]).not_to be_empty
      expect(
        body["data"].all? { |employee| employee["employment_status"] == "inactive" }
      ).to be(true)
    end

    it "sorts employees by salary in descending order" do
      create(:employee, annual_salary: 50_000)
      create(:employee, annual_salary: 100_000)
      create(:employee, annual_salary: 75_000)

      get "/api/v1/employees", params: {
        sort: "annual_salary",
        direction: "desc"
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      salaries = body["data"].map { |employee| employee["annual_salary"].to_f }

      expect(salaries).to eq(salaries.sort.reverse)
    end

    it "limits per_page to 100" do
      get "/api/v1/employees", params: {
        per_page: 500
      }

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"].size).to be <= 100
      expect(body["pagination"]["per_page"]).to eq(100)
    end
  end
end
