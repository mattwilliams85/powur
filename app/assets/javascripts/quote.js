var _data = {};

jQuery(function($){
    $(document).ready(function(){
        $("#user_nav").css("display","none");
        _data.customer={};

        //receive customer data from the uri
        _ajax({_ajaxType:"get", _url:window.location.pathname, _callback:function(data,text){
            _data.customer = data;
            $("#customer_signup").find(".js-multi_form_fieldset").removeAttr("disabled");

            if(typeof _data.customer.properties.email !== "undefined"){
                //prepopulate form field values
                $.each(_data.customer.properties, function(key, val){
                    $("#customer_signup").find("input[name='"+key+"']").val(val);});
                $("button#step_one").text("Update Contact info");
                $("button#step_two").text("Update Home info");
                $("button#step_three").text("Update Utility info");
                $("#state option").filter(function(){return $(this).text()==_data.customer.properties.state}).attr("selected", true);
                $("#roof_material option").filter(function(){return $(this).text()==_data.customer.properties.roof_material}).attr("selected", true);
                $("#provider option").filter(function(){return $(this).text()==_data.customer.properties.provider}).attr("selected", true);

            }else{
                $("#customer_signup").find(".js-home_info, .js-util_info").attr("disabled", "disabled");
                console.log("new user");
            }
        }});
    });

    $(document).on("click", "#customer_signup button", function(e){
        _formData = $("#customer_signup").serializeObject();

        //decide if the quote is already in the system
        if(_data.customer.actions.filter(function(action){return action.name=="update"}).length>0) _formData["quote"]=_data.customer.actions.filter(function(action){return action.name=="update"})[0].fields.filter(function(field){return field.name=="quote"})[0].value;
        else _formData["sponsor"] = _data.customer.actions.filter(function(action){return action.name=="create"})[0].fields.filter(function(field){return (field.name="promoter"&&field.type=="hidden")})[0].value

        _verb= (typeof _formData.quote!== "undefined")? "patch":"post";

        _ajax({_ajaxType:_verb, _url:"/quote", _postObj:_formData, _callback:function(data, text){
            //console.log("data input complete");
            _data.customer = data;
        }});
    });
});


