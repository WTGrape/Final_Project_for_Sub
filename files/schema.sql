CREATE USER 'nadeuriADM'@'%' IDENTIFIED BY 'ghostone1!';

CREATE DATABASE nadeuri;

GRANT ALL PRIVILEGES ON nadeuri.* TO 'nadeuriADM'@'%';

FLUSH PRIVILEGES;

use nadeuri

DROP TABLE nadeuri.xuser;

create table nadeuri.xuser(
    id INT(13) NOT NULL AUTO_INCREMENT,
    user_Name VARCHAR(30) NOT NULL,
    user_Email VARCHAR(40) NOT NULL,
    password VARCHAR(256) NULL DEFAULT NULL,
    platform VARCHAR(6),
    PRIMARY KEY (id)
)COLLATE='utf8_general_ci'
ENGINE=INNODB;

DROP TABLE nadeuri.xboard;

create table nadeuri.xboard(
    id INT(13) NOT NULL AUTO_INCREMENT,
    creator_id INT(13) NOT NULL,
    title VARCHAR(40) NOT NULL,
    content VARCHAR(3000) NULL DEFAULT NULL,
    location VARCHAR(90) NULL DEFAULT NULL,
    address VARCHAR(90) NULL DEFAULT NULL,
    recomend_up INT(12) NULL DEFAULT NULL,
    recomend_down INT(12) NULL DEFAULT NULL,
    created_at datetime,
    delete_YN VARCHAR(1) DEFAULT 'N',
    img_uid  VARCHAR(256) DEFAULT '',
    PRIMARY KEY (id)
)COLLATE='utf8_general_ci'
ENGINE=INNODB;


DROP TABLE nadeuri.xfestivalInfo;

create table nadeuri.xfestivalInfo(
    id INT(13) NOT NULL AUTO_INCREMENT,
    title VARCHAR(256) NULL DEFAULT NULL,
    tel VARCHAR(128) NOT NULL,
    addr1 VARCHAR(64) NOT NULL,
    addr2 VARCHAR(64) NOT NULL,
    event_start_date VARCHAR(8) NOT NULL,
    event_end_date VARCHAR(8) NOT NULL,
    mapx VARCHAR(40) NOT NULL,
    mapy VARCHAR(40) NOT NULL,
    first_image VARCHAR(512) NOT NULL,
    PRIMARY KEY (id)
)COLLATE='utf8_general_ci'
ENGINE=INNODB;