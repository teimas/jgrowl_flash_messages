jGrowl Flash Message
==============

Es un patrón simple para manejar los mensajes flash en la aplicación, añade helpers para el
controlador (para fijar los mensajes de forma fácil) y un helper en la vista, que muestra
los mensajes en popups al estilo growl (de mac os).

Depende de las librería javascript `jQuery` con el plugin `jGrowl`.

Añade simples helpers para el controlador y la vista que simplifican el uso de los mensajes de notificación.
Características y dependencias con javascript:

  * __El CSS__ va en las hojas de estilo del plugin de jQuery jGrowl (tiene su propio mecanismo de estilos), por lo tanto para dar estilos a los mensajes hay que hacerlo según sus clases.
  * __Tampoco se genera HTML__ directamente en la vista (se genera indirectamente desde javascript, pero son mensajes flotantes), por lo tanto no hace falta hacer sitio en el layout para meter el contenido de los mensajes.

Instalación
-----------------
Instalar `jQuery`: [http://jquery.com/](http://jquery.com/)

Instalar jQuery plugin `jGrowl`: [http://plugins.jquery.com/project/jGrowl](http://plugins.jquery.com/project/jGrowl)

Copiar el código de este plugin en su carpeta `rails_app/vendor/plugins/jgrowl_flash_messages`
    cd rails_app/vendor/plugins
    git clone git@github.com:teimas/jgrowl_flash_messages.git


Helpers del Controlador
-----------------

### Ejemplos
    flash_success( message_or_options = {} )
    flash_warning( message_or_options = {} )
    flash_error( message_or_options = {} )
    flash_notice( message_or_options = {} ) # también vale flash_message, que es sinónimo

Sirven para fijar un mensaje de alguno de esos tipos (success, warning, error o notice).
Se les puede pasar un String (mensaje) que se muestra directamente, 
o un hash de opciones, que sirve para internacionalizar el mensaje:

  * :scope => donde se busca el mensaje (igual que el scope de I18n.translate). El scope por defecto es "common.flash_messages.#{msg_type}", donde msg_type es 'success', 'warning', 'error' o 'notice' (según el método que se use).
  * :action => clave del mensaje dentro del scope (por defecto es 'default'). En el fichero de internacionalización debe poner al menos un texto para "common.flash_messages.#{msg_type}.default" (para cada msg_type).
  * :key => clave del mensaje completa (se forma automáticamente como scope.action). Si se le da algún valor, :scope y :action serán ignorados.
  * El resto de opciones se usan para interpolación como en el método `I18n.translate`

### Ejemplos:
    flash_success
    #=> mostrará el mensaje en I18n.translate 'common.flash_messages.success.default'
    
    flash_success :action => :create
    #=> I18n.translate 'common.flash_messages.success.create'
    
    flash_error :scope => 'my.errors', :action => 'fatal'
    #=> t 'my.errors.fatal'
    
    flash_error :key => 'my.errors.fatal'
    #=> t 'my.errors.fatal'
    
    flash_message 'Texto ad-hoc'
    #=> muestra una notice con el texto tal cual.


Helpers de la Vista
-----------------

    render_flash_messages(options={})
    
Configura jgrowl y muestra los mensajes flash que haya guardados desde el controlador.

    <%= render_flash_messages %>
    
Muestra los mensajes flash (de tipo success, warning, error o notice) que se declararon en el
controlador al momento de cargar la página.
Se puede poner tanto en el body como en el head del layout, pero tiene que ir después de la 
inclusión de las librerías jQuery y el plugin de jGrowl.

Se le puede pasar un hash de options, que sirven para configurar las opciones de jgrowl, 
de las cuales se pone closerTemplate con un mensaje internacionalizado por defecto (t 'common.links.close_all')
(ver página del plugin jgrowl: http://www.stanlemon.net/projects/jgrowl.html#options).


AJAX y JavaScript:
-----------------

También se pueden mostrar los mensajes desde el controlador en una acción ajax, utilizando
el helper show_flash_messages, que hace lo mismo que render_flash_messages, pero para ajax:

### Ejemplo para usar en el Controlador
    flash_success # mensaje de éxito
    flash_notice 'Otro mensaje para que el usuario se acuerde de cosas.'
    render :update do |page|
      page << show_flash_messages
      #...
    end

### Ejemplo para usar en la vista
    <%= flash_success(msg_or_options) %>
    <%= flash_warning(msg_or_options) %>
    <%= flash_error(msg_or_options) %>
    <%= flash_notice(msg_or_options) %> # alias: flash_message

Estos helpers son para las acciones con javascript directamente en la vista.
### Ejemplos de uso:

    <%= link_to_remote 'hacer algo en remoto', :url => 'mycontroller/myaction', 
        :complete => flash_success, :failure => flash_error %>

    <%= link_to_function 'mostrar mensaje', flash_notice('este es el mensaje') %>
    
    <%= javascript_tag flash_warning(:action => 'takecare') %>


