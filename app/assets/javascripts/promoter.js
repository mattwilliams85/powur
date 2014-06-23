var _data = {};

jQuery(function($){
    $(document).ready(function(){
        _getRoot(function(){
            //populate form
            _data.action = _data.root.actions.filter(function(action){return action.name=="create";})[0];
            for(i=0;i<_data.action.fields.length;i++)
                $(".js-signup_form").find("input[name='"+_data.action.fields[i].name+"']").val(_data.action.fields[i].value)
        });
    });

    $(document).on("click", ".js-signup_form button", function(e){
        e.preventDefault();
        _formSubmit(e, $(".js-signup_form"), _data.action.href, _data.action.method, function(data, text){
            window.location = data.links.filter(function(link){return link.rel=="index"})[0].href;
        });
    });

});


