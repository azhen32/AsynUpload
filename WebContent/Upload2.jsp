<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Insert title here</title>
<link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/webuploader.css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery-1.12.1.js"></script>
<script type="text/javascript" src="${pageContext.request.contextPath}/js/webuploader.js"></script>
<style type="text/css">
	#dndArea {
		width:200px;
		height:100px;
		border-color:red;
		border-style:dashed;
	}
</style>
</head>
<body>
	<div id="uploader">
		<!-- 用于拖拽文件 -->
		<div id="dndArea">
		
		</div>
		<!-- 用于显示文件列表 -->
		<div id="fileList"></div>
		<!-- 用于选择文件 -->
		<div id="filePicker">点击选择文件</div>
	</div>
	
	<script type="text/javascript">
		//文件的md5标记
		var fileMd5;
		//监听分块上传中的三个时间点
		WebUploader.Uploader.register({
			"before-send-file":"beforeSendFile",
			"before-send":"beforeSend",
			"after-send-file":"afterSendFile"
		}
		,{
			//时间点1:所有分块进行上传之前调用此函数  
			beforeSendFile:function(file) {
				//创建一个deffered对象
				var deferred = WebUploader.Deferred();
				//1.计算文件的唯一标记，用于断电续传和秒传，只计算文件前5M的md5值
				(new WebUploader.Uploader()).md5File(file,0,5 * 1024 * 1024)
					.progress(function(percentage) {
						$("#" + file.id).find("div.state").text("正在获取文件信息...");
					})
					.then(function(val) {
						fileMd5 = val;
						$("#" + file.id).find("div.state").text("成功获取文件信息");
						deferred.resolve();
					});
				//2.请求后台是否保存过该文件，如果存在，则跳过该文件，实现秒传功能
				
				return deferred.promise();
			},
			//时间点2：如果有分块上传，则每个分块上传之前调用此函数
			beforeSend:function(block) {
				//1.请求后台是否保存过当前分块，如果存在，则跳过该文件，实现点断续传功能
				//alert(uniqueFileTag);
				var deferred = WebUploader.Deferred();
				
				$.ajax({
					type:"POST",
					url:"${pageContext.request.contextPath}/UploadActionServlet?action=checkChunck",
					data:{
						fileMd5:fileMd5,
						chunk:block.chunk,
						chunkSize:block.end-block.start
					},
					dataType:"json",
					success:function(response) {
						if(response.ifExist) {
							deferred.reject();
						} else {
							deferred.resolve();
						}
					}
				});
				this.owner.options.formData.fileMd5 = fileMd5; 
				return deferred.promise();
			},
			//时间点3：所有分块上传成功之后调用此函数
			afterSendFile:function(file) {
				//1.如果分块上传，则通知后台合并所有分块文件
				$.ajax({
					type:"POST",
					url:"${pageContext.request.contextPath}/UploadActionServlet?action=mergeChunks",
					data:{
						fileMd5:fileMd5,
						fileName:file.name
					},
					success:function(response) {
						
					}
				});
			}
		});
		var uploader = WebUploader.create({
			//flash控件地址
			swf:"${pageContext.request.contextPath}/js/Uploader.swf",
			//后台提交地址
			server:"${pageContext.request.contextPath}/UploadServlet",
			//选择文件控件的标签
			pick:"#filePicker",
			//自动上传文件,不需要点击提交
			auto:true,
			//开启拖拽功能，制定拖拽区域
			dnd:"#dndArea",
			//屏蔽拖拽区域外的功能
			disableGlobalDnd:true,
			//开启粘贴功能
			paste:"#uploader",
			
			
			//分开上传设置
			//是否分块上传
			chunked:true,
			//每块文件的大小(默认5M)
			chunkSize:5 * 1024 * 1024,
			//开启几个并发线程(默认3个)
			threads:3,
			//在上传当前文件时，准备下一个文件
			prepareNextFile:true,
		});
		
		//2.选择文件后，文件信息队列展示
		//注册fileQueued事 件:当文件加入队列后触发
		uploader.on("fileQueued",function(file) {
			//追加文件信息div
			/*
			$("#fileList").append("<div id='" + file.id 
					+ "' + class='fileInfo'><span>" + file.name 
					+ "</span><div class='state'>等待上传...</div><span class='text'></span></div>");
			*/
			$("#fileList").append("<div id=" + file.id + "><img /><span>" + file.name + "</span><div><span class='percentage'></span></div><span class='state'></span</div>");
			//制造图片缩略图
			//error:制造缩略图失败
			//src：缩略图路径
			
			uploader.makeThumb(file,function(error,src){
				var id = $("#" + file.id);
				//如果失败，则显示“不能预览”
				if(error) {
					id.find("img").replaceWith("不能预览");
				}
				//成功，则显示缩略图到指定位置
				id.find("img").attr("src",src);
			});
			
		});
		
		//3.注册上传进度监听
		//file：正在上传的文件
		//percentage:当前进度的比例。最大为1。
		uploader.on("uploadProgress",function(file,percentage) {
			$("#" + file.id).find("span.percentage").text(Math.round(percentage * 100) + "%");
			//var id = $("#" + file.id);
			//更新状态信息
			//id.find("div.state").text("上传中...");
			//更新上传百分比
			//id.find("span.text").text(Math.round(percentage * 100) + "%");
		});
		//4.注册上传完毕监听器
		//file:上传完毕的文件
		//response:后台会送的数据，以json格式返回
		/*
		uploader.on("uploadSuccess",function(file,response) {
			$("#" + file.id).find("div.state").text("上传完毕");
		});
		*/
	</script>
</body>
</html>