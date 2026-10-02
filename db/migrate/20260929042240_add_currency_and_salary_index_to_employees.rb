class AddCurrencyAndSalaryIndexToEmployees < ActiveRecord::Migration[8.1]
  def change
    add_index :employees, [:currency, :annual_salary]
  end
end