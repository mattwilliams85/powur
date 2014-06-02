var _data = {};

jQuery(function($){
    $(document).ready(function(){
        _getRoot(function(){
            //populate form
            _action = _data.root.actions.filter(function(action){return action.href=="/login/register";})[0];
            for(i=0;i<_action.fields.length;i++)
                $(".js-signup_form").find("input[name='"+_action.fields[i].name+"']").val(_action.fields[i].value)
        });
    });

    $(document).on("click", ".js-signup_form button", function(e){
        e.preventDefault();
        _formSubmit(e, $(".js-signup_form"), "/login/register", "post", function(data, text){
            window.location = data.links.filter(function(link){return link.rel=="index"})[0].href;
        });
    });



});


