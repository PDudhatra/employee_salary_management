class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :employee_code
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :country
      t.string :department
      t.string :job_title
      t.string :employment_status
      t.date :joining_date
      t.decimal :annual_salary
      t.string :currency

      t.timestamps
    end
  end
end
