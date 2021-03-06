module Transformations
  #Legacy en el sentido de que no hace falta que se un module ahora comparado con lo que teniamos
  #Bien podria ser una clase Transformer y instanciarse en el wrapper.

  def inject(injected_parameters)
    transformation_context = self
    redefine_method (proc do |*arguments|
                      transformation_context.inject_parameters_into(transformation_context.get_injected_parameter_with_order(injected_parameters),arguments)
                      transformation_context.bind(self).call(*arguments)
                      end)
  end

  def redirect_to(substitute)
    transformation_context = self
    redefine_method (proc {|*arguments| substitute.send(transformation_context.name,*arguments)})
  end

  def before(&behaviour)
    transformation_context = self
    instead_of &(proc do |*args|
                 instance_exec *args,&behaviour
                 transformation_context.bind(self).call(*args)
               end)
  end

  def after(&behaviour)
    transformation_context = self
    instead_of &(proc do |*args|
                 transformation_context.bind(self).call *args
                 instance_exec *args,&behaviour
               end)
  end

  def instead_of(&behaviour)
    redefine_method(behaviour)
  end

  #Me di cuenta tarde que existia el with_index. Too late para un refactor.
  def get_injected_parameter_with_order(injected_parameters)
    parameter_names = parameters.map { | parameter | parameter[1] }
    injected_parameters.map {|name,value| [parameter_names.find_index(name),value]}.to_h
  end

  def inject_parameters_into(hashed_order_value,arguments)
    hashed_order_value.each {|order,value| arguments[order] = evaluate_if_proc(value,arguments[order])}
  end

  def evaluate_if_proc(value,argument)
    return value unless value.is_a? Proc
    value.call(receiver,name,argument)
  end

end

