# db/seeds.rb

Employee.delete_all

srand(42)

countries = {
  "India" => "INR",
  "Singapore" => "SGD",
  "Malaysia" => "MYR",
  "Thailand" => "THB",
  "Indonesia" => "IDR",
  "Philippines" => "PHP",
  "South Korea" => "KRW",
  "United Kingdom" => "GBP",
  "United States" => "USD"
}

salary_ranges = {
  "INR" => [500_000, 5_000_000],
  "SGD" => [40_000, 180_000],
  "MYR" => [40_000, 250_000],
  "THB" => [400_000, 3_000_000],
  "IDR" => [60_000_000, 1_500_000_000],
  "PHP" => [300_000, 3_000_000],
  "KRW" => [35_000_000, 200_000_000],
  "GBP" => [30_000, 150_000],
  "USD" => [40_000, 200_000]
}

departments = [
  "Engineering",
  "Product",
  "Sales",
  "Marketing",
  "Finance",
  "Human Resources",
  "Operations",
  "Customer Support"
]

job_titles = [
  "Software Engineer",
  "Senior Software Engineer",
  "Staff Software Engineer",
  "Product Manager",
  "Product Designer",
  "Sales Manager",
  "Marketing Specialist",
  "Financial Analyst",
  "HR Manager",
  "Operations Manager",
  "Customer Support Specialist"
]

statuses = %w[active active active active active inactive]

employees = Array.new(10_000) do |index|
  country, currency = countries.to_a.sample

  min_salary, max_salary = salary_ranges.fetch(currency)

  {
    employee_code: "EMP#{(index + 1).to_s.rjust(5, "0")}",
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    email: "employee#{index + 1}@acme.example.com",
    country: country,
    department: departments.sample,
    job_title: job_titles.sample,
    employment_status: statuses.sample,
    joining_date: Faker::Date.between(
      from: 10.years.ago,
      to: Date.current
    ),
    annual_salary: Faker::Number.between(
      from: min_salary,
      to: max_salary
    ),
    currency: currency,
    created_at: Time.current,
    updated_at: Time.current
  }
end

Employee.insert_all!(employees)

puts "Created #{Employee.count} employees."