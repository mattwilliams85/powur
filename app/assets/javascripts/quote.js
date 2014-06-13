var _data = {};

jQuery(function($){
    $(document).ready(function(){
        $("#user_nav").css("display","none");
        _data.quotes=[];
        _data.customer={};

        //receive existing details for current customers
        _ajax({_ajaxType:"get", _url:"/customers", _callback:function(data, text){
            //get latest quotes
            $.each(data.entities, function(key, val){
                //get detailed info for the customer
                $.ajax({type:"get", url:"/customers/"+val.properties.id}).done(function(data,text){ _data.quotes.push(data.properties);});
            });
        }});

        //receive customer data from the uri
        _ajax({_ajaxType:"get", _url:window.location.pathname, _callback:function(data,text){
            _data.customer = data.properties;
            $("#customer_signup").find(".js-multi_form_fieldset").removeAttr("disabled");

            if(typeof _data.customer.email !== "undefined"){
                //prepopulate form field values
                $.each(_data.customer, function(key, val){
                    $("#customer_signup").find("input[name='"+key+"']").val(val);
                });
            }else{

                console.log("new user");
            }
        }});
    });

    $(document).on("click", "#customer_signup button", function(e){
        //search to see if there is a matching email or phone 
        _formData = $("#customer_signup").serializeObject();
        _matchedQuote = _data.quotes.filter(function(quote){return quote.email==_formData.email;});
        if(_matchedQuote.length==0) _matchedQuote=_data.quotes.filter(function(quote){return quote.phone==_formData.phone;});

        //update or create new customers
        _verb= (_matchedQuote.length>0)? "patch":"post";
        _endPoint = (_matchedQuote.length>0)? "/customers/"+_matchedQuote[0].id:"/customers";
        _ajax({_ajaxType:_verb, _url:_endPoint, _postObj:_formData, _callback:function(data, text){
            console.log("data input complete");
            //check to see if we are ready to open up additional fieldsets 
        }});
    });
});


