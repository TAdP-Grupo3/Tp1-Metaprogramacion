require_relative '../src/exceptions/origin_argument_exception'
require_relative '../src/filters/name_filter'
require_relative '../src/filters/visibility_filter'
require_relative '../src/filters/parameter_filter'

class Aspects

  def self.on(*origins, &aspects_block)

    #Ac� deber�a ir la llamada __on__ de la que estaban hablando,
    # pero tiene que tomar como par�metro flatten_origins(origins)

  end


  def self.where(*conditions)

  end

  ----------------------------------------
#-------------------------------------------------
#-------------------------------------------------
#Modificador de filtro de argumentos
#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------

  def self.optional
    Proc.new { |argument_description| argument_description.first.equal?(:opt) }
  end

  def self.mandatory
    Proc.new { |argument_description| argument_description.first.equal?(:req) }
  end

#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------
#Filtros del where
#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------


  def self.has_parameters(number_of_parameters, modifier = Proc.new { |argument_description| true })
    ParameterFilter.new(number_of_parameters, modifier)
  end

  def self.is_private
    VisibilityFilter.new(true)
  end

  def self.is_public
    VisibilityFilter.new(false)
  end

#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------
#M�todos privados
#-------------------------------------------------
#-------------------------------------------------
#-------------------------------------------------

  private
  def self.has_name(regex)
    NameFilter.new(regex)
  end

  def self.flatten_origins(origins)

    flattened_origins = []
    origins.each do |origin|
      origin.class.equal?(Regexp) ? flattened_origins << regex_search(origin) : flattened_origins << origin
    end
    flattened_origins.flatten!.uniq!
    if flattened_origins.empty?
      raise OriginArgumentException.new
    end
    flattened_origins
  end


  def self.regex_search(regex)
    context_classes.select { |class_symbol| regex =~ class_symbol }.map { |existent_class| Object.const_get(existent_class) }
  end


#Fernando ten�a razon y est�n en Object como symbols las clases
  def self.context_classes
    Object.constants
  end

end
