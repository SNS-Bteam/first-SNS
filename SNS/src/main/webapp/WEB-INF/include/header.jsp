<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="sns.vo.*" %>
<%
String author= "";
String loginNo= "";
String userPname= "";
UserVO loginUser = null;
if(session.getAttribute("loginUser") != null) {
    loginUser = (UserVO)session.getAttribute("loginUser");
    if(loginUser.getPname() != null) {
        System.out.println("loginUser : " + loginUser.getPname());
        userPname = loginUser.getPname();
        loginNo = loginUser.getUno();
    }else {
        System.out.println("loginUser : 이름 없음");
    }
}else {
    System.out.println("loginUser : 로그인되지 않음");
}
%>
<!DOCTYPE html>
<html lang="kr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>SNS</title>
  <link rel="stylesheet" type="text/css" href="<%= request.getContextPath() %>/css/sns.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
  <script src="<%= request.getContextPath() %>/js/jquery-3.7.1.js"></script> 
  <script>
let IsDuplicate = false;
let NickDuplicate = false;
let emailcode = false;
$(document).ready(function() {
	// 페이지 로드 시 다크모드 초기화
    DarkMode();	
    
	// #menuA 클릭 시 #menutableA 토글
    $("#menuA").click(function(event) {
        $("#menutableA").toggle();  // 보이기/숨기기
        event.stopPropagation();    // 이벤트 전파 방지
    });

    // 문서의 다른 부분 클릭 시 #menutableA 숨기기
    $(document).click(function() {
        $("#menutableA").hide();
    });

    // #menutableA 내부 클릭 시 이벤트 전파 방지
    $("#menutableA").click(function(event) {
        event.stopPropagation();    // 이벤트 전파 방지
    });

    
    $(".icon").mouseover(function() {
        $(this).addClass('round');  // round 클래스 추가
    }).mouseout(function() {
        $(this).removeClass('round');  // round 클래스 제거
    });
    
    // 회원가입, 로그인 모달
    $(".userHeader a").click(function() {
        $("#user_modal").fadeIn();
        var clickedId = $(this).attr('id');
        var url = clickedId === "join" ? "<%= request.getContextPath() %>/user/join.do" : "<%= request.getContextPath() %>/user/login.do";
        
        $.ajax({
            url: url,
            type: "get",
            success: function(data) {
                $("#user_modalBody").html(data);
				
                // 동적으로 로드된 스크립트 실행
                $('script').each(function() {
                    if (this.src) {
                        $.getScript(this.src);
                    } else {
                        eval($(this).text());
                    }
                });
                
                resetEvents();

                // 다크모드 초기화 다시 실행
                DarkMode();
            }
        });
        
        
        $("header").css("z-index", "1"); 
        $("nav").css("z-index", "1"); 
    });

    $(window).click(function(event) {
        if ($(event.target).is("#user_modal")) {
            $("#user_modal").fadeOut();
            
       		// 모달창이 닫힐 때 header와 nav 색상 원래대로 되돌리기
            $("header").css("z-index", "1000");
            $("nav").css("z-index", "1001");
        }
    });
    
    $("#commentContent").on("keydown",function(event){
		if(event.key === "Enter"){
			btnComment();
			$("#commentContent").val("");
			return false;
		}
	});
    
    
    $("#search").keyup(function(event){
		if(event.keyCode == 13)	{	
			//Enter문자가 눌려짐. keyCode 아스키코드. 13이 enter 
			document.searchFn.submit();
		}
	});
	
	
	$("#search").on('keyup',function(){
		if($(this).val().length > 0){
			$("#clearBtn").css("display","inline");
		}else{
			$("#clearBtn").css("display","none");
		}
	});
	
	$("#clearBtn").on('click',function(){
	    $("#search").val('');  // 올바른 코드
	    $(this).css("display","none");
	});


	/* 로그인,회원가입 */
    $("#uid").focus();
    $("#login_uid").focus();
    
    $("#uid").on("input", function() {
	    var userid = $(this).val();
	    
	    // 아이디 길이가 4자 이상일 때에만 검증 요청
	    if(userid.length >= 4) {
	        $.ajax({
	            url: "<%= request.getContextPath() %>/user/idCheck.do",
	            type: "post",
	            data: { uid: userid },
	            dataType: "html",
	            success: function(result) {
	                result = result.trim();
	                switch(result) {
	                    case "00":
	                        $(".msg").html("사용 가능한 아이디입니다.");
	                        IsDuplicate = false;
	                        break;
	                    case "01":
	                        $(".msg").html("중복된 아이디입니다.");
	                        IsDuplicate = true;
	                        break;
	                }
	            }
	        });
	    }else {
	        $(".msg").html("아이디는 4자 이상이어야 합니다.");
	   	    // 동적으로 로드된 스크립트 실행
	    }
	});

	
	$("#unick").on("input", function() {
	    NickDuplicate = false;
	    var usernick = $(this).val();
	    
	    // 닉네임이 2글자 이상일 때 검증 요청
	    if (usernick.length >= 2) {
	        $.ajax({
	            url: "<%= request.getContextPath() %>/user/nickCheck.do",
	            type: "post",
	            data: { unick: usernick },
	            dataType: "html",
	            success: function(result) {
	                result = result.trim();
	                switch(result) {
	                    case "00":
	                        $(".msg").html("닉네임 체크 오류입니다.");
	                        break;
	                    case "01":
	                        $(".msg").html("중복된 닉네임입니다.");
	                        NickDuplicate = true;
	                        break;
	                    case "02":
	                        $(".msg").html("사용 가능한 닉네임입니다.");
	                        NickDuplicate = false;
	                        break;
	                }
	            }
	        });
	    }else {
	        // 닉네임이 2글자 미만일 경우 메시지 표시
	        $(".msg").html("닉네임은 2글자 이상이어야 합니다.");
	    }
	});
	

    
	/* 로그인 */
	$("#login_uid,#login_upw").keyup(function(event){
		if(event.keyCode == 13)
		{	//Enter문자가 눌려짐. keyCode 아스키코드. 13이 enter 
			DoLogin();
		}
	});
	
	
	// 파일 업로드 초기화
    $(".deleteFile").css("display", "none");
    $("#preview").css("display", "none");

    // 파일이 선택될 때의 동작
    $("#file").on('change', function(){
        var fileName = $("#file").val().split('\\').pop(); // 경로 제거하고 파일명만 추출
        if(fileName) {
            $(".upload-name").val(fileName);
            $(".deleteFile").show();
            $("#preview").show();
            $("input[name='deleteFile']").prop('checked', false);

            // 파일 미리보기 처리 (이미지일 경우)
            var file = this.files[0];
            if (file && file.type.startsWith("image/")) {
                var reader = new FileReader();
                reader.onload = function(e) {
                    $('#preview').attr('src', e.target.result);
                };
                reader.readAsDataURL(file);
            }
        }
    });

    // 파일 업로드 창을 열도록 하는 동작
    $(".upload-name").on('click', function() {
        $("#file").click();  // 파일 선택 창 열기
    });

    // 파일 삭제 동작
    $("input[name='deleteFile']").on('change', function() {
        if($(this).is(':checked')) {
            $(".upload-name").val("첨부파일");
            $("#file").val("");  // 파일 선택 취소
            $(".deleteFile").css("display", "none");
            $("#preview").css("display", "none");
            document.getElementById('preview').src = "";  // 미리보기 초기화
        }
    });

    
	var headerHeight = $('header').outerHeight(); // 헤더의 높이
    
    $(window).scroll(function() {
        // 현재 스크롤 위치가 header의 높이를 초과하면
        if ($(window).scrollTop() > headerHeight) {
            $('.listDiv').each(function() {
                var divOffset = $(this).offset().top; // 각 listDiv의 상단 위치
                if (divOffset < headerHeight) {
                    $(this).css('display', 'none'); // 헤더를 지나쳤을 때 숨기기
                } else {
                    $(this).css('display', 'flex'); // 다시 보이게 하기
                }
            });
        } else {
            $('.listDiv').css('display', 'flex'); // 스크롤이 헤더보다 위에 있을 때는 보이게 하기
        }
    });
});

