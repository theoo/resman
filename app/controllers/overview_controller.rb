class OverviewController < ApplicationController

  def index
    tag_to_ignore = Option.value('tag_to_ignore')

    @in_reservations = Reservation.upcoming_checkin
      .reject{ |obj| obj.resident.tag_list.include?(tag_to_ignore) }
    @out_reservations = Reservation.upcoming_checkout
      .reject{ |obj| obj.resident.tag_list.include?(Option.value('tag_to_ignore')) }
    @unread_comments = Comment.where(read: false)
      .order('created_at DESC')
  end

  def summary
    @date = Date.today

    tag_to_ignore = Option.value('tag_to_ignore')

    common_invoices_arel = Invoice
      .joins(:reservation, :resident, :tags)
      .order("residents.last_name", "residents.first_name", :created_at)
      .where.not("tags.name" => tag_to_ignore)
      .uniq

    @open_invoices = common_invoices_arel.to_a
      .select{ |i| i.open? && !i.is_a?(DepositInvoice) }

    @reservations_without_confirmation_invoice = Reservation.joins(:resident, :tags)
      .where.not(status: %w{cancelled confirmed})
      .where.not("tags.name" => tag_to_ignore)
      .order("residents.last_name", "residents.first_name")
      .to_a
      .reject{ |r| r.confirmation_invoice_generated? }

    @unbilled_reservations = Reservation.unbilled_reservations(@date)

    @overpaid_invoices = common_invoices_arel.to_a
      .select{ |i| i.overpaid? && !i.is_a?(DepositInvoice) }

    @reservations_without_deposit_invoice = Reservation.joins(:resident, :tags)
      .where.not("tags.name" => tag_to_ignore)
      .where.not(status: 'cancelled')
      .order("residents.last_name", "residents.first_name")
      .uniq
      .to_a
      .select{ |r| r.need_deposit_invoice? }

  end

  def statistics
    # FIXME what if there's no reservations?
    @from = Time.now.beginning_of_year # Reservation.order(:arrival).first.arrival
    @to   = Time.now.end_of_year # Reservation.order(:departure).last.departure

    if params[:date]
      @from = Date.new(params[:date][:from][:year].to_i, params[:date][:from][:month].to_i, 1)
      @to   = Date.new(params[:date][:to][:year].to_i, params[:date][:to][:month].to_i, 1).end_of_month
    end

    %w(country continent religion school institute).each do |k|
      arel = k.capitalize.constantize
        .joins(:reservations, :tags)
        .where("(arrival BETWEEN ? AND ?) OR (departure BETWEEN ? AND ?)", @from, @to, @from, @to)
        .where.not("tags.name" => Option.value('tag_to_ignore'))
        .order(:name)
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
