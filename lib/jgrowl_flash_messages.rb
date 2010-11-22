module JGrowlFlashMessages
  
  FLASH_MESSAGE_TYPES = [ :error, :warning, :success, :notice ]
  
  # Devuelve en string en base a las opciones:
  #  * :scope => donde se busca el mensaje
  #  * :action => clave del mensaje dentro del scope (por defecto es default)
  #  * :key => clave del mensaje completa (se forma automáticamente como scope.action)
  #  * El resto de opciones se usan para interpolación en el método I18n.translate
  # ===== Ejemplos:
  # MSG_FROM_OPTIONS[{}, :error] #=> I18n.translate 'common.flash_messages.error.default'
  # MSG_FROM_OPTIONS[:count => 3, :key => 'mytrans.lation'] #=> I18n.translate('mytrans.lation', :count => 3)
  MSG_FROM_OPTIONS = lambda do |*args|
    options = args.first
    msg_type = args.second || :notice 
    scope = options.delete(:scope) || "common.flash_messages.#{msg_type}"
    action = options.delete(:action) || "default"
    key = options.delete(:key) || "#{scope}.#{action}"
    I18n.translate key, options
  end
  
  
  # Operaciones disponibles en los controladores.
  # El parámetro msg puede ser un String o un Hash de opciones.
  # Si es un String, se pone ese texto directamente,
  # si es un Hash, se traduce usando I18n, según el método default_msg_from_options
  module ControllerHelpers
    def flash_error(msg={})
      msg = MSG_FROM_OPTIONS[msg, :error] if msg.is_a? Hash
      flash[:error] = msg
    end

    def flash_warning(msg={})
      msg = MSG_FROM_OPTIONS[msg, :warning] if msg.is_a? Hash
      flash[:warning] = msg
    end

    def flash_success(msg={})
      msg = MSG_FROM_OPTIONS[msg, :success] if msg.is_a? Hash
      flash[:success] = msg
    end

    def flash_notice(msg={})
      msg = MSG_FROM_OPTIONS[msg, :notice] if msg.is_a? Hash
      flash[:notice] = msg
    end
  
    def flash_message(msg={}) flash_notice(msg); end # alias of flash_notice
    
  end

  # Helpers para la vista
  module ViewHelpers
    
    # Poner en el layout en cualquier lugar (mejor abajo, justo antes de la etiqueta </body>).
    # Las opciones son las mismas que las que se pueden aplicar al plugin de jquery,
    # solo que se cambian ligeramente los valores por defecto (ver implementación debajo)
    # Simplemente especificarlas como un hash de ruby y se convierten automáticamente al
    # hash de opciones javaScript.
    # Las claves deben tener el mismo nombre que en javascript, pero deben ser symbols.
    def render_flash_messages(options={})
      # default options
      options[:closerTemplate] ||= "<div>[#{I18n.t 'common.links.close_all'}]</div>"
      options[:life] ||= 5000
      
      # javascript
      jgrowl_configuration = javascript_tag "jQuery.extend(jQuery.jGrowl.defaults, #{options.to_json});"
      messages = show_flash_messages
      
      fm = jgrowl_configuration
      fm << javascript_tag("jQuery(function() { #{messages} });") unless messages.empty?
      fm
    end
    
    # Genera el javascript necesario para mostrar todos los mensajes flash que haya acumulados.
    # Se puede usar en las acciones ajax (dentro del render(:update) { |page| page << show_flash_messages; ... }),
    # aunque suele ser más cómodo aplicar directamente los helpers del estilo flash_message:
    # render(:update) { |page| page << flash_success; ...}
    def show_flash_messages
      messages = (FLASH_MESSAGE_TYPES & flash.keys).collect do |key|
          jgrowl_display_message(flash[key], key)
      end.join
      flash.discard
      messages
    end
    
    def show_flash_message; show_flash_messages; end # alias of show_flash_messages
    

    # Comprobar si hay más mensajes flash
    def flash_message_set?
      flash_set = false
      FLASH_MESSAGE_TYPES.each do |key|
        flash_set = true unless flash[key].blank?
      end
      return flash_set
    end
    
    # Mostrar directamente mensajes en la vista
    # Las options son las mismas que en el controller.
    
    def flash_success(msg={})
      msg = MSG_FROM_OPTIONS[msg, :success] if msg.is_a? Hash
      jgrowl_display_message(msg, :success)
    end
    
    def flash_error(msg={})
      msg = MSG_FROM_OPTIONS[msg, :error] if msg.is_a? Hash
      jgrowl_display_message(msg, :error)
    end
    
    def flash_warning(msg={})
      msg = MSG_FROM_OPTIONS[msg, :warning] if msg.is_a? Hash
      jgrowl_display_message(msg, :warning)
    end
    
    def flash_notice(msg={})
      msg = MSG_FROM_OPTIONS[msg, :notice] if msg.is_a? Hash
      jgrowl_display_message(msg, :notice)
    end
    
    def flash_message(msg={}) flash_notice(msg); end # alias of jgrowl_notice
    
  
  private
    
    # Muestra directamente un mensaje.
    # Para usar desde la vista, por ejemplo en una operación ajax, en el :complete => show_message('..')
    def jgrowl_display_message(msg, msg_type = :notice)
      header = I18n.t msg_type, :scope => 'common.titles', :default => msg_type.to_s # title depends on key
      "jQuery.jGrowl('#{escape_javascript(msg)}', { header: '#{header}', theme: '#{msg_type}'});"
    end
    
  end
  
end