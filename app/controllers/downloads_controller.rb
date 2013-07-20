class DownloadsController < ApplicationController
  def index
  end

  def ofx
    send_file "public/ofx/kabuofx.ofx", :type => "application/x-ofx"
  end
end
