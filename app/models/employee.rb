class Employee < ApplicationRecord
  STATUSES = %w[active inactive].freeze

  CURRENCIES = %w[
    INR SGD MYR THB IDR PHP KRW GBP USD
  ].freeze

  validates :employee_code, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :country, presence: true
  validates :department, presence: true
  validates :job_title, presence: true
  validates :employment_status, inclusion: { in: STATUSES }
  validates :joining_date, presence: true
  validates :annual_salary, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, inclusion: { in: CURRENCIES }
end