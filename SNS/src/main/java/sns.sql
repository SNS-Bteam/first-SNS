SET SESSION FOREIGN_KEY_CHECKS=0;

/* Drop Tables */

DROP TABLE IF EXISTS ATTACH;
DROP TABLE IF EXISTS COMMENTS;
DROP TABLE IF EXISTS COMPLAINT_BOARD;
DROP TABLE IF EXISTS LOVE;
DROP TABLE IF EXISTS BOARD;
DROP TABLE IF EXISTS FOLLOW;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS USER;




/* Create Tables */

CREATE TABLE ATTACH
(
	ano int NOT NULL AUTO_INCREMENT,
	pname varchar(50) NOT NULL,
	fname varchar(200),
	bno int NOT NULL,
	PRIMARY KEY (ano)
);


CREATE TABLE BOARD
(
	bno int NOT NULL AUTO_INCREMENT,
	title varchar(100) NOT NULL,
	hit int DEFAULT 0 NOT NULL,
	-- E-활성화
	-- D-비활성화
	state char DEFAULT 'E' NOT NULL COMMENT 'E-활성화
D-비활성화',
	rdate timestamp DEFAULT now() NOT NULL,
	content text NOT NULL,
	uno int NOT NULL,
	PRIMARY KEY (bno)
);


CREATE TABLE COMMENTS
(
	cno int NOT NULL AUTO_INCREMENT,
	content text NOT NULL,
	rdate timestamp DEFAULT now() NOT NULL,
	-- E-활성화
	-- D-비활성화
	state char DEFAULT 'E' NOT NULL COMMENT 'E-활성화
D-비활성화',
	bno int NOT NULL,
	uno int NOT NULL,
	PRIMARY KEY (cno)
);


CREATE TABLE COMPLAINT_BOARD
(
	cpno int NOT NULL AUTO_INCREMENT,
	bno int NOT NULL,
	uno int NOT NULL,
	PRIMARY KEY (cpno)
);


CREATE TABLE FOLLOW
(
	fno int NOT NULL AUTO_INCREMENT,
	uno int NOT NULL,
	tuno int NOT NULL,
	PRIMARY KEY (fno)
);


CREATE TABLE LOVE
(
	lno int NOT NULL AUTO_INCREMENT,
	bno int NOT NULL,
	uno int NOT NULL,
	PRIMARY KEY (lno)
);


CREATE TABLE message
(
	mno int NOT NULL AUTO_INCREMENT,
	uno int NOT NULL,
	tuno int NOT NULL,
	content text NOT NULL,
	rdate timestamp DEFAULT now() NOT NULL,
	PRIMARY KEY (mno)
);


CREATE TABLE USER
(
	uno int NOT NULL AUTO_INCREMENT,
	uid varchar(12) NOT NULL,
	upw varchar(200) NOT NULL,
	unick varchar(20) NOT NULL,
	uemail varchar(100) NOT NULL,
	urdate timestamp DEFAULT now() NOT NULL,
	-- U-유저
	-- A-관리자
	uauthor char DEFAULT 'U' NOT NULL COMMENT 'U-유저
A-관리자',
	pname varchar(50),
	fname varchar(200),
	-- 활성화-E
	-- 비활성화-D
	ustate char DEFAULT 'E' NOT NULL COMMENT '활성화-E
비활성화-D',
	PRIMARY KEY (uno),
	UNIQUE (uid),
	UNIQUE (unick)
);



/* Create Foreign Keys */

ALTER TABLE ATTACH
	ADD FOREIGN KEY (bno)
	REFERENCES BOARD (bno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE COMMENTS
	ADD FOREIGN KEY (bno)
	REFERENCES BOARD (bno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE COMPLAINT_BOARD
	ADD FOREIGN KEY (bno)
	REFERENCES BOARD (bno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE LOVE
	ADD FOREIGN KEY (bno)
	REFERENCES BOARD (bno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE BOARD
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE COMMENTS
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE COMPLAINT_BOARD
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE FOLLOW
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE FOLLOW
	ADD FOREIGN KEY (tuno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE LOVE
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE message
	ADD FOREIGN KEY (uno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;


ALTER TABLE message
	ADD FOREIGN KEY (tuno)
	REFERENCES USER (uno)
	ON UPDATE RESTRICT
	ON DELETE RESTRICT
;



