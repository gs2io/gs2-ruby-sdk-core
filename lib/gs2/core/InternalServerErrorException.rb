module Gs2 module Core
  class InternalServerErrorException < Exception
    
    def initialize(errors)
      super(errors)
      @errors = errors
    end
    
    def errors()
      return @errors
    end
    
  end
end end
