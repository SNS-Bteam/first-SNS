<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="sns.vo.*" %>
<%
BoardVO vo = (BoardVO)request.getAttribute("board");

UserVO viewUser = null;
int uno = 0;
if(session.getAttribute("loginUser") != null){
    viewUser = (UserVO)session.getAttribute("loginUser");
	uno = Integer.parseInt(viewUser.getUno());
}
%>
<script>
function deleteFn(){
	const bno = $("#bno").val();
	
	$.ajax({
		url : '<%=request.getContextPath()%>/board/delete.do',
		type='post',
		// AJAX의 data 객체에서는 키 값을 문자열로 명시할 필요가 없다.
		data : {bno : bno}
		success : function(response){
			if(response.trim()==='success'){
				
			location.href = '<%= request.getContextPath()%>';
			}else{
				alert('글 등록에 실패했습니다.');
			}
			
		},
		// ajax에서 ""와 ''를 구별하지 않으나, 통일성을 위해 둘 중 하나를 선택해서 사용해야한다.
		error : function(){
			alert("서버 오류가 발생했습니다.")
		}
		
	});
	
	
}
</script>
<!--웹페이지 본문-->
<div class="view_div">
    <div class="view_inner">
    	<label>
			<span class="imgSpan" style="width: 550px; height: 550px; cursor: default;">
				<img style="width: 550px; height: 550px; border-radius: 40px;" src="<%= request.getContextPath() %>/upload/<%= vo.getPname() %>">
			</span>
		</label>
       	<div class="view_content" style="width: 50%;">
       		<div class="icon-container">
				<!-- 추천표시되는곳 -->
				<div id="reco" style="width:30px; cursor:pointer;">
					<!-- <img style="width:30px; cursor:pointer;" 
			         src="https://img.icons8.com/?size=100&id=87&format=png&color=000000" /> -->
				</div>
				<!-- 이미지 다운로드 -->
				<a href="<%= request.getContextPath() %>/upload/<%= vo.getPname() %>" download="<%= request.getContextPath() %>/upload/<%= vo.getFname() %>">
					<img id="downIcon" style="width:30px;" src="https://img.icons8.com/?size=100&id=gElSR9wTv6aF&format=png&color=000000">
				</a>
				<!-- 메뉴바 -->
				<div id="menuA" style="width:30px; cursor:pointer; margin-bottom:5px;">
				    <img style="width:30px; transform: rotate(90deg);" 
				         src="https://img.icons8.com/?size=100&id=98963&format=png&color=000000">
				    <!-- 서브메뉴바 -->
				    <div id="menutableA" style="display: none;">
				        <!-- 게시글신고 -->
				        <div class="menu-container" id="complainDiv" onclick="complainAdd(<%= vo.getBno() %>);">
				        </div>
				        <%
						if(session.getAttribute("loginUser") != null){
							if(uno == vo.getUno()){
							%>
					        <!-- 게시글수정 -->
					        <div class="menu-container">
					            <i class="fas fa-solid fa-pen-nib"></i>
					            <button id="infoBtn" onclick="location.href='<%=request.getContextPath()%>/board/modify.do?bno=<%= vo.getBno() %>'">수정</button>
					        </div>
					        <!-- 게시글삭제 -->
					        <form action="">
						        <div class="menu-container">
						            <i class="fas fa-solid fa-eraser"></i>
						            <button id="infoBtn" onclick="deleteFn()">삭제</button>
						            <input type="hidden" id= bno name="bno" value="<%=vo.getBno()%>">
						        </div>
					        </form>
							<%
							}else if(viewUser.getUauthor().equals("A")){
								System.out.println("writer.getUauthor() : " + viewUser.getUauthor());
							%>
							<!-- 게시글삭제 -->
					        <div class="menu-container">
					            <i class="fas fa-solid fa-eraser"></i>
					            <button id="infoBtn">삭제</button>
					        </div>
							<%	
							}
						%>
				        <%
						}
						%>
				    </div>
				</div>
			</div>
       	<p style="font-size:26px; margin:10px 0;"><%= vo.getTitle() %></p>
		<div style="font-size:16px; margin-top:5px;">
		<div class="view_profil">
				<%
				if(vo.getUpname() != null && !vo.getUpname().equals("")){
				%>
		        <!-- 프로필 이미지가 있을 경우 -->
		        <img id="previewProfil" class="circular-img" 
		       		 onclick="location.href='<%= request.getContextPath() %>/user/mypage.do?uno=<%= vo.getUno() %>'"
		             style="border:none; width:50px; height:50px; cursor:pointer; " 
		             src="<%= request.getContextPath() %>/upload/<%= vo.getUpname() %>" alt="프로필 이미지" />
				<%
				}else{
					String firstNick = vo.getUnick().substring(0, 1);
	        	%>
		        <div class="icon profileicon" 
			        onclick="location.href='<%= request.getContextPath() %>/user/mypage.do?uno=<%= vo.getUno() %>'"
			        style="background-color:#EEEEEE; border-radius: 50%; cursor: pointer;
			        display: flex; justify-content: center; align-items: center; 
			        font-size: 24px; font-weight: bold; width: 50px; height: 50px;">
			        <%= firstNick %>
	        	</div>
	        	<%
				}
				%>
			    <span><%= vo.getUnick() %></span>
			    <button class="ssBtn">팔로우</button>
			</div>
		&nbsp;
		<%= vo.getRdate() %>&nbsp;
		추천수&nbsp; <%= vo.getRecommend() %>&nbsp;
		조회수&nbsp; <%= vo.getHit() %>
		</div><br>
		<div><%= vo.getContent() %></div>
		<!-- 댓글위치 -->
		<div class="comment_inner">
			<table>
				<tr>
					<td colspan="3">
						<div class="search-wrapper">
							<div class="input-container" id="seach-container"
							style="box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
						    background-color: white;
						    border-radius: 40px;
						    width:100%;
						    display: flex;
						    align-items: center; 
						    gap: 10px;
						    ">
								<i class="fas solid fa-comment-dots" style="margin-left:10px;"></i>
								<input type="text" name="comment" placeholder="댓글"	
								style="padding-right: 40px;	background-color: white;" size="50" readonly>
            			    </div>
         			    </div>
					</td>
				</tr>
			</table>
			<!-- 댓글목록 출력 -->
			<div class="commentDiv">
				<div style="display: flex; align-items: center; gap: 10px;">
        			<div class="view_profil">
						<img id="previewProfil" class="circular-img" 
			             style="border:none; width:50px; height:50px;" 
			             src="<%= request.getContextPath() %>/upload/96a49eb6-2c1b-4dab-b538-2defa1fa1043" alt="프로필 이미지" />
				    </div>
		            <span style="font-size:18px;">흰둥이</span> <!-- 닉네임 -->
		       </div>
			   <div style="margin-top: 5px; margin-left: 70px;" id="content">
                	<span>맛있어보여요!</span>
           	    </div>
           	    <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 5px; margin-left: 70px; font-size: 12px; color: #999;">
		            <!-- 작성일 -->
		            <span>2024.10.14 16:19</span>
	           	    <div style="display: flex; align-items: center; gap: 10px;"> 
			            <span id="menuB" class="menuB" style="display: flex; align-items: center; gap: 10px;">
			            	<i class="fas fa-solid fa-bars"></i>
				  	  	</span>
			  	    </div>
		  	    </div>
			</div>	
			</div>
        </div>
	</div>
</div>