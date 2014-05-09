module GladiatorMatch
  class Entity
    # include ActiveModel::Validations

    def initialize(attrs={})
      attrs.each do |attr, value|
        setter = "#{attr}="
        self.send(setter, value) if self.class.method_defined?(setter)
      end
    end

    # TO DO
    # currently will create an infinite loop if there's a many-to-many relationship
    def to_hash
      updated_attrs = Hash[self.instance_values.map do |k,v|
        if v.is_a?(Entity)
          v = v.to_hash
        elsif v.is_a?(Array)
          v.map! do |inner_v|
            inner_v.is_a?(Entity) ? inner_v.to_hash : inner_v
          end
        end
        [k.to_sym, v]
      end]
    end
  end
end
