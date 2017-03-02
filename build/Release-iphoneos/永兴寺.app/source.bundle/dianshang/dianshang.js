function insertContent(data){
	new DianSh(data);
	
	getPubRel();//获取关联投稿
}
function DianSh(data){
	this._init(data);
}

DianSh.prototype = {
	constructor:DianSh,
	_init:function(data){
		this._showAll(data);
	},
	_showAll:function(data){
		$("#main").html(data["content"]);
		var me = this;
		me._showSlide(data["images"]);
		me._showTitle(data);
		me._showContent(data);
	},
	_showSlide:function(imgs){
		if(imgs.length){
			var str = "<div id='slider' class='swipe'><ul class='swipe-wrap'>";
			for(var i=0,l=imgs.length;i<l;i++){
				str +="<li><img src='"+ imgs[i]["obj"]["url"] +"'></li>";
			}
			if(l>1){
				str += "</ul>";
				str += "<ul class='position'>";
				for(var i=0;i<l;i++){
					str +="<li></li>";
				}
			}
			str +="</ul></div>";
			$("#main").prepend($(str));
			var bullets = $("#slider .position li");
			bullets.eq(0).addClass('on');
			window.mySwipe = new Swipe(document.getElementById('slider'),{
				startSlide: 0,
				speed: 600,
				auto: 5000,
				continuous: true,
				disableScroll: false,
				stopPropagation: false,
				callback: function(pos) {
					var i = bullets.length;
					while (i--) {
						bullets.eq(i).removeClass('on');
					}
					pos = pos % (bullets.length);
					bullets.eq(pos).addClass('on');
				},
				transitionEnd: function(pos) {
					var i = bullets.length;
					while (i--) {
						bullets.eq(i).removeClass('on');
					}
					pos = pos % (bullets.length);
					bullets.eq(pos).addClass('on');
				}
			});
			
			var conWidth = $("#main").width();
			$("#slider").css({"height":conWidth*2.5/4})
			for(var i=0;i<$("#slider li").length;i++){
				var oImg = $("#slider li").eq(i).find("img");
				setImgWidth(oImg.attr("src"),oImg,conWidth,4,2.5);
			}
		}
	},
	_showTitle:function(data){  // 显示title
		var obj = $(data["content"]);
		var str = "<div id='title'>";
		str += "<h3>"+ data["title"] +"</h3>";
		str += "</div>";
		$(".shopinfo").before($(str));
		
		var oForm = $(".shopinfo .form");
		var descr = obj.find(".form").attr("descr") || "立即购买";
		oForm.append($("<a href='Javascript:void(0);'>"+ descr +"</a>"));
		var oPrice = $(".shopinfo .price");
		var price = "";
		var flag = true;
		if(data["descr"]){
			price += "<p><b>￥"+ data["descr"] +"</b>";
			if(oPrice.attr("desc")){
				price += "<small>" + oPrice.attr("desc") +"</small>";
			}
			price += "</p>";
			flag = false;
		}
		if(data["source"]){
			if(flag){
				price +="<p class='gray'>原价:<span>￥"+ data["source"] +"</span></p>";
			}else{
				price +="<p class='gray'>原价:<s>￥"+ data["source"] +"</s></p>";
			}
		}
		oPrice.append($(price));
		oForm.click(function(){
			var args=[];
			if(!oForm.attr("webappid")){
				alert("web提示:获取webapp_id失败");
				return;
			}
			args.push(getStr(oForm.attr("webappid")));
			var formid=oForm.attr("form_id");
			var objForm={};
			objForm["color"] = Math.floor(Math.random()*5); //随机的color参数
			objForm["id"] = formid;
			args.push(getStr(JSON.stringify(objForm)));
			callDevice("openwebapp",args,function(){});
		});
	},
	_showContent:function(data){ //显示content
		var me = this;
		me._showImgset(data["imageset"]);
		me._showVideo(data["videos"]);
		me._showLinkPhone(data);
		me._showMap(data.coord);
	},
	_showImgset:function(imageset){
		if($("img.imgset").length<=0||!imageset){
			return;
		}
		var conWidth=$("#main").width();
		
		var oImgset = $("<ul class='imgset'></ul>");
		for(var i=0,l=imageset["images"].length;i<l;i++){
			var img = imageset["images"][i];
			var oLi = $("<li><div class='img_wrap'><img src=''/></div></li>");
			oLi.find("img").attr("src",img["obj"]["url"]);
			oLi.append('<h6 class="gray">'+img["descr"]+'</h6>');
			oLi.find("div.img_wrap").bind("click",function(){
				callDevice("showImgset",[],function(){});
			});
			oImgset.append(oLi);
		}
		$("img.imgset").parents(".img_wrap").replaceWith(oImgset);
		oImgset.find("img").show();
	},
	_showVideo:function(videos){
		if($("img.video").length<=0||videos.length<=0){
			return;
		}
		var index=0;
		var conWidth=$("#main").width();
		$("img.video").each(function(){
			$(this).attr("src",videos[index]["thumbnail"]);
			var oImg=document.createElement("div");
			$(oImg).css("background","url(play.png) no-repeat center");
			$(oImg).css({"position":"absolute","left":"50%","top":"50%","width":"75px","height":"75px","margin-top":"-37px","margin-left":"-37px"});
			$(this).parent().addClass("img_wrap").append($(oImg));
			$(this).parent().bind("click",(function(k){
				return function(){
					var args=[];
					var url=videos[k]["obj"]["url"];
					if(KGlobal.kindDevice=="android"){	//只针对android
						url="'"+url+"'";
					}
					args.push(url);
					callDevice("playVideo",args,function(){});
				}
			})(index));
			var title=$('<h6>'+videos[index]["descr"]+'</h6>');
			title.insertAfter($(this).parent());
			index++;
		}).show().parent().addClass("img_wrap").css("position","relative");
	},
	_showLinkPhone:function(){
		var links=$(".link");
		for(var i=0,l=links.length;i<l;i++){
			var oLink=links.eq(i);
			var strHtml="<div class='ico'><img src='link.png'/></div><div class='text'><h4>"+$(oLink).attr("descr")+"</h4></div>";
			oLink.html(strHtml);
			var link=oLink.attr("link");
			if(KGlobal.kindDevice=="android"){	//只针对andoid
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
			var strHtml="<div class='ico'><img src='tele.png'/></div><div class='text'><h4>"+$(oPhone).attr("descr")+"</h4></div>";
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
	},
	_showMap:function(coord){
			var oMain=$("#main");
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
				setImgWidth(src,$("#map img").eq(0),conWidth,4,2.5);
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
}
function GoBack(){
	if($("#phones").css("display")!="none"){	//如果显示
		$("#phones").hide();
	}else{
		callDevice("exit",[],function(){});
	}
}