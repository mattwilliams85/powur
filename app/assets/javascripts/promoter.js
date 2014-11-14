var _data = {};

jQuery(function($){
    $(document).ready(function(){
        document.getElementById("intro").volume=0.0;

        _getRoot(function(){
            //populate form
            _data.action = _data.root.actions.filter(function(action){return action.name=="create";})[0];
            for(i=0;i<_data.action.fields.length;i++)
                $(".js-signup_form").find("input[name='"+_data.action.fields[i].name+"']").val(_data.action.fields[i].value)
        });
    });

    $(document).on("click", ".js-signup_form .button", function(e){
        e.preventDefault();
        _action = _data.root.actions[0]
        _formSubmit(e, $(".js-signup_form"), _action.href, _action.method, function(data, text){
            window.location = data.links.filter(function(link){return link.rel=="index"})[0].href;
        });
    });

    $(window).resize(function(){
        var max_width=1225;
        var current_width = (($(window).width()+15)>=max_width)? max_width:($(window).width()+15);

    });
});




