class Age

  def initialize(*args)
    @residents = Age.find_by_age(args)
  end

  def self.find_by_age( age = nil, reservation_from = (Time.now - 1.year), reservation_to = Time.now )

    if age
      birthdate_interval = (Time.now - age.last.years)..(Time.now - age.first.years)
    else
      birthdate_interval = nil
    end

    Resident.all( conditions: { reservations: { arrival_gt: reservation_from, departure_lte: reservation_to },
                                   group: { tags: { name_is_blank: true, or_name_ne: Option.value('tag_to_ignore') } },
                                   birthdate: birthdate_interval
                                 } )
  end

  def self.find(*args)
    Resident.find(args)
  end

end