
function getDate(date){
	var ss=date.replace(/-/g,"/");
	var dDate=new Date(ss.replace("T"," "));
	var nDate=new Date();
	var dd=nDate.getTime()-dDate.getTime();
	var days=Math.floor(dd/(24*3600*1000));
	if(days==2){
		return "前天";
	}else if(days==1){
		return "昨天";
	}else if(days==0){//今天
		var leave1=dd%(24*3600*1000);    //计算天数后剩余的毫秒数
		var hours=Math.floor(leave1/(3600*1000));
		if(hours>0){
			return hours+"小时前";
		}else{
			var leave2=leave1%(3600*1000)        //计算小时数后剩余的毫秒数
			var minutes=Math.floor(leave2/(60*1000))
			if(minutes<=5){
				return "刚刚";
			}
			return minutes+"分钟前";
		}
	}else{
		return date.split("T")[0];
	}
}
function insertTitle(source,date,title,rStyle){
	$("#title_content").html(title);
	$("#source").html(source);
	$("#date").html(getDate(date));			
	setTitleStyle(rStyle);
}
var randomColor="";
var arrColors=["#F96522","#1D7DC6","#2CA6E8","#0B656E","#E50011"];
function setTitleStyle(rStyle){
	randomColor=Math.floor(Math.random()*arrColors.length);
	var rColor=arrColors[randomColor];
	if(rStyle==0){
		$("#header").css("border-left-color",rColor).css("padding-left","0.6em");
		$("#title_color").addClass("nodisplay");
		$("#source_date").css("background-color","#FFF");
		$("#source").css("padding-left","0.7em");
	}else if(rStyle==1){
		$("#title_color").addClass("nodisplay");
		$("#header").css("border-color","#FFF");
		$("#source").css("padding-left","0.6em");
		$("#source").addClass("marginL10");
		$("#source_date").css("background-color",rColor);
	}
}
function insertContent(data,mid,fsize,source){	//插入文章内容
	$("#content_main").empty();//推送的时候将原来的内容清空
	$("#header").siblings().remove();
	document.body.style.fontSize=fsize+"px";
	insertTitle(source,data.ctime,data.title,mid);
	var html=replaceIMG(removeBr(data.content));
	$oContent=$("#content_main");
	$oContent.html(html);
	var conWidth=$("#content_main").width();
	showMap(data.coord);//先解析出是否有地图。这样会先有占位图
	$(".img_wrap").height(conWidth/4*2.5);
	setVideo(data.videos);
	setImgSet(data.imageset);
	setImgsSrc(data.images);
	setAudios(data.audios);
	setAttachs(data.attachs);
	setWebpage(data.webpages);
	removeSpan();
	setLinkPhoneForm();
	
	getPubRel();//获取关联投稿
}
function replaceIMG(html) {
	var imgreg =/<[dD][iI][vV][^>]*><[iI][mM][gG][^>]*src="[^"]+"[^>]*>/g;
	if(res = imgreg.exec(html)){
		if(html.indexOf(res[0]) == 0){
			html=html.replace(res[0],"");
			if(res[0].indexOf("title_top")>=0){//检测是否决定标题图片一定在最前面
				$("#title").prepend(res[0]);
				$("#title").css("margin-top","0").children(".img_wrap").css({"margin-top":"0","height":"230px"});
			}else{
				var random=Math.floor(Math.random()*2);
				if(random==0){
					$("#title").prepend(res[0]);//在标题前面插入图片
					$("#title").css("margin-top","0").children(".img_wrap").css({"margin-top":"0","height":"230px"});
				}else{
					$("#title").append(res[0]);
				}
			}
		}
	}
	return html;
}
function setVideo(videos){
	if($("img.video").length<=0||videos.length<=0){
		return;
	}
	var index=0;
	var conWidth=$("#content_main").width();
	$("img.video").each(function(){
		setImgWidth(videos[index]["thumbnail"],$(this),conWidth);
		var oImg=document.createElement("div");
		$(oImg).css("background","url(play.png) no-repeat center");
		$(oImg).css({"position":"absolute","left":"50%","top":"50%","width":"75px","height":"75px","margin-top":"-37px","margin-left":"-37px"});
		$(this).parent().addClass("img_wrap").append($(oImg));
		$(this).parent().bind("click",(function(k){
			return function(){
				//window.external.playVideo(videos[k]["obj"]["url"]);
				var args=[];
				var url=videos[k]["obj"]["url"];
				if(KGlobal.kindDevice=="android"){//只针对android
					url="'"+url+"'";
				}
				args.push(url);
				callDevice("playVideo",args,function(){});
			}
		})(index));
		var title=$('<h6>'+videos[index]["descr"]+'</h6>');
		title.insertAfter($(this).parent());
		index++;
	}).parent().addClass("img_wrap");
}
function setImgSet(imageset){
	if($("img.imgset").length<=0||!imageset){
		return;
	}
	var conWidth=$("#content_main").width();
	$imgset=$("img.imgset").eq(0);
	setImgWidth(imageset["images"][0]["obj"]["url"],$imgset,conWidth);
	$imgset.parent().bind("click",function(){
		//window.external.showImgset();
		callDevice("showImgset",[],function(){});
	}).addClass("img_wrap");
	for(var i=1,l=imageset["images"].length;i<l;i++){
		$img=$("<img src=''/>");
		setImgWidth(imageset["images"][i]["obj"]["url"],$img,conWidth);
		$imgset.parent().append($img);
	}
	$imgset.parent().append($("<div class='bg_imgset' style='background-color:"+arrColors[randomColor]+"'>图集</div>"));
	var title=$('<h6>'+imageset["title"]+'</h6>');
	title.insertAfter($imgset.parent());
	$imgsibs=$imgset.siblings("img");
	$imgsibs.push($imgset[0]);
	index=0;
	setTimeout("changeImg($imgsibs,0)",10);	
}
function changeImg(imgs,index){
	$index=index>=imgs.length?0:index;
	now=imgs[$index];
	$index++;
	$(now).show();
	$(now).siblings("img").hide();
	setTimeout("changeImg($imgsibs,$index)",5000);
}
function setImgsSrc(images){ 
	if(images.length<=0){
		return;
	}
	$pics=$("img.pic");
	var conWidth=$("#content_main").width();
	var bodyWidth=$("#title").width();
	for(var i=0,l=$pics.length;i<l;i++){
		$pic=$pics.eq(i);
		var src=images[i]?images[i]["obj"]["url"]:"";
		$pic.parent("div.img_wrap").bind("click",(function(k){
			return function(){
				var args=[];
				args.push(k);
				callDevice("showPic",args,function(){});
			}
		})(i));
		if(i==0 && $("#title img.pic").length>0){
			setImgWidth(src,$pic,bodyWidth);
			continue;
		}
		setImgWidth(src,$pic,conWidth);
		var title=$('<h6>'+images[i]["descr"]+'</h6>');
		title.insertAfter($pic.parent());
	}
}
function removeSpan(){
	$spans=$("span:not(#title_color)");
	for(var i=0,l=$spans.length;i<l;i++){
		if(!$.trim($spans.eq(i).html())||$spans.eq(i).html()=="&nbsp;"){
			$spans.eq(i).remove();
		}
	}
}
function removeBr(con){
	var reg=/<br\/?>/gi;
	return con.replace(reg,"");
}
function setAudios(audios){
	if(audios.length<=0 || !$("div.audio")){
		return;
	}
	var oAudios=$("div.audio");//音频数组长度
	var lAudio=audios.length;
	for(var i=0,l=oAudios.length;i<l;i++){
		if(lAudio<i){
			break;
		}
		var oA=$("<a href='javascript:void(0)'></a>");
		oA.attr("audiourl",audios[i]["obj"]["url"]);
		oA.css("color",arrColors[randomColor]).html(audios[i]["descr"]);
		oA.css("background","url(img"+randomColor+"/audio.png) no-repeat left center");
		oA.css("background-size","28px 28px");
		oAudios.eq(i).append(oA);
		oA.click(function(){
			//window.external.showAudio($(this).attr("audiourl"));
			var args=[];
			var url=$(this).attr("audiourl");
			if(KGlobal.kindDevice=="android"){//只针对android
				url="'"+url+"'";
			}
			args.push(url);
			callDevice("showAudio",args,function(){});
		});
	}
}
function setAttachs(attachs){
	if(attachs.length<=0 || !$("div.attach")){
		return;
	}
	var oAttachs=$("div.attach");//附件数组长度
	var lAttach=attachs.length;
	for(var i=0,l=oAttachs.length;i<l;i++){
		if(lAttach<i){
			break;
		}
		var oA=$("<a href=''></a>");
		oA.attr("href",attachs[i]["obj"]["url"]);
		oA.css("color",arrColors[randomColor]).html(attachs[i]["descr"]);
		oA.css("background","url(img"+randomColor+"/attach.png) no-repeat left center");
		oA.css("background-size","28px 28px");
		oAttachs.eq(i).append(oA);
	}
}
function setWebpage(webpages){
	if(webpages.length<=0 || !$("div.webpage")){
		return;
	}
	var oWebpages=$("div.webpage");
	var lWebpage=webpages.length;
	for(var i=0,l=oWebpages.length;i<l;i++){
		if(lWebpage<i){
			break;
		}
		var oA=$("<a href='javascript:void(0)'></a>");
		oA.css("color",arrColors[randomColor]).html(webpages[i]["descr"] ? webpages[i]["descr"] :"点击查看网页");
		oA.css("background","url(img"+randomColor+"/webpage.png) no-repeat left center");
		oA.css("background-size","28px 28px");
		oWebpages.eq(i).append(oA);
		oA.bind("click",(function(k){
			return function(){
				//window.external.showWebpage(k);
				var args=[];
				args.push(k);
				callDevice("showWebpage",args,function(){});
			}
		})(k));
	}
}

