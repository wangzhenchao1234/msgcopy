function changeFontSize(size){//android调用js事件，改变字体大小
	document.body.style.fontSize=size+"px";
}

var KGlobal={};
function checkDevice(){//检测设备
	var ua=navigator.userAgent.toLowerCase();
	if (/android/i.test(ua)){
	    KGlobal.kindDevice="android";
	}else if(/ipad|iphone/i.test(ua)){
		KGlobal.kindDevice="ios";
	}
}
checkDevice();//检验是ios还是android
if(KGlobal.kindDevice=="ios"){//如果是ios调用bbhasloaded方法
	callDevice("loadfinished",[],function(){});
}
function getStr(str){	//只有在android的时候如果是字符串必须加引号
	if(KGlobal.kindDevice=="android"){
		return "'"+str+"'";
	}
	return str;
}
function callDevice(cmd,arg,errfun){	//js调用客户端的函数  (参数说明:函数名称，参数（以数组形式传参）,调用失败函数)
	try{
		if(KGlobal.kindDevice=="ios"){
            try {
                var url = "msgcopy://" + cmd;
                for (var i = 0, l = arg.length; i < l; i++) {
                    var a = BASE64.encoder(arg[i].toString());
                    url += "-msgcopy-" + a.replace("http://", "http%3a%2f%2f");
                }
                url = url.replace(/=/g,"");
                window.location.href = url;
            } catch (ex) {
                if (typeof errfun != "undefined")errfun();
            }	
		}else if(KGlobal.kindDevice=="android"){
			var args="";
			if(arg.length>0){
				args=arg[0];
			}
			for(var i=1,l=arg.length;i<l;i++){
				args+=","+arg[i];
			}
			var url="";
			if(arg.length>0){
				url="window.external."+cmd+"("+args+")";
			}else{
				url="window.external."+cmd+"()";
			}
			eval(url);
		}
	}catch(ex){
		alert("call device error");
		errfun();
	}
}
function loadImgs(src,callback){//图片的预加载
	var img=new Image();
	img.src=src;
	if(img.complete){
		callback(img);
		return;
	}
	img.onload=function(){
		callback(img);
	}
}
function setImgWidth(src,$pic,wrapWidth,x,y){
	if(!src){
		return;
	}
	x = x || 4;
	y = y || 2.5;
	loadImgs(src,(function(oImg){return function(img){
		if(img.width/x>img.height/y){
			var oHeight=wrapWidth/x*y;
			var oWidth=img.width*oHeight/img.height;
			var marginLeft=(wrapWidth-oWidth)/2;
			oImg.height(oHeight).width(oWidth).css("margin-left",marginLeft);//也采用中间截取，两边不显示
		}else{
			var oHeight1=wrapWidth/x*y;
			var oHeight=img.height*wrapWidth/img.width;
			oImg.width(wrapWidth).height(oHeight);
			var marginTop=(oHeight-oHeight1)/2*(-1);
			oImg.css("margin-top",marginTop+"px");//采用中心截取
		}
		oImg.attr("src",src).show();
	}})($pic));
}
function GoBack(){
	callDevice("exit",[],function(){});
}

var PubRel = {
	"hunpai":function(pubrels){
		var str = "<div class='pubrels'>";
		str += "<h3>相关新闻</h3><ul>";
		for(var i=0,l=pubrels.length;i<l;i++){
			var pub = pubrels[i]["pub"],
				article = pub["article"];
			str += "<li pub='"+ pub["id"] +"'><s></s>"+ article["title"] +"</li>";
		}
		str += "</ul></div>";
		$("#content_main").append($(str));
	},
	"zhuanti":function(pubrels){
		var oPubrel = $(".pubrels"),
			oUl = $("<ul></ul>");
		for(var i=0,l=pubrels.length;i<l;i++){
			var pub = pubrels[i]["pub"],
				article = pub["article"],
				thumb = article["thumbnail"],
				oLi = $("<li pub='"+ pub["id"] +"'></li>"),
				iWidth = $("#articles").width()/2,
				iHeight = iWidth*3/4;
			oLi.css({height:iHeight});
			if(!jQuery.isEmptyObject(thumb)){
				oLi.append("<img class='pic' src=''>");
				setImgWidth(thumb["url"],oLi.find("img.pic"),iWidth,4,3);
			}else{
				oLi.css({"background-color":"#E0E0E0"});
			}
			if(!jQuery.isEmptyObject(article["ctype"])){
				if(article["ctype"]["systitle"] == "hunpai"){
					oLi.append("<img class='video' src='play.png'>");
				}
			}
			oLi.append($("<p>"+ article["title"] +"</p>"));
			oUl.append(oLi);
		}
		oPubrel.append($("<h3>相关新闻</h3>")).append(oUl);
	},
	"dianshang":function(pubrels){
		var oPubrel = $(".pubrels"),
			oUl = $("<ul></ul>");
		for(var i=0,l=pubrels.length;i<l;i++){
			var pub = pubrels[i]["pub"],
				article = pub["article"],
				thumb = article["thumbnail"],
				oLi = $("<li pub='"+ pub["id"] +"'><div><p class='img'></p></div></li>"),
				iWidth = $("#main").width()/2,
				iHeight = iWidth*3/4,
				oDiv = oLi.find("div");
			oDiv.find("p.img").css({height:iHeight});
			if(!jQuery.isEmptyObject(thumb)){
				oDiv.find("p.img").append("<img class='pic' src=''>");
				setImgWidth(thumb["url"],oLi.find("img.pic"),iWidth,4,3);
			}else{
				oDiv.find("p.img").css({"background-color":"#E0E0E0"});
			}
			oDiv.append($("<div class='desc'><h4>"+ article["title"] +"</h4></div>"));
			if(!jQuery.isEmptyObject(article["ctype"])){
				switch(article["ctype"]["systitle"]){
					case "shipin":
						oDiv.find("p.img").append("<img class='video' src='play.png'>");
						break;
					case "dianshang":
						var oDesc = oDiv.find("div.desc"),
							oPrice = $("<p class='price'></p>");
						oPrice.append("<span class='nowprice'>"+ article["descr"] +"元</span>");
						oPrice.append("<span class='oriprice'>原价:<s>"+ article["source"] +"元</s></span>");
						oDesc.append(oPrice);
						break;
				}
			}
			oUl.append(oLi);
		}
		oPubrel.append($("<h3>相关新闻</h3><hr/>")).append(oUl);
		var oTitle = oPubrel.find("h3");
		oTitle.css({"margin-left":oTitle.width()/(-2)});
	}
}
function get_pubrel_callback(data){
	var pubrels = data["pubrels"];
	switch(ptype){
		case "hunpai":
			PubRel.hunpai(pubrels);
			break;
		case "dianshang":
			PubRel.dianshang(pubrels);
			break;
		case "zhuanti":
			PubRel.zhuanti(pubrels);
			break;
	}
	$(".pubrels li").click(function(){ // 打开关联投稿 
		var pub_id = $(this).attr("pub");
		callDevice("openpub",[pub_id],function(){});
	});
}
function getPubRel(){
	var args=[];
	var callback = "get_pubrel_callback";
	if(KGlobal.kindDevice == "android"){	//只针对android
		callback="'"+callback+"'";
	}
	args.push(callback);
	callDevice("web_get_pubrel",args,function(){});
}