function readURL(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('preview').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    } else {
        document.getElementById('preview').src = "";
    }
}


function findPage(type) {
	let url = "";
	if(type === "findId") {
	    url = "<%= request.getContextPath() %>/user/findId.do";
	}else if(type === "findPw") {
	    url = "<%= request.getContextPath() %>/user/findPw.do";
	}else if(type === "findPwOk") {
		if($("#find_uid").val() == ""){
			$(".msg").html("아이디를 입력해주세요.");
			$("#find_uid").focus();
			return false;
		}
		let mail = document.getElementById("uemail");
	    var emailPattern = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
	    if(mail.value == "") {
	        $(".msg").html("이메일을 입력해주세요");
	        mail.focus();
	        return false;
	    }else if (!emailPattern.test(mail.value)) {
	        $(".msg").html("유효한 이메일 주소를 입력하세요");
	        mail.focus();
	        return false;
	    }if(emailcode == false)	{
	    	$(".msg").html("이메일 인증을 해주세요.");
			$("#code").focus();
			return false;
		}
	    url = "<%= request.getContextPath() %>/user/findPw.do";
	}else if(type === "pwChange") {
	    url = "<%= request.getContextPath() %>/user/pwChange.do";
	}else{
		let mail = document.getElementById("uemail");
	    var emailPattern = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
	    if(mail.value == "") {
	        $(".msg").html("이메일을 입력해주세요");
	        mail.focus();
	        return false;
	    }else if (!emailPattern.test(mail.value)) {
	        $(".msg").html("유효한 이메일 주소를 입력하세요");
	        mail.focus();
	        return false;
	    }if(emailcode == false)	{
	    	$(".msg").html("이메일 인증을 해주세요.");
			$("#code").focus();
			return false;
		}
		
		url = "<%= request.getContextPath() %>/user/findIdResult.do";
	}

    
    $.ajax({
        url: url,
        type: (type === "findPwOk" || type === "findIdResult") ? "post" : "get",
      	data: (type === "findPwOk") 
      		? {uid: $("#find_uid").val(), uemail: $("#uemail").val()} 
    			: (type === "findIdResult") 
    				? {uemail: $("#uemail").val()} : {},
        success: function(data) {
            $("#user_modalBody").html(data); // 모달 내부에 페이지 로드
            
            // 동적으로 로드된 스크립트 실행
            $('script').each(function() {
                if (this.src) {
                    $.getScript(this.src);
                } else {
                    eval($(this).text());
                }
            });
            
            resetEvents();
            DarkMode();
        }
    });
    
    $(document).on('click', '#emailBtn', function() {
    	$("#emailBtn").text("메일발송중");
    });
}

