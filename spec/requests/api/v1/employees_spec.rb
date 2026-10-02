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

  describe "GET /api/v1/employees/:id" do
    let!(:employee) { create(:employee) }

    it "returns the requested employee" do
      get "/api/v1/employees/#{employee.id}"

      expect(response).to have_http_status(:ok)

      body = JSON.parse(response.body)

      expect(body["data"]["id"]).to eq(employee.id)
      expect(body["data"]["employee_code"]).to eq(employee.employee_code)
      expect(body["data"]["email"]).to eq(employee.email)
    end
  end

  describe "PATCH /api/v1/employees/:id" do
    let!(:employee) { create(:employee, annual_salary: 50_000) }

    it "updates the employee salary" do
      patch "/api/v1/employees/#{employee.id}",
        params: {
          employee: {
            annual_salary: 75_000
          }
        }

      expect(response).to have_http_status(:ok)

      employee.reload

      expect(employee.annual_salary.to_f).to eq(75_000)
    end

    it "rejects a negative salary" do
      patch "/api/v1/employees/#{employee.id}",
        params: {
          employee: {
            annual_salary: -100
          }
        }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "returns 404 for a missing employee" do
      patch "/api/v1/employees/999999",
        params: {
          employee: {
          annual_salary: 75_000
        }
      }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/employees" do
    let(:valid_attributes) do
      {
        employee_code: "EMP99999",
        first_name: "John",
        last_name: "Smith",
        email: "john.smith@acme.example.com",
        country: "India",
        department: "Engineering",
        job_title: "Software Engineer",
        employment_status: "active",
        joining_date: "2026-09-01",
        annual_salary: 1_500_000,
        currency: "INR"
      }
    end

    it "creates an employee" do
      expect {
        post "/api/v1/employees",
             params: { employee: valid_attributes },
             as: :json
      }.to change(Employee, :count).by(1)

      expect(response).to have_http_status(:created)

      body = JSON.parse(response.body)

      expect(body["data"]["employee_code"]).to eq("EMP99999")
      expect(body["data"]["email"]).to eq("john.smith@acme.example.com")
    end

    it "returns validation errors for invalid data" do
      post "/api/v1/employees",
           params: {
             employee: valid_attributes.merge(
               annual_salary: -100
             )
           },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["errors"]).to include(
        "Annual salary must be greater than or equal to 0"
      )
    end

    it "does not create an employee with a duplicate email" do
      create(
        :employee,
        employee_code: "EMP88888",
        email: "john.smith@acme.example.com"
      )

      post "/api/v1/employees",
           params: { employee: valid_attributes },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["errors"]).to include("Email has already been taken")
    end

    it "does not create an employee with a duplicate employee code" do
      create(
        :employee,
        employee_code: "EMP99999",
        email: "another.employee@acme.example.com"
      )

      post "/api/v1/employees",
           params: { employee: valid_attributes },
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)

      body = JSON.parse(response.body)

      expect(body["errors"]).to include("Employee code has already been taken")
    end
  end
end
