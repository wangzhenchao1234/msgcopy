评论 说明文档
1、个客户端加载的时候需要注入cookie 以及相应的渠道号
2、客户端需要向webcontrol注入一个名字为 external的对象并且实现如下接口：
	方法  
	 LoadCoolComment():void 方法来调用酷评相关功能
	 LoadArticleComment(articleId):void 加载 article的评论
 	 LoadComment(commentId):void;将id 为commentId 评论 加到列表顶端
 	 GoBack():bool  当为true的时候 客户端 需要 处理关闭webview 等等事件。如果为false 则 模板自己处理
     SetServerAddress(serverAddress):void 设置服务器地址   SetServerAddress("http://iapi.msgcopy.net");
	事件(接口)
	showPub(publication_id); 显示特定id的 publication
	showPic(img_url);    显示图片
	showVideo(video_url); 播放视频
	showAudio(audio_url); 播放音频
	showAttach(attach_url); 打开附件
3、JS 于objc 互调 规范
  		 协议标志为：-msgprotocol-
 		参数分隔符：-msgarg-
 		例：showVideo -msgprotocol- http://a.mp4 -msgarg- http://b.mp4  
        js 以重定向的方式调用 objc window。location.herf的值为  以上字符串，需要objc 解析