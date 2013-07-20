class Tasks::DownloadTask
  def self.execute
    DownloadStocks.new.download
  end
end