function DoChange(){
	if($("#pUpw").val() == ""){
		$(".msg").html("비밀번호를 입력해주세요.");
		$("#pUpw").focus();
		return false;
	}
	
    if ($("#pUpwcheck").val() == "") {  // 수정된 ID 참조
        $(".msg").html("비밀번호 확인을 입력해주세요");
        $("#pUpwcheck").focus();
        return false;
    } else if ($("#pUpwcheck").val() != $("#pUpw").val()) {  // 수정된 ID 참조
        $(".msg").html("비밀번호가 일치하지 않습니다");
        $("#pUpwcheck").focus();
        return false;
    }
    
    $.ajax({
    	url:"<%= request.getContextPath() %>/user/pwChange.do",
    	type:"post",
    	data:{
    		uid: $("#pUid").val(),
    		uemail: $("#pUemail").val(),
    		upw: $("#pUpw").val()
    	},
    	success:function(result){
    		result = result.trim();
	        switch(result) {
	            case "success":
	            	openLoginModal();
	                break;
	            case "error":
	                alert("비밀번호 재설정에 실패하셨습니다.");
	                break;
	            default :
	           		alert("서버와의 연결에 실패했습니다. 나중에 다시 시도해 주세요.");
              		break;
       		 }
    	}
    });
}


function DarkMode() {
    const currentMode = localStorage.getItem('mode') || 'light';
    const modeText = document.getElementById('modeText');
    if (currentMode === 'dark') {
        document.body.classList.add('dark-mode');
        modeText.textContent = '라이트모드';
    } else {
        document.body.classList.remove('dark-mode');
        modeText.textContent = '다크모드';
    }

    // 다크모드 토글 버튼 클릭 이벤트
    document.getElementById('modeToggle').addEventListener('click', function() {
        document.body.classList.toggle('dark-mode');
        const newMode = document.body.classList.contains('dark-mode') ? 'dark' : 'light';
        localStorage.setItem('mode', newMode);
        modeText.textContent = newMode === 'dark' ? '라이트모드' : '다크모드';
    });
}

