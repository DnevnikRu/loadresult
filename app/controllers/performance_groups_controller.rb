class PerformanceGroupsController < ApplicationController
  before_action :set_group, only: [:edit, :update, :destroy, :show]
  before_action :get_labels, only: [:show]

  def index
    @performance_groups = PerformanceGroup.all.order('id ASC')
  end

  def show
  end

  def destroy
    @group.destroy
    redirect_to(performance_groups_url, notice: 'Performance group was successfully destroyed.')
  end

  def edit
    flash.now[:name] = @group[:name]
    flash.now[:units] = @group[:units]
    flash.now[:trend_limit] = @group[:trend_limit]
  end

  def update
    group = PerformanceGroup.edit_group(@group, params)
    if group.errors.empty?
      redirect_to(performance_groups_url, notice: 'Performance group was successfully updated.')
    else
      flash.now[:name] = params[:name]
      flash.now[:units] = params[:units]
      flash.now[:trend_limit] = params[:trend_limit]
      flash.now[:alert] = group.errors.full_messages
      render action: :edit
    end
  end

  def create
    group = PerformanceGroup.create_new_group(params)
    if group.errors.empty?
      redirect_to(performance_groups_url, notice: 'Performance group was successfully created.')
    else
      flash.now[:name] = params[:name]
      flash.now[:units] = params[:units]
      flash.now[:trend_limit] = params[:trend_limit]
      flash[:alert] = group.errors.full_messages
      redirect_to :back
    end
  end

  private

  def set_group
    @group = PerformanceGroup.find_by(id: params[:id])
  end

end