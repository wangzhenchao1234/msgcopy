function ZhuanTi(data){
	this._init(data);
}
ZhuanTi.prototype={
	constructor:ZhuanTi,
	defaults:{
		datas:{}
	},
	_init:function(data){
		var me=this;
		me.config=me.defaults;
		me.config.datas=data;
		
		me._showAll();
	},
	_showAll:function(){
		var me=this;
		var datas=me.config.datas;
		var oContent=document.createElement("div");
		oContent.innerHTML=datas["content"];
		me._showTitle(datas,oContent);
		me._showContent(datas,oContent);
	},
	_bindEvent:function(oLi){
		oLi.addEventListener("click",function(){
			var pub_id=this.getAttribute("publication_id");
			callDevice("openpub",[pub_id],function(){});
		},false);
	},
	_showTitle:function(datas,oContent){
		var oThumbImg=document.querySelector("#thumb img");
		if(datas["images"].length>0){
			var url = datas["images"][0]["obj"]["url"];
			var oThumb = $("#thumb");
			oThumb.css("height",oThumb.width()/5);
			setImgWidth(url,$(oThumbImg),oThumb.width(),5,1);
		}else{
			document.querySelector("#thumb").removeChild(oThumbImg);
		}
		var oTitle=document.querySelector("#title");
		oTitle.querySelector("h2").innerText=datas["title"];
		oTitle.querySelector("p").innerText=oContent.querySelector("#title p").innerText;
	},
	_showContent:function(datas,oContent){
		var me=this,
			oUl=oContent.querySelector("#articles ul"),
			oLis = oUl.querySelectorAll("li");
		document.querySelector("#articles").appendChild(oUl);
		for(var i=0,l=oLis.length;i<l;i++){
			var oLi=oLis[i];
			oLi.querySelector(".content").className = "content ellipsis" ;
			var pub_id=oLi.getAttribute("publication_id");
			(function(publication_id,oLi){
				//me._showPublication(publication_id,oLi);
				me._bindEvent(oLi);
			})(pub_id,oLi);
		}
	},
	_showPublication:function(pub_id,oLi){
		var me=this;
		ajaxData("GET","/iapi/app/publication/"+pub_id+"/",function(data){
			if(data["article"]["comment_count"]>0){
				var ospan=document.createElement("span");
				ospan.className = "comment";
				ospan.innerHTML = '<img src="comment.png">'+data["article"]["comment_count"];
				oLi.querySelector(".content").appendChild(ospan);
			}
			me._bindEvent(oLi);//渲染完了以后给元素绑定事件
		});
	}	
}

function ajaxData(type,url,callback){
	var oAjax = null;
	if(window.XMLHttpRequest){
	    oAjax = new XMLHttpRequest();
	}else{
	    oAjax = new ActiveXObject('Microsoft.XMLHTTP');
	}
	oAjax.onreadystatechange=function(){
		if(oAjax.readyState==4 && oAjax.status==200){
			var data=JSON.parse(oAjax.responseText);
			callback(data);
		}
	}
	oAjax.open(type, url, true);
	oAjax.send();			
}
function insertContent(data,mid,fsize,source){//传递过来数据
	var zhti=new ZhuanTi(data);
}
if(KGlobal.kindDevice=="ios"){//如果是ios调用bbhasloaded方法
	callDevice("loadfinished",[],function(){});
}