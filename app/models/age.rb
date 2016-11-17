class Age

  def initialize(*args)
    @residents = Age.find_by_age(args)
  end

  class << self
    def find_by_age( age = nil, from = (Time.now - 1.year), to = Time.now )

      if age
        birthdate_interval = (Time.now - age.last.years)..(Time.now - age.first.years)
      else
        birthdate_interval = nil
      end

      Resident.joins(:reservations, :tags)
        .where("(arrival BETWEEN ? AND ?) OR (departure BETWEEN ? AND ?)", from, to, from, to)
        .where.not("tags.name" => Option.value('tag_to_ignore'))
        .where(birthdate: birthdate_interval)
        .uniq
    end

    def find(*args)
      Resident.find(args)
    end

    def where(*args)
      Resident.where(*args)
    end
  end

end