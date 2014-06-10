var _data = {};

jQuery(function($){
    $(document).ready(function(){
        $("#user_nav").css("display","none");

        //******** remove below after testing **********//
        _data.quotes=[];
        _ajax({_ajaxType:"get", _url:"/customers", _callback:function(data, text){
            //get latest quotes
            $.each(data.entities, function(key, val){
                _data.quotes.push(val.properties);
            });
        }});
        //******** remove above after testing **********//

    });
    $(document).on("click", "#customer_signup button", function(e){
        //determine whether it's an existing quote based on the latest data
        _data.quotes=[];
        _ajax({_ajaxType:"get", _url:"/customers", _callback:function(data, text){
            //get latest quotes
            $.each(data.entities, function(key, val){
                _data.quotes.push(val.properties);
            });
            //search to see if there is a matching email or phone 
            _formData = $("#customer_signup").serializeObject();
            _matchedQuote = _data.quotes.filter(function(quote){return quote.email==_formData.email;});
            if(_matchedQuote.length==0) _matchedQuote=_data.quotes.filter(function(quote){return quote.phone==_formData.phone;});

            //update or create new customers
            _verb= (_matchedQuote.length>0)? "patch":"post";
            _endPoint = (_matchedQuote.length>0)? "/customers":"/customers/"+_matchedQuote.id;
            _ajax({_ajaxType:_verb, _url:_endPoint, _postObj:_formData, function(data, text){
                console.log("data input complete");
                //check to see if we are ready to open up additional fieldsets 


            }});

        }});

    });

});


