/*
bindWithDelay jQuery plugin
Author: Brian Grinstead
MIT license: http://www.opensource.org/licenses/mit-license.php

http://github.com/bgrins/bindWithDelay
*/
(function($) {
  $.fn.bindWithDelay = function( type, data, fn, timeout, throttle ) {
  	if ( $.isFunction( data ) ) {
  		throttle = timeout;
  		timeout = fn;
  		fn = data;
  		data = undefined;
  	}

  	// Allow delayed function to be removed with fn in unbind function
  	fn.guid = fn.guid || ($.guid && $.guid++);

  	// Bind each separately so that each element has its own delay
  	return this.each(function() {
      var wait = null;

      function cb() {
          var e = $.extend(true, { }, arguments[0]);
          var ctx = this;
          var throttler = function() {
          	wait = null;
          	fn.apply(ctx, [e]);
          };

          if (!throttle) { clearTimeout(wait); wait = null; }
          if (!wait) { wait = setTimeout(throttler, timeout); }
      }

      cb.guid = fn.guid;

      $(this).bind(type, data, cb);
  	});
  }
})(jQuery);
/* --- END bindWithDelay --- */


(function($) {
  $("a[href^='http://'], a[href^='https://']").attr("target","_blank");
    
  $('textarea[name="sass"]').bindWithDelay('keyup', function() {
    $("#sass-form").submit();
  },750);
  
  $('select').on('change', function() {
    $("#sass-form").submit();
  });

  /* attach a submit handler to the form */
  $("#sass-form").submit(function(event) {

    /* stop form from submitting normally */
    event.preventDefault();

    /* get some values from elements on the page: */
    var $form = $( this ),
        sass = $form.find( 'textarea[name="sass"]' ).val(),
        syntax = $form.find( 'select[name="syntax"]' ).val(),
        output = $form.find( 'select[name="output"]' ).val(),
        plugin = $form.find( 'select[name="plugin"]' ).val(),
        url = $form.attr( 'action' );

    /* Send the data using post and put the results in a div */
    $.post( url, { sass: sass, syntax: syntax, output: output, plugin: plugin },
      function( data ) {
        // var content = $( data ).find( '#content' );
        $( "#css" ).empty().append( data );
        prettyPrint();
      }
    );
  });
})(jQuery);