function showMap(coord){
	var oMain=$("#content");
	if(coord){
		var coords=coord.split(",");
		var oMap=oMain.find(".map");
		if(!oMap.length){
			oMap=oMain;
		}
		oMap.append("<div id='map' coord='"+coords+"' style='border:1px solid silver;border-radius:5px;margin:15px 0;'><div class='img_wrap' style='margin:0;border-bottom:1px solid silver;'><img src=''></div></div>");
		var conWidth=oMain.width();
		var x=coords[0];
		var y=coords[1];
		var src="http://api.map.baidu.com/staticimage?center="+x+","+y+"&width=500&height=260&zoom=13&markers="+x+","+y;
		setImgWidth(src,$("#map img").eq(0),conWidth);
		var key="http://api.map.baidu.com/api?v=2.0&ak=A2d174e0f92861fab6c28150d25058be";
		var url="http://api.map.baidu.com/geocoder/v2/?ak="+key+"&callback=renderReverse&location="+y+","+x+"&output=json&pois=0";
		$.ajax({
			url:url,
			type:"GET",
			dataType:"jsonp",
			success:function(data){
				var oCoord={};
				oCoord["x"]=x;oCoord["y"]=y;
				$("#map").append("<h6 style='font-size:14px;text-align:left;padding:0 10px;margin:5px 0;color:#8A8A8A;'><img style='display:inline;width:26px;height:30px;vertical-align:middle;' src='coord.png'>地址:"+data["result"]["formatted_address"]+"</h6>").click(function(){
					var args=[];
					args.push(getStr(oMain.find(".map").attr("webappid")));
					args.push(getStr(JSON.stringify(oCoord)));
					callDevice("openwebapp",args,function(){});
				});
			}
		});
	}
}
function setLinkPhoneForm(){//设置链接和一键拨号  表单
	var links=$(".link");
	for(var i=0,l=links.length;i<l;i++){
		var oLink=links.eq(i);
		var strHtml="<div class='ico'><img src='link.png'/></div><div class='text'><h4><s></s><s class='right'></s>"+$(oLink).attr("descr")+"</h4></div>";
		oLink.html(strHtml);
		var link=oLink.attr("link");
		if(KGlobal.kindDevice=="android"){//只针对andoid
			link="'"+link+"'";
		}
		oLink.bind("click",(function(url){
			return function(){
				var args=[];
				args.push(url);
				callDevice("openlink",args,function(){});
			}
		})(link))
	}
	var teles=$(".tele");
	for(var i=0,l=teles.length;i<l;i++){
		var oPhone=teles.eq(i);
		var strHtml="<div class='ico'><img src='tele.png'/></div><div class='text'><h4><s></s><s class='right'></s>"+$(oPhone).attr("descr")+"</h4></div>";
		oPhone.html(strHtml);
		var phones=oPhone.attr("phones");
		oPhone.bind("click",(function(phone){
			return function(){
				var arr=phone.split("&");
				if(arr.length<=0){
					return;
				}
				$("#phones").show();
				var oDl=$("#phones").find("dl");
				oDl.empty();
				for(var j=0,jj=arr.length;j<jj;j++){
					oDl.append('<dd><a href="tel:'+arr[j]+'">'+arr[j]+'</a></dd>');
				}
			}
		})(phones));
	}
	$("#phones h3").click(function(){
		$("#phones").hide();
	});
	var forms=$(".form");
	for(var i=0,l=forms.length;i<l;i++){
		var oForm=forms.eq(i);
		if(oForm.attr("status")=="close"){//如果表单是关闭的 ("close","open")
			oForm.hide();
			continue;
		}
		var strHtml="<div class='ico'><img src='form.png'/></div><div class='text'><h4><s></s><s class='right'></s>"+$(oForm).attr("formDescr")+"</h4></div>";
		oForm.html(strHtml).addClass("clear");
		var rand=randomColor+1;
		var objForm={};
		objForm["color"]=rand;
		oForm.bind("click",(function(form){
			return function(){
				var args=[];
				args.push(getStr(form.attr("webappid")));
				var formid=form.attr("formid");
				objForm["id"]=formid;
				args.push(getStr(JSON.stringify(objForm)));
				callDevice("openwebapp",args,function(){});//参数是formid和form所要展现的color的序列号从1开始
			}
		})(oForm))				
	}
	var coupons=$(".coupon");
	for(var i=0,l=coupons.length;i<l;i++){
		var oCoupon=coupons.eq(i);
		if(oCoupon.attr("status")=="close"){
			oCoupon.hide();continue;
		}
		var payType=$(oCoupon).attr("payType");
		var strHtml="<div class='ico'><img src='"+payType+".png'/></div><div class='text'><h4><s></s><s class='right'></s>"+$(oCoupon).attr("couponDescr")+"</h4></div>";				
		oCoupon.html(strHtml).addClass("clear");
		oCoupon.bind("click",(function(coupon){//点击优惠券
			return function(){
				var args=[];
				args.push(getStr(coupon.attr("webappid")));
				var obj={};
				obj["id"]=coupon.attr("couponId");
				args.push(getStr(JSON.stringify(obj)));
				callDevice("openwebapp",args,function(){});
			}
		})(oCoupon))	
	}		
}
$("#phones .bg_wrap").click(function(){
	$(this).parents("#phones").hide();
});
function GoBack(){
	if($("#phones").css("display")!="none"){//如果显示
		$("#phones").hide();
	}else{
		callDevice("exit",[],function(){});
	}
}
