package cc.az;

import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class UploadActionServlet
 */
@WebServlet("/UploadActionServlet")
public class UploadActionServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public UploadActionServlet() {
        super();
        // TODO Auto-generated constructor stub
    }

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("utf-8");
		String action = request.getParameter("action");
		if(action.equals("mergeChunks")) {
			//合并文件
			String fileMd5 = request.getParameter("fileMd5");
			String fileName = request.getParameter("fileName");
			
			//读取目录里面的所有文件
			File f = new File("/home/azhen" + File.separator + fileMd5);
			File[] fileArray = f.listFiles(new FileFilter() {
				//排除目录，只要文件
				public boolean accept(File pathname) {
					if(pathname.isDirectory()) {
						return false;
					}
					return true;
				}
			});
			//转成集合，便于排序
			List<File> fileList = new ArrayList<File>(Arrays.asList(fileArray));
			//从小到大排序
			Collections.sort(fileList,new Comparator<File> () {
				public int compare(File o1,File o2) {
					if(Integer.parseInt(o1.getName()) < Integer.parseInt(o2.getName())) {
						return -1;
					}
					return 1;
				}
			});
			File outputFile = new File("/home/azhen" + File.separator + fileName);
			//创建文件
			outputFile.createNewFile();
			//输出流
			FileChannel outChannel = new FileOutputStream(outputFile).getChannel();
			//合并
			FileChannel inChannel;
			for(File file : fileList) {
				inChannel = new FileInputStream(file).getChannel();
				inChannel.transferTo(0, inChannel.size(), outChannel);
				inChannel.close();
				
				//删除分片
				file.delete();
			}
			//清除文件夹
			File tempFile = new File("/home/azhen" + File.separator + fileMd5);
			if(tempFile.isDirectory() && tempFile.exists()) {
				tempFile.delete();
			}
			
			System.out.println("合并成功");
		} else if(action.equals("checkChunck")) {
			 String fileMd5 = request.getParameter("fileMd5");
			 String chunk = request.getParameter("chunk");
			 String chunkSize = request.getParameter("chunkSize");
			 File checkFile = new File("/home/azhen" + File.separator + fileMd5 + File.separator + chunk);
			 
			 response.setContentType("text/html;charset=utf-8");
			 //检查文件是否存在，且大小是否一致
			 if(checkFile.exists() && checkFile.length() == Integer.parseInt(chunkSize)) {
				 response.getWriter().write("{\"ifExist\":1}");
			 } else {
				 response.getWriter().write("{\"ifExist\":0}");
			 }
		}
	}

}