function resetEvents() {
    $("#uid, #upw, #upwcheck, #unick, #uemail, #login_uid, #login_upw, #find_uid").on("input", function() {
        DoReset();
    });

    // 회원가입 버튼에 다시 이벤트 연결
    $("#joinBtn").on("click", function() {
        DoJoin();
    });

    // 로그인 버튼에 다시 이벤트 연결
    $("#loginBtn").on("click", function() {
        DoLogin();
    });
}



/* 회원가입 */
function openLoginModal() {
    $("#user_modal").fadeIn();
    
    $(".msg").html(""); 
    
    $.ajax({
        url: "<%= request.getContextPath() %>/user/login.do",
        type: "get",
        success: function(data) {
            $("#user_modalBody").html(data);

            // 동적으로 로드된 스크립트 실행
            $('script').each(function() {
                if (this.src) {
                    $.getScript(this.src);
                } else {
                    eval($(this).text());
                }
            });

            resetEvents();
            DarkMode();
        }
    });
}


function DoReset(){
	$(".msg").html("");  // 메시지 내용 지우기
}


function DoLogin(){
	if($("#login_uid").val() == ""){
		$(".msg").html("아이디를 입력해주세요.");
		$("#login_uid").focus();
		return false;
	}
	
	if($("#login_upw").val() == ""){
		$(".msg").html("비밀번호를 입력해주세요.");
		$("#login_upw").focus();
		return false;
	}
	
	    // 폼 데이터 비동기적으로 전송
	    var form = document.getElementById("loginFn");
	    console.log(document.loginFn.uid.value);
	    $.ajax({
    	url:"<%= request.getContextPath() %>/user/login.do",
    	type:"post",
    	data:{
    		uid: $("#login_uid").val(),
    		upw: $("#login_upw").val()
    	},
    	success:function(result){
    		result = result.trim();
            switch(result) {
            case "success":
           	 /* alert("로그인에 성공"); */
                <%-- window.location.href = "<%= request.getContextPath() %>"; --%>
                location.reload();
                break;
             case "error":
           	    openLoginModal();
                alert("로그인에 실패하셨습니다.");
                break;
             default :
           	 	alert("서버와의 연결에 실패했습니다. 나중에 다시 시도해 주세요.");
                break;
       		 }
    	}
    });
}

function DoJoin() {
    let id = document.getElementById("uid");

    // 아이디 검사
    if (id.value == "") {
        $(".msg").html("아이디를 입력해주세요");
        id.focus();
        return false;
    } else if (id.value.length < 4) {
        $(".msg").html("아이디는 4글자 이상 입력해주세요");
        id.focus();
        return false;
    }else if (id.value.length > 12) {
        $(".msg").html("아이디는 12글자 이하로 입력해주세요");
        id.focus();
        return false;
    } else if (!/^[a-z0-9]+$/.test(id.value)) {
        $(".msg").html("아이디는 영어 소문자와 숫자만 가능합니다");
        id.focus();
        return false;
    } else if (IsDuplicate == true) {
        $(".msg").html("중복된 아이디입니다");
        id.focus();
        return false;
    }

    // 비밀번호 검사
    let pass = document.getElementById("upw");
    if(pass.value == "") {
        $(".msg").html("비밀번호를 입력해주세요");
        pass.focus();
        return false;
    }else if(pass.value.length < 4) {
        $(".msg").html("비밀번호는 4글자 이상 입력해주세요");
        pass.focus();
        return false;
    }else if(pass.value.length > 20) {
        $(".msg").html("비밀번호는 20글자 이하로 입력해주세요");
        pass.focus();
        return false;
    }

    // 비밀번호 확인
    let pwCheck = document.getElementById("upwcheck");
    if (pwCheck.value == "") {
        $(".msg").html("비밀번호 확인을 입력해주세요");
        pwCheck.focus();
        return false;
    } else if (pwCheck.value != pass.value) {
        $(".msg").html("비밀번호가 일치하지 않습니다");
        pwCheck.focus();
        return false;
    }

    // 닉네임 2글자 이상
    let userNick = document.getElementById("unick");
    if (userNick.value == "") {
        $(".msg").html("닉네임을 입력해주세요");
        userNick.focus();
        return false;
    } else if (userNick.value.length < 2) {
        $(".msg").html("닉네임은 2글자 이상 입력해주세요");
        userNick.focus();
        return false;
    }else if (userNick.value.length > 20) {
        $(".msg").html("닉네임은 20글자 이하로 입력해주세요");
        userNick.focus();
        return false;
    } else if (NickDuplicate == true) {
        $(".msg").html("이미 사용중인 닉네임입니다");
        userNick.focus();
        return false;
    }

    // 이메일 입력 확인
    let mail = document.getElementById("uemail");
    var emailPattern = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
    if(mail.value == "") {
        $(".msg").html("이메일을 입력해주세요");
        mail.focus();
        return false;
    }else if (!emailPattern.test(mail.value)) {
        $(".msg").html("유효한 이메일 주소를 입력하세요");
        mail.focus();
        return false;
    }if(emailcode == false)	{
    	$(".msg").html("이메일 인증을 해주세요.");
		$("#code").focus();
		return false;
	}

    // 폼 데이터 비동기적으로 전송
    var form = document.getElementById("joinFn");
    
    $.ajax({
        url: "<%= request.getContextPath() %>/user/join.do",  // 요청 URL
        type: "post",  // 요청 방식
        data: new FormData(form),  // 폼 데이터 전송
        processData: false,  // 자동 데이터 처리 방지
        contentType: false,  // 요청 시 Content-Type 설정 방지
        success: function(result) {
			result = result.trim();
	            	
	            switch(result) {
                 case "success":
                	 openLoginModal();
                     break;
                 case "error":
                	 $(".msg").html("회원가입에 실패했습니다. 다시 시도해주세요.");
                     break;
                 default :
                	 alert("서버와의 연결에 실패했습니다. 나중에 다시 시도해 주세요.");
                     break;
             }
        }
    });
}

