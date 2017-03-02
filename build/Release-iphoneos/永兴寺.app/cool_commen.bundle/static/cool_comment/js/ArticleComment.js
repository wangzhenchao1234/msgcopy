$(function(){
   
});
var $attach_layer;
function SetCommentBodyMaxHeigh()
{
	 
	var height=$(window).height()/3;
	var linHeight=parseInt($(".commnet_content").css("line-height"));//.replace("px","");
	height-= height%linHeight;
		$(".commnet_content p").css({maxHeight:height+"px"});
}
function SetServerAddress(serverAdrress)
{
	ServerAdrress=serverAdrress;
}

function LoadCoolComment()
{
	 getChannel_id();
	 InitEmotionKeyValue();
	 GetCoolComment();
	  
}

function LoadArticleComment(articleId)
{
	 
	 InitEmotionKeyValue();
	 GetArticleComment(articleId)
	  
}
var ServerAdrress="";
function LoadComment(comment)
{
	// if($("#attach_layer").css("display")!="none")
	//{
		 
	//	$("#attach_layer").hide();
	//	$("#comment_content").show();
	//	 $(document).scrollTop(scrooTop); 
	//	 SendMessageToDevice("canRefresh","true");
		 
		
	//}
	GoBack();
	    var data=comment;
	 
     	if($("#comment_content").length==0)
     	 {
     	 	InitEmotionKeyValue();
     	 	$body=$("<div id='comment_content'> </div>");
     	 	$body.insertBefore( $("#attach_layer"));
     	}
     	 $("#no_comment").hide();
	     InserArticleCommentToPage(data,true,true);
	    
	   
     	 $("#LoaderLayer").css({"display":"none"});
     	 $("#comment_content").css({"display":"block"});
         	 $("html, body").animate({ scrollTop: scrooTop+"px" },200);
} 
 function GetArticleComment(comment)
 {
 	 
 	// var geturl=ServerAdrress+ "/iapi/article/"+articleId+"/comment/";
    //  	 
    // $.ajax(
     // {url:geturl,type:"GET",dataType:"JSONP",success:function(data,status)
     // {
     	//加载前 清楚 comment_content
     	 if( $("#comment_content").length>0)
     	 {
     	 	$("#comment_content").remove();
     	 }
     	
     	 var data=comment;
     	 $body=$("<div id='comment_content'> </div>");
     	 if(data.length==0)
     	 {
     	  var $no_comment=	$("<div id='no_comment' style='  position:absolute;top:50%; left:50%; margin-left:-105px;   margin-top:-50px;' >还没评论，立即评论你就是楼主</div>");
     	   
     	  $no_comment.insertBefore( $("#attach_layer"));
     	 }else{
     	for (var i=0; i < data.length; i++) {
     	 
		    InserArticleCommentToPage(data[i],false);
		 };
		 }
     	  $("#LoaderLayer").hide();
     	 	$body.insertBefore( $("#attach_layer"));
     	 	$("#comment_content").show();

     	  LayoutByDeviceSize();
     	  SetCommentBodyMaxHeigh();
     	  $(".commnet_content p").each(function(){
     	 	var allHeight=parseInt($(this).get(0).scrollHeight);
     	 	var maxHeight=parseInt($(this).css("max-height"));
     	 	if(allHeight>maxHeight){
     	 		$(this).parent("div").append($("<p style='float:right; margin-right:0.5em; color:#B5B5B6; font-size:12px;'  >显示更多</p>"));
     	 	}
     	 });
     // }
     // }
    // );
 	
 }
 
 var $body;
