namespace :app do
  desc 'Automatically drops unconfirmed reservations'
  task(delete_unconfirmed_reservations: :environment) do
    User.current_user = User.find(:first, conditions: { login: 'admin' })
    
    conditions = {}
    conditions[:status] = 'pending'
    conditions[:invoices] = {}
    conditions[:invoices][:type] = 'ConfirmationInvoice'
    conditions[:invoices][:created_at_lt] = Time.now - Option.value('delay_before_cancellation').to_i.day
    Reservation.find(:all, conditions: conditions).each do |reservation|
      if reservation.deletable?
        reservation.destroy
      else
        reservation.status = 'cancelled'
        reservation.save!
      end
    end
  end
end
