<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
</head>
<body>
	<form action="${pageContext.request.contextPath }/UploadServlet" method="post"  enctype="multipart/form-data">
		选择文件:<input type="file" name="name"><br/>
		描述信息:<input type="text" name="info"><br/>
		<input type="submit" name="提交">
	</form>
</body>
</html>