package sns.controller;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;

import sns.util.DBConn;
import sns.vo.CommentsVO;

public class CommentController {
	public CommentController(HttpServletRequest request, HttpServletResponse response, String[] comments)
			throws ServletException, IOException {

		if (comments[comments.length - 1].equals("view.do")) {
			commentWrite(request, response);
		} /*
			 * else if (comments[comments.length - 1].equals("commentsList.do")) {
			 * commentList(request, response); }
			 */
	}

	/*
	 * public void commentList(HttpServletRequest request, HttpServletResponse
	 * response) throws ServletException, IOException {
	 * 
	 * String bno = request.getParameter("bno"); Connection conn = null;
	 * PreparedStatement psmt = null; ResultSet rs = null;
	 * 
	 * try { String sqlComments = " SELECT c.*,u.unick,u.pname " +
	 * " FROM comments c " + " INNER JOIN user u " + " ON c.uno = u.uno " +
	 * " WHERE bno = ? " + " AND c.state = 'E' " + " ORDER BY c.rdate desc ";
	 * 
	 * psmt = conn.prepareStatement(sqlComments); psmt.setInt(1,
	 * Integer.parseInt(bno)); rs = psmt.executeQuery();
	 * 
	 * List<CommentsVO> clist = new ArrayList<CommentsVO>();
	 * 
	 * while (rs.next()) { CommentsVO cvo = new CommentsVO();
	 * cvo.setBno(rs.getInt("bno")); cvo.setUno(rs.getInt("uno"));
	 * cvo.setContent(rs.getString("content")); cvo.setRdate(rs.getString("rdate"));
	 * cvo.setState(rs.getString("state")); cvo.setPname(rs.getString("pname"));
	 * cvo.setUnick(rs.getString("unick")); clist.add(cvo); } // ������Ʈ�� ���
	 * request.setAttribute("comments", clist); } catch (Exception e) {
	 * e.printStackTrace(); } finally { try { DBConn.close(null, null, null); }
	 * catch (Exception e) { // TODO Auto-generated catch block e.printStackTrace();
	 * } }
	 * 
	 * }
	 */

	public void commentWrite(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		System.out.println("commentWrite ȣ��");

		// ������ Content-Type�� JSON���� ����
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");

		// �� ������ ��������
		int bno = Integer.parseInt(request.getParameter("bno"));
		int uno = Integer.parseInt(request.getParameter("uno"));
		String content = request.getParameter("content");

		// DB����
		Connection conn = null;
		PreparedStatement psmt = null;
		ResultSet rs = null;

		try {

			conn = DBConn.conn();

			String sql = " insert into comments (bno,uno,content)value(?,?,?); ";

			psmt = conn.prepareStatement(sql);
			psmt.setInt(1, bno);
			psmt.setInt(2, uno);
			psmt.setString(3, content);

			psmt.executeUpdate();

		} catch (Exception e) {
			e.printStackTrace();
		}

		// ��ݵ�ϵ� ��� ��ȣ�� db���� �޾ƿ´�
		int cno = 0;

		try {
			String sql = " select last_insert_id() as cno; ";

			psmt = conn.prepareStatement(sql);

			rs = psmt.executeQuery();

			if (rs.next()) {
				cno = rs.getInt("cno");
			}

		} catch (Exception e) {
			e.printStackTrace();
		}
		System.out.println("cno : " + cno);

		// ��۹�ȣ�� ��� ������ db���� �޾ƿ´�
		// ����� �� ��� ��ȣ�� ������ �̹��� ���ϸ�� ���������� �����´�

		JSONObject json = new JSONObject();

		try {
			String sql = " select c.cno, c.rdate, u.unick, u.fname, u.pname from comments as c join user as u on c.uno = u.uno where cno = ?; ";

			psmt = conn.prepareStatement(sql);
			psmt.setInt(1, cno);

			rs = psmt.executeQuery();

			if (rs.next()) {
				// JSON ��ü ����
				json.put("cno", cno);
				json.put("name", rs.getString("unick"));
				json.put("content", content);
				json.put("rdate", rs.getString("rdate"));
				json.put("fname", rs.getString("fname"));
				json.put("pname", rs.getString("pname"));
			}

		} catch (Exception e) {
			e.printStackTrace();
		}

		// JSON ���� ����
		PrintWriter out = response.getWriter();
		out.print(json.toString());
		out.flush();
	}
}