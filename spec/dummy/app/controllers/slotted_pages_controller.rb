class SlottedPagesController < ApplicationController

  def show
    @page = SlottedPage.find params[:id]
  end

end
