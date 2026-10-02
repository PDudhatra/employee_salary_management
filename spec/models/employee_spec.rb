require "rails_helper"

RSpec.describe Employee, type: :model do
  subject(:employee) { build(:employee) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(employee).to be_valid
    end

    it "requires an employee code" do
      employee.employee_code = nil

      expect(employee).not_to be_valid
      expect(employee.errors[:employee_code]).to include("can't be blank")
    end

    it "requires a unique employee code" do
      employee.save!

      duplicate = build(:employee, employee_code: employee.employee_code)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:employee_code]).to include("has already been taken")
    end

    it "requires a unique email" do
      employee.save!

      duplicate = build(:employee, email: employee.email)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "does not allow a negative salary" do
      employee.annual_salary = -1

      expect(employee).not_to be_valid
      expect(employee.errors[:annual_salary]).to include(
        "must be greater than or equal to 0"
      )
    end

    it "only allows active or inactive status" do
      employee.employment_status = "terminated"

      expect(employee).not_to be_valid
      expect(employee.errors[:employment_status]).to include(
        "is not included in the list"
      )
    end

    it "requires a supported currency" do
      employee = build(:employee, currency: "XX")

      expect(employee).not_to be_valid
      expect(employee.errors[:currency]).to include(
        "is not included in the list"
      )
    end

    it "requires a supported currency" do
      employee = build(:employee, currency: "XYZ")

      expect(employee).not_to be_valid
      expect(employee.errors[:currency]).to include("is not included in the list")
    end
  end
end