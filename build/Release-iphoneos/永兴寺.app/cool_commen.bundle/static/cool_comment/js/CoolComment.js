$(function(){
	   
	 
	    
	  AddEventHander();
	  
});

var $loader ;
 
 
function AddTestData()
{
	var $comment1=$(".comment_body");

	   
}

function AddEventHander()
{
	$("#topBar").click(function(){return false;});
	$("#go_back").click(function(){
		$("#attach_layer").hide();
	 		$("#comment_content").show();
	});
	 $(".commnet_content").toggle(StretchCommentContent, CloseCommentContent);
	 	$("#attach_layer").click(function(){
	 		  
	 	});
	// $(document).ajaxError(function(){
	// 	onLoadError();
	// 	$error_div = $("<div style='text-align:center;'> <div style='margin-right: auto;margin-left: auto;vertical-align:middle;line-height:"+$(document).height()+"px;'>网络不给力啊，点击重新加载！</div></div>")
	// 	.click(function(){
	// 		location.reload();
	// 	});
	// 	 $("body").empty()
	 //	 .append($error_div);
	 	 
	// });
}

function StretchCommentContent()
{
	$(this).animate({"max-height":$(this).get(0).scrollHeight},200);
}

function CloseCommentContent()
{
	$(this).animate({"max-height":"3em"},200);
}

function LayoutByDeviceSize(){
	 
	$height=$(window).height();
	$widht=$(window).width();
	if($widht > 500)
	{
		 SetLargeDeviceStyle();
	}
	 
}

function SetLargeDeviceStyle()
{ 
	$(".head_photo").css({"height":"30px","width":"30px"});
	//$(".user_info_detail").css({"top":"10px"});
	$("body").css("font-size","20px");
	$(".comment_head").css({"font-size":"16px"});
	$(".user_info_detail").css({"font-size":"15px"});
	$(".user_info_detail_titme").css({"font-size":"15px"});
}

 
