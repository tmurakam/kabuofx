job_type :rails4_runner, "cd :path && bin/rails runner -e :environment :task.execute :output"

every 1.days, :at => '18:00' do
  rails4_runner " DownloadStocks.new.download"
end
