module Sluggable
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.extend ClassMethods
    base.class_eval do
      my_class_method
    end
  end

  module InstanceMethods
    def to_param
      self.slug
    end

    def generate_slug!
      the_slug = to_slug(self.send(self.class.slug_col))
      obj = self.class.find_by slug: the_slug
      count = 2
      while obj && obj != self
        the_slug = append_suffix(the_slug, count)
        obj = self.class.find_by slug: the_slug
        count += 1
      end
      self.slug = the_slug
    end

    def append_suffix(str, count)
      if str.split('-').last.to_i != 0
        return str.split('-').slice(0...-1).join('-') + '-' + count.to_s
      else
        return str + '-' + count.to_s
      end
    end

    def to_slug(name)
      str = name.strip
      str.gsub! /\s*[^A-Za-z0-9]\s*/, '-'
      str.gsub! /-+/, '-'
      str.downcase
    end
  end

  module ClassMethods
    def my_class_method
      before_save :generate_slug!
      class_attribute :slug_col
    end

    def sluggable_column(col)
      self.slug_col = col
    end
  end
end