//------------------ 인증번호 발송 버튼 -------------------
function SendMail() {
	var email = $("#uemail").val();
	var pattern = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
	
	if(!pattern.test($("#uemail").val())) {
		$(".msg").html("올바른 메일주소를 입력해주세요");
		$("#uemail").focus();
		return;
	}else if($("#uemail").val().length < 5)	{
		$(".msg").html("메일주소를 5자 이상 입력해주세요.");
		$("#uemail").focus();
		return;
	}
	
	$.ajax({
		url: "<%= request.getContextPath() %>/user/sendmail.do",
		type : "post",
		data : {uemail : email},
		dataType: "html",
		success : function(result) {
			result = result.trim();
			$("#emailBtn").text("인증하기");
			alert(result);
		}			
	});		
}
// ----------- 이메일 코드인증 확인 버튼 --------------
function DoEmail() {
	if($("#code").val() == "") {
		$(".msg").html("인증코드를 입력하세요.");
		$("#code").focus();
		return;
		emailcode = false;
	}		
	
	// 받아온 코드값과 입력한 코드값을 비교
	$.ajax({
		url: "<%= request.getContextPath() %>/user/getcode.do",
		type : "post",
		dataType: "html",
		success : function(result) {
			result = result.trim();
			if($("#code").val() == result) {
				console.log(result);				
				$(".msg").html("인증이 완료되었습니다.");
				emailcode = true;
			}else {
				console.log(result);	
				$(".msg").html("인증코드가 일치하지 않습니다.");
				$("#code").focus();
				emailcode = false;
			}
		}			
	});		
}

/* 추천 테이블 */
function loadReco(bno) {
    $.ajax({
        url: "<%= request.getContextPath() %>/board/loadReco.do",
        type: "get",
        data: { bno: bno},
        success: function(data) {
        	console.log("loadReco data:"+data);
            $("#reco").html(data);
        },
        error: function(xhr, status, error) {
            console.error("AJAX 요청 실패: ", status, error);  // 오류 확인
        }
    });
}
function recoAdd(bno) {
	let loginUno = '<%= session.getAttribute("loginUser") %>';
	console.log(loginUno);
	
	if(loginUno != 'null'){
	    $.ajax({
	        url: "<%= request.getContextPath() %>/board/recoAdd.do",
	        type: "post",
	        data: { bno: bno },
	        success: function() {
	            loadReco(bno);  // 추천 상태를 다시 로드
	        }
	    });
	}else{
		alert("로그인 후 추천가능합니다.");
	}
}

