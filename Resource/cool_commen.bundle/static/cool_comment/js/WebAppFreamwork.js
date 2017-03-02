function GoBack(){
	if(isShowLargeImage)
	{
	 
		$.fancybox.close();
	}else if($("#attach_layer").css("display")!="none")
	{
		
		$("#comment_content").css({display:"block"});
		// $(document).scrollTop(scrooTop);
		 $(document).scrollTop(scrooTop);
		 $("#attach_layer").css({"top":scrooTop+"px"});
		$("#attach_layer") .animate({left:$(document).width()+'px',right:-$(document).width()+'px'},300,function(){
			 
			//$(document).scrollTop(scrooTop);
			 
			
			$(this).css({ minHeight:+"0px",display:"none",left:"0px"});
		 
			 
			
			
     
		}).click(function(){ });//菜单块向右移动 
		  $("#comment_content").animate({left:'0px'},300,function(){
			  	 
			  	 //$("html, body").animate({ scrollTop: scrooTop+"px" },200);
			  	  
			  });
		 
		 SendMessageToDevice("canRefresh","true");
		 
	}
	else {
		return true; //让客户端控制关闭
	}
	return false;//web 自己处理了 不用管了
}

$channel_id="";

function getChannel_id(){
	var reg = new RegExp("(^|&)"+ "channel_id" +"=([^&]*)(&|$)","i");
	var r=window.location.search.substr(1).match(reg);
	if (r!=null) {
		$channel_id="?channel_id="+unescape(r[2]);
	}else{
		alert("没有填写渠道号");
		return;
	}
}
 
function SendMessageToDevice(cmd,arg,ErrorOpen)
{
    
	var boundary="-msgarg-";
	try	{
    	//调用ios客户端
    	var url=cmd+"://";
        var argArr=arg.toString().split(boundary);
    	 url+=argArr[0];
    	for (var i=1; i < argArr.length; i++) {
		     url+=(boundary+argArr[i].replace("http://","http%3a%2f%2f"));
		}
		if(DeviceKind=="IOS")
	 window.location.href=url;
	}catch(err){}
	
	try	{
    	//调用安卓客户端
    	var args="";
    	var argArr=arg.toString().split(boundary);
    	 args=argArr[0];
    	for (var i=1; i < argArr.length; i++) {
		   args+= (","+argArr[i]);
		}
		var cmd="window.external."+cmd+"('"+args+"')";
		 
	eval(cmd);
	
	}catch(err){ 
		 
		if(ErrorOpen!==undefined&&undefined!=false)
		window.open(arg);
		}
	
}

function getDate(date){
			var ss=date.replace(/-/g,"/");
    if(ss.indexOf(".")>0){
        ss=ss.substring(0,ss.indexOf("."));
    }
			var dDate=new Date(ss.replace("T"," "));
			var nDate=new Date();
			var dd=nDate.getTime()-dDate.getTime();
			var days=Math.floor(dd/(24*3600*1000));
			console.info(nDate.getFullYear());
			if(days==0){//今天
				var minu=dDate.getMinutes();
				if(minu<10){
					minu="0"+minu;
				}
				var hour=dDate.getHours();
				if(hour<10){
					hour="0"+hour;
				}
				return hour+":"+minu;
			}else if(nDate.getFullYear()==dDate.getFullYear()){//如果是当年
				var month=dDate.getMonth()+1;
				if(month<10){
					month="0"+month;
				}
				return month+"-"+dDate.getDate();
			}else{//不是同一年
				var month=dDate.getMonth()+1;
				if(month<10){
					month="0"+month;
				}
				return dDate.getFullYear()+"-"+month;
			}
		}

function onLoadError()
{
	try
	{
		window.external.OnLoadError();
	}
	catch(err)
	{
		 
	}
}
