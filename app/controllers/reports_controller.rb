require "csv"

class ReportsController < ApplicationController
  def create
    sql = OllamaService.generate_sql_from_question(params[:query])
    Rails.logger.info "Generated SQL: #{sql}"
    csv_data = run_and_export(sql)
    report_title = report_name(params[:query])

    send_data csv_data,
      filename: "#{report_title}.csv",
      type: "text/csv"
  end

  private

  def report_name(query)
    OllamaService.ask("Generate a concise report name for the following query: #{query}, just return the text of the better one, no extension and no additional text.")
  rescue StandardError => e
    Rails.logger.error "Failed to generate report name: #{e.message}"
    "report-#{Time.now.to_i}"
  end

  def run_and_export(sql)
  results = ActiveRecord::Base.connection.exec_query(sql)
    CSV.generate(headers: true) do |csv|
      csv << results.columns
      results.rows.each { |row| csv << row }
    end
  end
end