/* 신고 테이블 */
function loadComplain(bno) {
    $.ajax({
        url: "<%= request.getContextPath() %>/admin/loadComplain.do",
        type: "get",
        data: { bno: bno },
        success: function(data) {
        	console.log(data);
            $("#complainDiv").html(data);
        }
    });
}

function complainAdd(bno) {
	let loginUno = '<%= session.getAttribute("loginUser") %>';
	console.log(loginUno);
	
	if(loginUno != 'null'){
		$.ajax({
	        url: "<%= request.getContextPath() %>/admin/complainAdd.do",
	        type: "post",
	        data: { bno: bno },
	        success: function() {
	        	loadComplain(bno);  // 신고 상태를 다시 로드
	        }
	    });
	}else{
		alert("로그인 후 신고가능합니다.");
	}
}

// ------------알림 모달창------------------
    const alarmModal = document.querySelector(".alarm_modal");
    const openIcon = document.querySelector(".icon");
    const closeIcon = document.querySelector(".icon");
    
    openIcon.onclick = function() {
        alarmModal.style.display = "flex";
    }
    
    closeIcon.onclick = function() {
    	alarmModal.style.display = "none";
    }

    window.onclick = function(event) {
        if (event.target == alarmModal) {
        	alarmModal.style.display = "none";
        }
    }
    
</script>
</head> 

