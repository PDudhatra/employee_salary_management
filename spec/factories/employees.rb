FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| "EMP#{n.to_s.rjust(5, "0")}" }
    sequence(:email) { |n| "employee#{n}@acme.example.com" }

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    country { "India" }
    department { "Engineering" }
    job_title { "Software Engineer" }
    employment_status { "active" }
    joining_date { Faker::Date.between(from: 10.years.ago, to: Date.current) }

    annual_salary { Faker::Number.between(from: 30_000, to: 150_000) }
    currency { "USD" }
  end
end
