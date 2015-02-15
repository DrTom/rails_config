#  Copyright (C)  2014, 2015 Dr. Thomas Schank  (DrTom@schank.ch, Thomas.Schank@algocon.ch)
#
require 'set'
module DeepMerge
  class << self 
    def deep_merge(obj1, obj2)
      if obj1.is_a?(Hash) && obj2.is_a?(Hash)
        deep_merge_hashes obj1, obj2
      else
        obj2
      end
    end

    private 

    def keys(h1, h2)
      Set.new(h1.keys) + Set.new(h2.keys)
    end

    def deep_merge_hashes(h1, h2)
      Hash[(keys(h1, h2)).map do |k|
        [k, if h1.key?(k) && h2.key?(k) 
         deep_merge(h1[k], h2[k])
        elsif h2.key?(k)
          h2[k]
        else
          h1[k]
        end]
      end]
    end
  end
end
