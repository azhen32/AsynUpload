package cc.az;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FileUtils;

/**
 * Servlet implementation class UploadServlet
 */
@WebServlet(
		description = "文件上传Servlet", 
		urlPatterns = { "/UploadServlet" }, 
		initParams = { 
				@WebInitParam(name = "name", value = "upload", description = "上传")
		})
public class UploadServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadServlet() {
        super();
    }

 
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		//1.创建DiskFileItemFactory对象,配置缓存信息
		DiskFileItemFactory factory = new DiskFileItemFactory();
		//2.创建ServletFileUpload对象
		ServletFileUpload sfu = new ServletFileUpload(factory);
		//3.设置文件名编码
		sfu.setHeaderEncoding("utf-8");
		//4.开始解析文件
		String fileMd5 = null;
		//文件分块的索引
		String chunk = null;
		try {
			List<FileItem> fileItems = sfu.parseRequest(request);
			//5.获取文件信息
			for(FileItem item : fileItems) {
				//6.判断是否是文件类型
				if(item.isFormField()) { 
					//普通数据
					String fieldName = item.getFieldName();
					if(fieldName.equals("info")) {
						String info = item.getString("utf-8");
						System.out.println(info);
					}
					if(fieldName.equals("fileMd5")) {
						fileMd5 = item.getString("utf-8");
						System.out.println(fileMd5);
					}
					if(fieldName.equals("chunk")) {
						chunk = item.getString("utf-8");
						System.out.println(chunk);
					}
				} else {
					//文件数据
					/*普通上传
					String fileName = item.getName();
					InputStream is = item.getInputStream();
					FileUtils.copyInputStreamToFile(is, new File("/home/azhen" + File.separator + fileName));
					*/
					File file = new File("/home/azhen" + File.separator + fileMd5);
					//1.创建唯一目录
					if(!file.exists()) {
						file.mkdir();
					}
					//2.保存文件
					File chunkFile = new File("/home/azhen" + File.separator + fileMd5 + File.separator + chunk);
					FileUtils.copyInputStreamToFile(item.getInputStream(), chunkFile);
				}
			}
		} catch (FileUploadException e) {
			e.printStackTrace();
		}
	} 
}
