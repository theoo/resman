class OverviewController < ApplicationController

  auto_complete_for :room, :name

  def index
    tag_to_ignore = Option.value('tag_to_ignore')

    @in_reservations = Reservation.find_by_in
      .reject{ |obj| obj.resident.tag_list.include?(tag_to_ignore) }
    @out_reservations = Reservation.find_by_out
      .reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) }
    @unread_comments = Comment.where(read: false)
      .order('created_at DESC')
  end

  def summary
    @date = Date.today

    # Fix this by switching to searchlogic 2
    @open_invoices = Invoice.all(order_by: [{ reservation: { resident: [:last_name, :first_name] }}, :created_at]).select{ |i| i.open? && !i.is_a?(DepositInvoice) }.reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) } #.sort_by{ |i| i.can_be_paid_until?(@date) ? 1 : 0 }
    @reservations_without_confirmation_invoice = Reservation.all(conditions: { status_ne: %w{cancelled confirmed} }, order_by: { resident: [:last_name, :first_name] }).reject{ |r| r.confirmation_invoice_generated? }.reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) }
    @unbilled_reservations = Reservation.unbilled_reservations(@date)
    @overpaid_invoices = Invoice.all(order_by: [{ reservation: { resident: [:last_name, :first_name] }}, :created_at]).select{ |i| i.overpaid? && !i.is_a?(DepositInvoice) }.reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) }
    @reservations_without_deposit_invoice = Reservation.all(conditions: { status_ne: 'cancelled' }, order_by: { resident: [:last_name, :first_name] }).select{ |r| r.need_deposit_invoice? }.reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) }
  end

  def statistics
    # FIXME what if there's no reservations?
    @from = Reservation.order(:arrival).first.arrival
    @to   = Reservation.order(:departure).last.departure

    if params[:date]
      @from = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1)
      @to   = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).end_of_month
    end

    %w(country continent religion school institute).each do |k|
      arel = k.capitalize.constantize
        .joins(:reservations, :tags)
        .where(" ? <= arrival AND departure < ?", @from, @to)
        .where.not("tags.name" => Option.value('tag_to_ignore'))
        .uniq
      instance_variable_set "@" + k.pluralize, arel
    end

    @ages = {}
    [0..20, 20..25, 25..30, 30..180, nil].each do |i|
      if i.is_a? Range
        @ages["#{i.first}-#{i.last}"] = Age.find_by_age(i, @from, @to)
      else
        @ages[i] = Age.find_by_age(i, @from, @to)
      end
    end

  end

  def residents

    @from = params[:from] ? params[:from].to_default_date : Reservation.first(order_by: :arrival).arrival
    @to = params[:to] ? params[:to].to_default_date : Reservation.last(order_by: :departure).departure
    if %w(Resident Age).include? params[:class]
      @object = params[:class].constantize
        .where(id: params[:id])
    else
      @object = Resident.joins(params[:class].downcase.to_sym)
        .where("#{params[:class].downcase.pluralize}.id" => params[:id])
        .uniq
    end

  end

  def inout
    @from = Reservation.order(:arrival).first.arrival
    @to   = Reservation.order(:departure).last.departure

    if params[:date]
      @from = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1)
      @to   = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).end_of_month
    end

    @arrivals   = Reservation.joins(:tags)
      .where(" ? <= arrival AND arrival <= ?", @from, @to)
      .where.not("tags.name" => Option.value('tag_to_ignore'))
      .count
    @departures = Reservation.joins(:tags)
      .where(" ? <= departure AND departure <= ?", @from, @to)
      .where.not("tags.name" => Option.value('tag_to_ignore'))
      .count
  end

  def preferences
  end

end
