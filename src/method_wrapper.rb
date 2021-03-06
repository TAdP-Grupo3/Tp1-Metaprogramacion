require_relative 'transform'

class MethodWrapper
  include Transformations
  attr_accessor :method,:owner,:receiver


  def initialize(method,owner,receiver)
    @method = method
    @owner = owner
    @receiver = receiver
  end

  def method_missing(symbol,*args)
    @method.send(symbol,*args)
  end

  def redefine_method(behaviour)
    @owner.send(:define_method,@method.name,behaviour)
  end

  def respond_to_missing?(symbol,include_all)
    @method.respond_to?(symbol,include_all)
  end

  def hash
    method.hash
  end

  def eql?(another)
    method.eql? another.method
  end

end