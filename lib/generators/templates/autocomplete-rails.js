/*
* Unobtrusive autocomplete
*
/*
* Unobtrusive autocomplete
*
* To use it, you just have to include the HTML attribute autocomplete
* with the autocomplete URL as the value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete">
*
* Optionally, you can use a jQuery selector to specify a field that can
* be updated with the element id whenever you find a matching value
*
*   Example:
*       <input type="text" data-autocomplete="/url/to/autocomplete" id_element="#id_field">
*/

$(document).ready(function(){
	$('input[data-autocomplete]').railsAutocomplete();
});

(function(jQuery)
{
	var self = null;
	jQuery.fn.railsAutocomplete = function() {
		return this.live('focus',function() {
			if (!this.railsAutoCompleter) {
				this.railsAutoCompleter = new jQuery.railsAutocomplete(this);
			}
		});
	};

	jQuery.railsAutocomplete = function (e) {
		_e = e;
		this.init(_e);
	};
	jQuery.railsAutocomplete.fn = jQuery.railsAutocomplete.prototype = {
		railsAutocomplete: '0.0.1'
	};
	jQuery.railsAutocomplete.fn.extend = jQuery.railsAutocomplete.extend = jQuery.extend;
        jQuery.railsAutocomplete.fn.extend( $.ui.autocomplete, {
                filter: function(array, term) {
                        var matcher = new RegExp( $.ui.autocomplete.escapeRegex(term), "i" );
                        return $.grep( array, function(value) {
                                return matcher.test( value.for_search || value.label || value.value || value );
                        });
                }
        });
	jQuery.railsAutocomplete.fn.extend({
		init: function(e) {
      e.min_chars = $(e).attr('data-min-chars') || 2;
			e.delimiter = $(e).attr('data-delimiter') || null;
			function split( val ) {
				return val.split( e.delimiter );
			}
			function extractLast( term ) {
				return split( term ).pop().replace(/^\s+/,"");
			}
	    $(e).autocomplete({
				source: function( request, response ) {
          // get extra params from input
          var params = {};
          if ($(e).data('extra-params')){
            params = $(e).data('extra-params');
          }
          // Add term to params
          params.term = extractLast(request.term);
          // Foreach params, try to eval code, else use given string as param
          $.each(params, function(k, v){
            try{
              eval("params."+k+"='"+eval(v)+"';");
            }
            catch(err){
              // do nothing, use given string as param
            }
          });
          $.getJSON( $(e).attr('data-autocomplete'), params, response );
				},
				search: function() {
					// custom minLength
					var term = extractLast( this.value );
					if ( term.length < e.min_chars ) {
						return false;
					}
                                },
				open: function() {
                                        // when appending the result list to another ellement, we need to cancel the "position: relative;" css.
                                        var css = eval('(' + $(e).attr('result_list_css') + ')');
                                        if (css){
                                          ul_css = css["ul"];
                                          li_css = css["li"];
                                          a_css = css["a"];
                                        } else {
                                          ul_css = null;
                                          li_css = null;
                                          a_css = null;
                                        }
                                        if (append_to_ellement){
                                          var ul_selector = (append_to_ellement + ' ul.ui-autocomplete');
                                          var li_selector = (append_to_ellement + ' ul.ui-autocomplete li');
                                          var a_selector = (append_to_ellement + ' ul.ui-autocomplete li a');
                                          ul_css = ul_css || {'position': 'static'};
                                        } else{
                                          var ul_selector = ('ul.ui-autocomplete');
                                          var li_selector = ('ul.ui-autocomplete li');
                                          var a_selector = ('ul.ui-autocomplete li a');
                                        }
                                        if (ul_css){
                                          $(ul_selector).css(ul_css);
                                        }
                                        if (li_css){
                                          $(li_selector).css(li_css);
                                        }
                                        if (a_css){
                                          $(a_selector).css(a_css);
                                        }
				},
				focus: function() {
								// prevent value inserted on focus
					return false;
				},
				select: function( event, ui ) {
					var terms = split( this.value );
					// remove the current input
					terms.pop();
					// add the selected item
					terms.push( ui.item.value );
					// add placeholder to get the comma-and-space at the end
					if (e.delimiter != null) {
						terms.push( "" );
						this.value = terms.join( e.delimiter );
					} else {
						this.value = terms.join("");
						if ($(this).attr('id_element')) {
							$($(this).attr('id_element')).val(ui.item.id);
              // Trigger change event on target
              $($(this).attr('id_element')).trigger('change');
						}
					};
                    var javascript_on_select = $(e).attr('on_select');
                    if (javascript_on_select) {
                      eval('(' + javascript_on_select + ')');
                    };
                    if ($(e).attr('submit_on_select') == 'true') {
                      $(e).closest("form")[0].submit();
                    };
					return false;
				},
                                delay: ($(e).attr('delay') || 300),
                                appendTo: append_to_ellement || "body",
                                disabled: $(e).attr('autocomplete_disabled') || false
			});
    }
  });
})(jQuery);