function GetCoolComment()
{
    var geturl=ServerAdrress+ "/iapi/coolcomment/"+$channel_id;
    $.ajax(
     {url:geturl,type:"GET",success:function(data,status)
     {
     	 $body=$("<div id='comment_content'> </div>");
     	for (var i=0; i < data.length; i++) {
		    InserCommentToPage(data[i]);
		 };
		
		   $("#LoaderLayer").hide();
     	 	$body.insertBefore( $("#attach_layer"));
     	 	$("#comment_content").show();

     	  LayoutByDeviceSize();
     	 SetCommentBodyMaxHeigh();
     	  $(".commnet_content p").each(function(){
     	 	var allHeight=parseInt($(this).get(0).scrollHeight);
     	 	var maxHeight=parseInt($(this).css("max-height"));
     	 	if(allHeight>maxHeight){
     	 		$(this).parent("div").append($("<p style='float:right; margin-right:0.5em; color:#B5B5B6; font-size:12px;'  >显示更多</p>"));
     	 	}
     	 });
     }
     }
    );
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
var scrooTop;
function InserArticleCommentToPage(data,isFrist,isNew)
{
	
	 

	
	 //生成user info 部分
 
        var user_name=data["master"]["username"];
 
	var head_photo= GetUserHeadPhoto(data,user_name);
            
	 	  $.data($("#DataPool"),data["id"].toString(),data);
		//$("#DataPool").data(data["id"],data);
 
      

	 var ctime =getDate(data["ctime"]);
	 if(isNew){
	 	var dNow=new Date();
		var minu=dNow.getMinutes();
		if(minu<10){
			minu="0"+minu;
		}
		var hour=dNow.getHours();
		if(hour<10){
			hour="0"+hour;
		}
	 	ctime=hour+":"+minu;
	 }
	  var user_first_name=data["master"]["first_name"];
	 var content=data["content"];
        
	 content=ParseEmotion(content,true);
         
	 var isShowAttachBtn=SetAttatchButton(data);
	  
	 $comment_body=$("<div class='comment_body'> </div>");
	 
	 
	 //生成  tool box
	if(isShowAttachBtn)
	{
		 $right_tool=$("<div class='right_tool'> </div>")
	     
	     .attr("Data-tag",data["id"]);
	       var images=data["images"];
		   var videos=data["videos"];
		   var audios=data["audios"];
	       var attachs=data["attachs"];
		   var baseUrl=GetStaticUrl(); 
	       if(images.length>0) $right_tool.append($("<img  style='width:16px; float:right; margin:3px; position:relative;right:0px' src='"+baseUrl+"cool_comment/image/image.png'></img>"));
		   if(audios.length>0)  $right_tool.append($("<img style='width:16px; float:right;margin:3px;'position:relative;right:0px src='"+baseUrl+"cool_comment/image/audio.png'></img>"));
		   if(videos.length>0)  $right_tool.append($("<img  style='width:16px; float:right;margin:3px;position:relative;right:0px' src='"+baseUrl+"cool_comment/image/video.png'></img>"));
		   if(attachs.length>0)r$right_tool.append($("<img  style='width:16px; float:right;margin:3px;position:relative;right:0px' src='"+baseUrl+"cool_comment/image/attach.png'></img>"));
	    
    }
	 
	  
	 $user_info=$("<div class='user_info'><div style='  box-shadow:2px 2px 3px #aaaaaa; border-width:0x;   padding:2px;    float:left;' ><img class='head_photo'   src='"+head_photo+"'/> </div> <span class='user_info_detail'> "+user_first_name+"</span><span class='user_info_detail_titme'> "+ctime+"</span></div>")
	
	 $comment_content=$("<div class='commnet_content'><p style='max-height:3em;'>"+content+"</p></div>")
	 
	 //$comment_body.append($comment_head);
	 $comment_body.attr("Data-tag",data["id"]);
	 
	 var $pheight=$(".commnet_content p").height();
	 if($pheight>$(".commnet_content").css("max-height") )
	 {
	 	//加入  查看更多
	 	var $more=$("<a>查看更多</a>");
	 	$(".commnet_content").append($more);
	 }
	
	 $comment_body.append($user_info);
    
    $user_info.find('img').click(function(event){
                                 SendMessageToDevice("showuser",user_name);
                                 event.stopPropagation()
                                 });
    
	 $comment_body.append($comment_content);
	  if(isShowAttachBtn)
	 $comment_body.append($right_tool);
    
    
	 $comment_body.click(function()
	 {
	 	SendMessageToDevice("canRefresh","false");
	 	 
	 	  scrooTop= $(document).scrollTop(); 
	 	 // $("#comment_content").css({position:"relative",left:0+"px",display:"block",maxHeight:$(document).height()})
	 	 // .animate({left:-$(document).width()+'px'},500);
	 	 var commentHtml=$(this).html();
	 	 var $attach_layer =$("#attach_layer");
	 	 
	 	 $("#attach_comment_layer").html($(commentHtml));
      
	 	 var dataId=$(this).attr("Data-tag").toString();
         var comment= data;
	    // var comment= $.data($("#DataPool"),dataId);
	     
	     
	     SetImags(comment);
	     SetVideos(comment);
	     SetAudios(comment);
	     SetAttach(comment);
	     scrooTop= $(document).scrollTop(); 
	     
	      $("#comment_content").css({position:"relative",left:0+"px",display:"block",maxHeight:$(window).height()})
	 	 .animate({left:-$(window).width()+'px'},300 );
	      $attach_layer.css({top:scrooTop+"px",left:$(window).width(),right:-$(window).width(),display:"block",minHeight:$(window).height()});
	      $attach_layer.animate({left:"0px",right:"0px"},300,function(){
	        $("#comment_content").css({display:"none"});
	        $(document).scrollTop(0); 
	         $attach_layer.css({top:0+"px"});
        //$attach_layer.swipe({swipeRight:function(event, direction, distance, duration, fingerCount){
	   	 //if(direction=="right"&&distance >100)
	   	 //{
	   	 //	GoBack();
	   	 //}
	 
	   	  
	     //}});
	       });
	    
	 	  // $attach_layer.animate({left:'0px'},300,function(){
        
      
	 	  // });//菜单块向右移动 r $head=$("#attach_comment_layer   .head_photo");
	 	  var $tool=$("#attach_comment_layer   .right_tool").hide(); 
	 	   var $tool=$("#attach_comment_layer   .comment_head").hide(); 
	 	   var $tool=$("#attach_comment_layer   a").hide(); 
	 	   var comment_content=comment["content"];
	 	  comment_content= ParseEmotion(comment_content,false);
	 	  
	 	      $("#attach_comment_layer   .commnet_content").html(comment_content);
	 	    var $tool=$("#attach_comment_layer   .commnet_content").css({maxHeight:'1000em'});
	 	     var $tool=$("#attach_comment_layer   .commnet_content p").css({maxHeight:'1000em'});
	 	  $("#attach_comment_layer   .user_info_detail").css({color:"#2da7e0",fontSize:"14px",top:"5px"});
	 	  $("#attach_comment_layer   .user_info_detail_titme").css({color:"#717070",fontSize:"10px",top:"5px"});
	 	  
	 	// $head.animate({height:"+=8px",width:"+=8px"},300);
	 });
	 if(!isFrist)
	 $body.append($comment_body);
	 else
	 $body.prepend($comment_body); 
	 LayoutByDeviceSize();
	 
	 return $comment_body;
	 
}

function InserCommentToPage(data)
{
	 $.data($("#DataPool")[0],data["id"].toString(),data);
      
	 var ctime =getDate(data["comment"]["ctime"]);
	 var pubId=data["publication"]["id"];
	 var source=data["publication"]["leaf"]["title"];
	 var art_title=data["comment"]["article"]["title"];
	 
	 var user_name=data["comment"]["master"]["username"];
	 var comment_id=data["comment"]["id"];
	 var user_first_name=data["comment"]["master"]["first_name"];
	 var content=data["comment"]["content"];
	 content=ParseEmotion(content,true);
	 var isShowAttachBtn=SetAttatchButton(data["comment"]);
	  
	  
      
	  
	// $body=$("#comment_content");
	 
	 $comment_body=$("<div class='comment_body'> </div>");
	 
	 //生成 comment titile部分
	 $comment_head=$("<div class='comment_head' ></div>")
	 .click(function(){
	 SendMessageToDevice("showPub",pubId);
	 event.stopPropagation();
	 	
	 })
	 .append($("<span>【</span>"))
	 .append($("<span>"+source+"</span>"))
	 .append($("<span>】</span>"))
	 .append($("<span></span>").text(art_title));
	 
	 //生成  tool box
	if(isShowAttachBtn)
	{
		 $right_tool=$("<div class='right_tool'> </div>")
	     
	       .attr("Data-tag",data["id"]);
	       var images=data["comment"]["images"];
		   var videos=data["comment"]["videos"];
		   var audios=data["comment"]["audios"];
	       var attachs=data["comment"]["attachs"];
	         
		   var baseUrl=GetStaticUrl();
	       if(images.length>0) $right_tool.append($("<img style='width:16px;'  class='attach_image' src='"+baseUrl+"cool_comment/image/image.png'></img>"));
		   if(audios.length>0)  $right_tool.append($("<img style='width:16px;' class='attach_image'  src='"+baseUrl+"cool_comment/image/audio.png'></img>"));
		   if(videos.length>0)  $right_tool.append($("<img style='width:16px;'  class='attach_image'  src='"+baseUrl+"cool_comment/image/video.png'></img>"));
		   if(attachs.length>0) $right_tool.append($("<img  style='width:16px;'  class='attach_image'  src='"+baseUrl+"cool_comment/image/attach.png'></img>"));
	    
    }
	 //生成user info 部分
	 $user_info=$("<div class='user_info'><div style='box-shadow:0px 0px 5px 0px #aaaaaa;border-radius:2px; border-width:0x;   padding:1px;    float:left;' ><img class='head_photo'   src='"+GetUserHeadPhotoOnline(user_name)+"'/> </div> <span class='user_info_detail'> "+user_first_name+"</span><span class='user_info_detail_titme'> "+ctime+"</span></div>")
	
	 $comment_content=$("<div   class='commnet_content'><p style='overflow:hidden;' >"+content+"</p></div>");
	    
	   
	     
	 $comment_body.append($comment_head);
	 
	 
	 $comment_body.attr("Data-tag",data["id"]);
	
	 $comment_body.append($user_info);
	 $comment_body.append($comment_content);
	  if(isShowAttachBtn)
	 $comment_body.append($right_tool);
	 $comment_body.click(function()
	 {
	 	 scrooTop= $(document).scrollTop(); 
	 	 //$("#comment_content").hide();
	 	 var commentHtml=$(this).html();
	 	 var $attach_layer =$("#attach_layer");
	 	 
	 	 $("#attach_comment_layer").html($(commentHtml));
      
	 	 var dataId=$(this).attr("Data-tag").toString();
	     var comment= $.data($("#DataPool")[0],dataId);
	     
	   
	 	 SetImags(comment["comment"]);
	     SetVideos(comment["comment"]);
	     SetAudios(comment["comment"]);
	     SetAttach(comment["comment"]);
	     
	 	 scrooTop= $(document).scrollTop(); 
	     
	      $("#comment_content").css({position:"relative",left:0+"px",display:"block",maxHeight:$(window).height()})
	 	 .animate({left:-$(window).width()+'px'},300 );
	      $attach_layer.css({top:scrooTop+"px",left:$(window).width(),right:-$(window).width(),display:"block",minHeight:$(window).height()});
	      $attach_layer.animate({left:"0px",right:"0px"},300,function(){
	        $("#comment_content").css({display:"none"});
	        $(document).scrollTop(0); 
	         $attach_layer.css({top:0+"px"});
	      	 $(this).swipe({swipeRight:function(event, direction, distance, duration, fingerCount){
	   	 if(direction=="right"&&distance >100)
	   	 {
	   	 	GoBack();
	   	 } 
	 
	   	  
	     }});
	       });
	     
	     // $("html, body").animate({ scrollTop: "0px" },200,function(){
// 	     	 
// 	     	
	     // });
	 	 var $head=$("#attach_comment_layer   .head_photo");
	 	  var $tool=$("#attach_comment_layer   .right_tool").hide(); 
	 	   var $tool=$("#attach_comment_layer   .comment_head").hide(); 
	 	   var $tool=$("#attach_comment_layer   a").hide(); 
	 	   var comment_content=comment["comment"]["content"];
	 	  comment_content= ParseEmotion(comment_content,false);
	 	      $("#attach_comment_layer   .commnet_content").html(comment_content);
	 	    var $tool=$("#attach_comment_layer   .commnet_content").css({maxHeight:'1000em'});
	 	     var $tool=$("#attach_comment_layer   .commnet_content p").css({maxHeight:'1000em'});
	 	  $("#attach_comment_layer   .user_info_detail").css({color:"#2da7e0",fontSize:"14px",top:"5px"});
	 	  $("#attach_comment_layer   .user_info_detail_titme").css({color:"#717070",fontSize:"14px",top:"5px"});
	 	  
	 	 //$head.animate({height:"+=8px",width:"+=8px"},300);
	 });
	 
	 $body.append($comment_body);
	  
	
	 
}
 
//解析评论内容中的表情字符
function ParseEmotion(content,ishasoldcontent)
{
	  if(ishasoldcontent)
	  content=commentShow(content);
	  var reg=/\[.*?\]/g;
      var data=content.match(reg);
 	  if(data!=null)
       for (var i=0; i < data.length; i++) {
       	 var url=GetStaticUrl();
         var emotionUlr=url+"cool_comment/Emotion/"+$.data($("#DataPool")[0],data[i])+".png";
         var img="<img class='emotion' src='"+emotionUlr+"'/>";
           content= content.replace(data[i],img );
 		 }; 
 		 if(content=="(null)")content="内容更精彩，用力戳我哦";
	return content;
}
 

function InitEmotionKeyValue()
{
	 SetKeyValue("[微笑]","e1");    SetKeyValue("[大笑]","e2");    SetKeyValue("[可爱]","e3");  SetKeyValue("[惊讶]","e4");
	 SetKeyValue("[耍帅]","e5");    SetKeyValue("[暴怒]","e6");    SetKeyValue("[羞涩]","e7");  SetKeyValue("[汗]","e8");
	 SetKeyValue("[悲伤]","e9");    SetKeyValue("[黑线]","e10");   SetKeyValue("[鄙视]","e11");  SetKeyValue("[哀怨]","e12");
	 SetKeyValue("[赞]","e13");    SetKeyValue("[财迷]","e14");   SetKeyValue("[疑问]","e15");  SetKeyValue("[腹黑]","e16");
	 SetKeyValue("[恶心]","e17");   SetKeyValue("[好奇]","e18");   SetKeyValue("[委屈]","e19");  SetKeyValue("[喜欢]","e20");
	 SetKeyValue("[无奈]","e21");   SetKeyValue("[窃喜]","e22");   SetKeyValue("[尴尬]","e23");  SetKeyValue("[卖萌]","e24");
	 SetKeyValue("[坏笑]","e25");   SetKeyValue("[奸笑]","e26");   SetKeyValue("[大汗]","e27");  SetKeyValue("[无辜]","e28");
	 SetKeyValue("[酣睡]","e29");   SetKeyValue("[泪奔]","e30");   SetKeyValue("[愤怒]","e31");  SetKeyValue("[大惊]","e32");
	 SetKeyValue("[喷]","e33");    SetKeyValue("[爱心]","e34");   SetKeyValue("[心碎]","e35");  SetKeyValue("[献花]","e36");
	 SetKeyValue("[礼物]","e37");   SetKeyValue("[彩虹]","e38");   SetKeyValue("[月亮]","e39");  SetKeyValue("[太阳]","e40");
	 SetKeyValue("[金钱]","e41");   SetKeyValue("[灯泡]","e42");   SetKeyValue("[咖啡]","e43");  SetKeyValue("[蛋糕]","e44");
	 SetKeyValue("[音乐]","e42");   SetKeyValue("[灯泡]","e43");   SetKeyValue("[咖啡]","e44");  SetKeyValue("[蛋糕]","e45");
	 SetKeyValue("[爱你]","e46");   SetKeyValue("[胜利]","e47");   SetKeyValue("[很棒]","e48");  SetKeyValue("[弱]","e49");
	 SetKeyValue("[OK]","e50");
}
function SetKeyValue(key,value)
{
	$.data($("#DataPool")[0],key,value);
}

var isShowLargeImage=false;
var $currentFancyBoxItem;
function SetImags(comment)
{
	if( comment["images"].length==0)
	{
		$("#images_list").hide();
	}
	else
	{
	    $("#images_list").show();
	    $("#images_list").empty();
	    $("#images_list").append($("<div style='color:gray;font-size:15px;'></div>"));
	     var width=( $("#images_list").width()/3-15);
	    
	    for (var i=0; i < comment["images"].length; i++) {
	    	 
	    	var url=comment["images"][i]["obj"]["url"];
	                var $img1=$("<img style='width: 100%;'    src='"+url+"' />").load(function(){
	                	// $(this).parent().css({height:$("#images_list").width()/4*2.5+"px"});
	                });
	               var $div=$("<div style='overflow :hidden;display:inline-block;' > </div>");
	               $div.append($img1);
	                
	               var $img=$("<div class='grouped_elements' style='margin-top:10px;margin-bottom:10px;' rel='group1' href='"+url+"' ></div>");
	               $img.append($div);
			    // $img.click((function(k){
			    	// return function(){
			    		// try	
			    		// {
// 			    			
			    			// $currentFancyBoxItem= $(this).fancybox(
			    			 	// {
			    			 		// 'centerOnScroll':true,
			    			 		 // 'transitionIn'	:	'elastic',
									// 'transitionOut'	:	'elastic',
										// 'speedIn'		:	600, 
										// 'speedOut'		:	200,
										// 'onClosed':function(){
											 // isShowLargeImage=false;
										// }
			    			 	// }
			    			 // );
			    			 // isShowLargeImage=true;
			            // } 
			            // catch(err){alert(err);}
			            // finally { return false;}
			    	// }
			    // })(i));
			    $("#images_list").append($img); 
			 };
	}
}
 

var originImage=new Image();
function GetImageWidth(oImage)
{
if(originImage.src!=oImage.src) originImage.src=oImage.src;
return originImage.width;
}
function GetImageHeight(oImage)
{
if(originImage.src!=oImage.src) originImage.src=oImage.src;
return originImage.height;
}

function SetVideos(comment)
{
	if( comment["videos"].length==0)
	{
		$("#video_list").hide();
		 
	}
	else
	{
	    $("#video_list").show();
	    $("#video_list").empty();
	    $("#video_list").append($("<div style='color:gray;font-size:15px;'></div>"));
	    var width=( $("#video_list").width()/3-15);
	    width=75;
	    for (var i=0; i < comment["videos"].length; i++) {
	            var url=comment["videos"][i]["thumbnail"]; 
	            var paly_icon=GetStaticUrl()+"cool_comment/image/play.png";
	            var $play=$("<img  style='position:absolute; top:50%;left:50%; margin-left:-15px;margin-top:-15px; width:46px;height:46px;'  src='"+paly_icon+"' />");
	            var $img1=$("<img style='width:100%;'    src='"+url+"' />").load(function(){
	            	 var width=  $(this).parent("div").width();
	            	 console.info(width);
	                $(this).parent().css({height:width/4*2.5+"px"});
	                });
	               var $div=$("<div style='position:relative;  overflow :hidden;' > </div>");
	               
	               $div.append($img1);
	               $div.append($play);
	               var $img=$("<div class='grouped_elements' style='margin-top:10px;margin-bottom:10px;' rel='group1' href='"+url+"' ></div>");
	               $img.append($div);
	             
	           // var $img=$("<img  style='margin-bottom:5px;margin-top:5px;margin-right:5px; width:"+width+"px;' src='"+url+"'></img>");
			    $img.click((function(k){
			    	return function(){
                            
			    		SendMessageToDevice("showVideo",comment["videos"][k]["obj"]["url"],true);
			    		 return false;
			    	}
			    })(i));
			    $("#video_list").append($img); 
			 };
	}
}
function SetAudios(comment)
{
	if( comment["audios"].length==0)
	{
		$("#audio_list").hide();
		 
	}
	else
	{
	    $("#audio_list").show();
	    $("#audio_list").empty();
	    $("#audio_list").append($("<div style='color:gray;font-size:15px;'></div>"));
	    var width=( $("#audio_list").width()/3-15);
	     width=75;
	    for (var i=0; i < comment["audios"].length; i++) {
	            var url=GetStaticUrl()+"cool_comment/image/audioPlay.png";
	               var $img=$("<div class='grouped_elements' style='margin-top:10px;margin-bottom:10px;' rel='group1'  > <img src='"+url+"' style='width:135px;' ></img></div>");
	               $img.click((function(k){
			    	return function(){
			    		
			    		SendMessageToDevice("showAudio",comment["audios"][k]["obj"]["url"],true);
			    		 return false;
			    	}
			    })(i));
			    $("#audio_list").append($img); 
			 };
	}
}
function SetAttach(comment)
{
	return;
	if( comment["attachs"].length==0)
	{
		$("#attach_list").hide();
		 
	}
	else
	{
	    $("#attach_list").show();
	    $("#attach_list").empty();
	    $("#attach_list").append($("<div style='color:gray;font-size:15px;'></div>"));
	    var width=( $("#attach_list").width()/3-15);
	     width=75;
	    for (var i=0; i < comment["comment"]["attachs"].length; i++) {
	            var url=GetStaticUrl();+"cool_comment/image/videos.png";
	         
	          
	           var $img=$("<img  style='margin-bottom:5px;margin-top:5px;margin-right:5px; width:"+width+"px;' src='"+url+"'></img>");
			    $img.click((function(k){
			    	return function(){
			    		SendMessageToDevice("showAttach",comment["comment"]["attachs"][k]["obj"]["url"],true);
			    		 return false;
			    	}
			    })(i));
			    $("#attach_list").append($img); 
			 };
	}
}

function SetAttatchButton(data)
{
	 
	var videos=data["videos"];
	var audios=data["audios"];
	var attachs=data["attachs"];
	if(data["images"].length>0)return true;
	if(data["audios"].length>0>0)return true;
	if(data["videos"].length>0>0)return true;
	if(data["attachs"].length>0>0)return true;
	return false;
}
function GetUserHeadPhotoOnline(username)
{
	var head= $.data($("#DataPool")[0],username);
	if(head!=null)
	return head;
	var headUrl="";
	var geturl=ServerAdrress+"/iapi/user/head/u/"+username+"/"+$channel_id;
	console.info("ajax begin");
	  $.ajax(
     {
     	url:geturl,
     	type:"GET",
     	async:false,
     	success:function(data,status)
     {
     	 
     	 headUrl= (data["head50"]);
     	  
     	  $.data($("#DataPool")[0],username,headUrl);
     	  
     	   return headUrl;
     	 
     },
     
     error:function(data,status)
     {
     	headUrl=  GetStaticUrl()+ "cool_comment/image/head50.jpg";
     	 
     }
     
     }
    );
     
     return headUrl;
}

function GetUserHeadPhoto(data, username)
{
	 try{
     return  data["master"]["get_profile"]["head"]["head50"];
}catch(err){return GetStaticUrl()+ "cool_comment/image/head50.jpg";}
}
//显示评论内容
function commentShow(data){
	var content;
	var reg=/<\/?[^>]*>/;
	var liuimg=/<\/?(?!img)[^>]*>/g;
	var liubq=/<\/?((?!emoticons\/)[^>])*>/;
	if(reg.test(data)){
		var qhtml=data.replace(liuimg,'');
		if(liubq.test(qhtml)){
			content='评论内容为富媒体形式，点击查看全部';
			 
			return content;
		}
		else{
			content=qhtml;
		 
			return content;
		}
	}
	else
	{
		 
		return data
	}
}