<body>
	<!-- header 검색창, 프로필이미지, 알림, 메시지 -->
	<header>
		<div class="top-bar">
			<%-- <div class="logo_inner">
	            <!-- 로고 표시 -->
		        <div class="icon" onclick="location.href='<%= request.getContextPath() %>'">
	      	   		<img id="logo" src="<%= request.getContextPath() %>/image/logo.jpg">
	      	   		<div class="login-hover-menu">
			            <p>홈이동</p>
			        </div>
		        </div>
	        </div> --%>
	        <div class="search_inner">
	            <form action="index.jsp" method="get" name="searchFn" style="padding-bottom:30px;">
	                <div class="search-wrapper">
	                    <div id="seach-container"
	                    style="display: flex;  align-items: center;
	                    box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
	                    background-color: white;
	                    border-radius: 25px;
	                    width:45%; height: 52px;
	                    margin-top: 1.5%; margin-left:40%;
	                    ">
			      	   		<img id="searchIcon" 
			      	   		onclick="location.href='<%= request.getContextPath() %>'"
			      	   		src="<%= request.getContextPath() %>/image/logo.jpg">
	                        <input type="text" name="searchValue" id="search" placeholder="검색">
	                        <i class="fas fa-times" id="clearBtn"></i>
	                    </div>
	                </div>
	            </form>
	        </div>
	        <%
			if(loginUser != null){
			%>
	        <!-- 로그인했을 경우 -->
	        <div class="userHeader_login">
	    	    <%-- <div class="icon">
		        	<a href="<%= request.getContextPath() %>/board/write.do">
	                    <img style="margin-top:16px;"
	                    src="https://img.icons8.com/?size=100&id=59864&format=png&color=767676" alt="글쓰기">
	                </a>
	                <div class="login-hover-menu">
	                    <p>글쓰기</p>
	                </div>
	            </div> --%>
		        <!-- 알림 표시 -->
		        <div class="icon">
	      	   		<img src="https://img.icons8.com/?size=100&id=3334&format=png&color=767676">
	      	   		<div class="login-hover-menu">
			            <p>알림</p>
			        </div>
		        </div>
		        <!-- 메시지 표시 -->
		        <div class="icon">
		       		<img src="https://img.icons8.com/?size=100&id=37966&format=png&color=767676">
		       		<div class="login-hover-menu">
			            <p>메시지</p>
			        </div>
		        </div>
		        <!-- 프로필이미지 -->
		        <%
		        if(userPname != null && !userPname.equals("")){
	        	%>
	        	<div class="icon">
		        	<img id="previewProfil" class="circular-img" 
		        	onclick="location.href='<%= request.getContextPath() %>/user/mypage.do?uno=<%= loginNo %>'"
			            style="border:none;" 
			            src="<%= request.getContextPath()%>/upload/<%= userPname %>"
		           		alt="첨부된 이미지" style="max-width: 100%; height: auto;" />
		        	<%-- <img id="previewProfil" class="circular-img" 
		        	onclick="location.href='<%= request.getContextPath() %>/user/mypage.do'"
			            style="border:none;" 
			            src="<%= userPname != null && !userPname.equals("") 
			            ? request.getContextPath()+"/upload/" + userPname 
		           		: "https://img.icons8.com/?size=100&id=115346&format=png&color=000000" %>" 
		           		alt="첨부된 이미지" style="max-width: 100%; height: auto;" /> --%>
	           		<div class="login-hover-menu">
			            <p>프로필</p>
			        </div>
	         	</div>
	        	<%
		        }else{
		        	String firstNick = loginUser.getUnick().substring(0, 1);
	        	%>
		        <div class="icon profileicon" 
			        onclick="location.href='<%= request.getContextPath() %>/user/mypage.do?uno=<%= loginNo %>'"
			        style="background-color:#EEEEEE; border-radius: 50%; cursor: pointer;
			        display: flex; justify-content: center; align-items: center; margin-left:10px;
			        font-size: 24px; font-weight: bold; width: 70px; height: 70px;">
			        <%= firstNick %>
		        	<div class="login-hover-menu">
			            <p>프로필</p>
			        </div>
	        	</div>
	        	<%
		        }
		        %>
	        </div>
			<%
			}else{
			%>
	        <!-- 로그인하지 않았을 경우 -->
	        <div class="userHeader">
	            <a id="join">회원가입</a>&nbsp;|&nbsp; 
				<a id="login">로그인</a>
	        </div>
			<%	
			}
			%>
		</div>	
	<nav>
     	<ul>
           <li>
                <!-- 다크모드&라이트모드 전환 -->
                <div class="menu-item" id="modeToggle">
                    <a>
                        <img src="https://img.icons8.com/?size=100&id=101342&format=png&color=767676" alt="다크모드 전환">
                    </a>
                    <div class="hover-menu">
	                    <p id="modeText">다크모드</p>
	                </div>
                </div>
            </li>
            <%
			if(loginUser != null){
			%>
			<li>
				<div class="menu-item">
		        	<a href="<%= request.getContextPath() %>/board/write.do">
	                    <img src="https://img.icons8.com/?size=100&id=59864&format=png&color=767676" alt="글쓰기">
	                </a>
	                <div class="hover-menu">
	                    <p>글쓰기</p>
	                </div>
	            </div>
			</li>
            <!-- 로그인한 경우 로그아웃 -->
			<li>
                <div class="menu-item">
                    <a href="<%= request.getContextPath() %>/user/logout.do">
                        <img class="logout" src="https://img.icons8.com/?size=100&id=BvRKVanAagI0&format=png&color=767676" alt="로그아웃">
                    </a>
                    <div class="hover-menu">
	                    <p>로그아웃</p>
	                </div>
                </div>
            </li> 
          	<%
           	if(loginUser.getUauthor().equals("A")){
	        %>
            <!-- 관리자의 경우 신고내역확인 -->
			<li>
                <div class="menu-item">
                    <a href="<%= request.getContextPath() %>/admin/blackList.do">
                        <img src="https://img.icons8.com/?size=100&id=8773&format=png&color=767676" alt="관리자 신고 관리">
                    </a>
                    <div class="hover-menu">
	                    <p>신고관리</p>
	                </div>
                </div>
            </li>
          	<%
            	}
			}
			%>
        </ul>
    </nav>
	</header>
	<!-- 회원가입,로그인 모달창 -->
	<div id="user_modal" style="display:none;">
	    <div class="user_modal-content">
	        <div id="user_modalBody">
	            <!-- 회원가입,로그인페이지 여기에 표시됨 -->
	        </div>
	    </div>
	</div>
	<!-- view 페이지 모달창 -->
	<div id="modal" style="display:none;">
	    <div class="modal-content">
	        <div id="modalBody">
	            <!-- 게시글 내용이 여기에 표시됨 -->
	        </div>
	    </div>
	</div>
	
	<!-- 알림 모달창 -->
	<div id="alarm_modal" style="display:none;">
		<div class="alarm_modal-content">
			<div id="alarm_modalBody">
				<!-- 알람 내용 여기에 표시됨 -->
			</div>
		</div>
	</div>