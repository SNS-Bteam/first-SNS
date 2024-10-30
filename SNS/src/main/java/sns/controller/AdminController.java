package sns.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import sns.util.DBConn;
import sns.vo.BoardVO;
import sns.vo.UserVO;

public class AdminController {
	public AdminController(HttpServletRequest request
			, HttpServletResponse response
			, String[] comments) throws ServletException, IOException {
		
		if(comments[comments.length-1].equals("blackList.do")) {
			blackList(request,response);
		}else if(comments[comments.length-1].equals("complainList.do")) {
			complainList(request,response);
		}else if (comments[comments.length-1].equals("loadComplain.do")) {
			loadComplain(request,response);
		}else if (comments[comments.length-1].equals("complainAdd.do")) {
			complainAdd(request,response);
		}else if (comments[comments.length-1].equals("stopUser.do")) {
			if(request.getMethod().equals("POST")) {
				stopUser(request,response);
			}
		}
	}
		
	public void blackList (HttpServletRequest request
			, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;

		try{
			conn =DBConn.conn();
			//������ ��¿� �ʿ��� �Խñ� ������ ��ȸ ���� ����
			
			// complaint_board �Ű� �Խ���   date_format(b.rdate,'%Y-%m-%d') as rdate" 
			
			// �������� �� �� �����ؾ��� >> complaint_board c�� �ۼ��ϸ� sql���� ������ �߻���
			String sql =" SELECT u.*, c.*,  "
					// �Ű� Ƚ���� ���ϱ� ���� ���� 
					   + "( select count(*) from complaint_board c2 where c2.bno = b.bno ) as cnt"
					   +" 	FROM complaint_board c "
					   +"   INNER JOIN board b "
					   +" 	ON c.bno = b.bno "
						+"   INNER JOIN user u "
						+" 	ON b.uno = u.uno ";
			psmt = conn.prepareStatement(sql);
			rs = psmt.executeQuery();
			UserVO vo = new UserVO();
			while(rs.next()){
				vo.setUnick(rs.getString("unick"));
				vo.setUemail(rs.getString("uemail"));
				vo.setUrdate(rs.getString("urdate"));
				vo.setDeclaration(rs.getInt("cnt"));
				vo.setUstate(rs.getString("ustate"));
				vo.setCpno(rs.getInt("cpno"));
				vo.setUno(rs.getString("uno"));
				}
			request.setAttribute("vo", vo);
			// board �ۼ��� 
			request.getRequestDispatcher("/WEB-INF/admin/blackList.jsp").forward(request, response);
		}catch(Exception e){
			e.printStackTrace();
		}finally {
			try {
				DBConn.close(rs,psmt, conn);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
	}
	
	public void complainList (HttpServletRequest request
			, HttpServletResponse response) throws ServletException, IOException {
		request.getRequestDispatcher("/WEB-INF/admin/complainList.jsp").forward(request, response);
	}
		
		
	public void loadComplain(HttpServletRequest request
			, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		
		String bno = request.getParameter("bno");
		String uno = "0";
		String state = "D";
		
		HttpSession session = request.getSession();
		if(session.getAttribute("loginUser") != null){
			UserVO user = (UserVO)session.getAttribute("loginUser");
			uno = user.getUno();
		}
		System.out.println("loadComplain ���� bno ��: " + bno + ", uno : " + uno);
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		
		try {
		    conn = DBConn.conn();

		    // ����ڰ� �� �Խù��� ��õ�ߴ��� Ȯ��
		    String sql = "select * from COMPLAINT_BOARD where uno = ? and bno = ?";
		    System.out.println("sql checkComplain: "+sql);
		    psmt = conn.prepareStatement(sql);
		    psmt.setString(1, uno);
		    psmt.setString(2, bno);
		    
		    rs = psmt.executeQuery();
		    
		    if(rs.next()) {
		    	state = "E";
		    }
		    
		    request.setAttribute("state", state);
		    request.setAttribute("bno", bno);
			request.getRequestDispatcher("/WEB-INF/admin/loadComplain.jsp").forward(request, response);

		} catch (Exception e) {
		    e.printStackTrace();
		} finally {
		    try {
				DBConn.close(rs, psmt, conn);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	public void complainAdd(HttpServletRequest request
			, HttpServletResponse response) throws ServletException, IOException {
		request.setCharacterEncoding("UTF-8");
		HttpSession session = request.getSession();
		UserVO user = (UserVO)session.getAttribute("loginUser");
		String uno = user.getUno();
		String bno = request.getParameter("bno"); 

		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;
		String sql = "";


		try {
		    conn = DBConn.conn();

		    sql = "select * from COMPLAINT_BOARD where uno = ? and bno = ?";
		    psmt = conn.prepareStatement(sql);
		    psmt.setString(1, uno);
		    psmt.setString(2, bno);

		    rs = psmt.executeQuery();

		    if (rs.next()) {
		        // �Ű� �̹� �����ϸ� delete
		    	sql = "delete from COMPLAINT_BOARD where uno = ? and bno = ?";
		        psmt = conn.prepareStatement(sql);
		        psmt.setString(1, uno);
		        psmt.setString(2, bno);
		    } else {
		        // �Ű� ������ insert
		        sql = "insert into COMPLAINT_BOARD (uno, bno) values (?, ?)";
		        psmt = conn.prepareStatement(sql);
		        psmt.setString(1, uno);
		        psmt.setString(2, bno);
		    }
		    psmt.executeUpdate();

		} catch (Exception e) {
		    e.printStackTrace();
		} finally {
		    try {
				DBConn.close(rs, psmt, conn);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}

	public void stopUser (HttpServletRequest request
			, HttpServletResponse response) throws ServletException, IOException {
		// ���ڵ� 
		request.setCharacterEncoding("UTF-8");
		
		//uno�� vo ��ü���� String���� ���� �Ǿ��ֱ� ������ 
		String uno = request.getParameter("uno");
		String ustate = request.getParameter("ustate");
		PrintWriter out = response.getWriter();
		// �ʿ��� ���� uno�� ustate �� �� �ϳ��� null�ΰ�� error�� �˷��ְ� return���� ���� ���� ��Ŵ
		if(uno == null || ustate == null) {
			out.print("error");
			return;
		}
		int unoInt = Integer.parseInt(uno);
		System.out.println(uno);
		
		Connection conn =null;
		PreparedStatement psmt = null;
		
		try {
			conn = DBConn.conn();
			String sql = "";
			// ajax���� ���ΰ�ħ ����� ������, �׿� ���� if���� �־�, ���ǿ� �°� ȸ���� ���¸� ������ �� ����
			if(ustate.equals("E")) {
				sql += "UPDATE user set ustate = 'D' WHERE uno = ?";
			}else {
				sql += "UPDATE user set ustate = 'E' WHERE uno = ?";
			}
			psmt = conn.prepareStatement(sql);
			psmt.setInt(1,unoInt);
			psmt.executeUpdate();
		
			response.setContentType("text/html;charset=UTF-8");
			out.print("success");  
			out.flush();
			out.close();   
			
		}catch(Exception e){
			e.printStackTrace();
			response.setContentType("text/html;charset=UTF-8");
			out.print("error");  
			out.flush();
			out.close();
		}finally {
			try {
				DBConn.close(psmt, conn);
			} catch (Exception e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
		}
		
		
	}



}
