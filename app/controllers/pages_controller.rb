class PagesController < ApplicationController

  def show
    @page = ContentBlock.find_or_create_by( name: params[:id])
  end

  def policies
#    @page = ContentBlock.find_or_create_by( name: params[:id])
  end

  def technology
  end

  def deposit
  end

end
