module ScopeExtention

  module ClassMethods
    def order_by_link_query(args)
      if args
        attributes = args[:attr]

        if attributes.is_a? Hash # relationship to build
          foreign_relationships, foreign_attributes = [], []
          attributes.each do |key,value|
            foreign_relationships << key.to_sym
            value.each do |v|
              foreign_attributes << key.to_s.pluralize + "." + v.to_s
            end
          end

          # add joins and attributes to query
          joins(foreign_relationships)
        else
          foreign_attributes = [attributes]
        end

        # ASC by default, setting args[:dir] to true inverse order
        dir = eval(args[:dir]) ? 'DESC' : 'ASC'
        if foreign_attributes.size > 1
          foreign_attributes = foreign_attributes.join(" #{dir}, ")
        else
          foreign_attributes = foreign_attributes.to_s + " " + dir
        end

        if attributes.is_a? Hash # there is joins
          joins(foreign_relationships).order(foreign_attributes)
        else
          order(foreign_attributes)
        end
      else
        raise ArgumentError, "The key :attr is required. You can use values like :attribute, :relation => :attribute or :relation => [:attribute1, :attribute2]"
      end
    end
  end

end
