#
# phpBB2 - SQLite schema (generated from mysql_schema.sql)
#
CREATE TABLE phpbb_auth_access (
   group_id mediumint(8) DEFAULT '0' NOT NULL,
   forum_id smallint(5) DEFAULT '0' NOT NULL,
   auth_view tinyint(1) DEFAULT '0' NOT NULL,
   auth_read tinyint(1) DEFAULT '0' NOT NULL,
   auth_post tinyint(1) DEFAULT '0' NOT NULL,
   auth_reply tinyint(1) DEFAULT '0' NOT NULL,
   auth_edit tinyint(1) DEFAULT '0' NOT NULL,
   auth_delete tinyint(1) DEFAULT '0' NOT NULL,
   auth_sticky tinyint(1) DEFAULT '0' NOT NULL,
   auth_announce tinyint(1) DEFAULT '0' NOT NULL,
   auth_vote tinyint(1) DEFAULT '0' NOT NULL,
   auth_pollcreate tinyint(1) DEFAULT '0' NOT NULL,
   auth_attachments tinyint(1) DEFAULT '0' NOT NULL,
   auth_mod tinyint(1) DEFAULT '0' NOT NULL
);
CREATE INDEX phpbb_auth_access_group_id ON phpbb_auth_access (group_id);
CREATE INDEX phpbb_auth_access_forum_id ON phpbb_auth_access (forum_id);

CREATE TABLE phpbb_user_group (
   group_id mediumint(8) DEFAULT '0' NOT NULL,
   user_id mediumint(8) DEFAULT '0' NOT NULL,
   user_pending tinyint(1)
);
CREATE INDEX phpbb_user_group_group_id ON phpbb_user_group (group_id);
CREATE INDEX phpbb_user_group_user_id ON phpbb_user_group (user_id);

CREATE TABLE phpbb_groups (
   group_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   group_type tinyint(4) DEFAULT '1' NOT NULL,
   group_name varchar(40) COLLATE NOCASE NOT NULL DEFAULT '',
   group_description varchar(255) COLLATE NOCASE NOT NULL DEFAULT '',
   group_moderator mediumint(8) DEFAULT '0' NOT NULL,
   group_single_user tinyint(1) DEFAULT '1' NOT NULL
);
CREATE INDEX phpbb_groups_group_single_user ON phpbb_groups (group_single_user);

CREATE TABLE phpbb_banlist (
   ban_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   ban_userid mediumint(8) NOT NULL DEFAULT '0',
   ban_ip varchar(32) COLLATE NOCASE NOT NULL DEFAULT '',
   ban_email varchar(255) COLLATE NOCASE
);
CREATE INDEX phpbb_banlist_ban_ip_user_id ON phpbb_banlist (ban_ip, ban_userid);

CREATE TABLE phpbb_categories (
   cat_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   cat_title varchar(100) COLLATE NOCASE,
   cat_order mediumint(8) NOT NULL DEFAULT '0'
);
CREATE INDEX phpbb_categories_cat_order ON phpbb_categories (cat_order);

CREATE TABLE phpbb_config (
   config_name varchar(255) COLLATE NOCASE NOT NULL DEFAULT '',
   config_value varchar(255) COLLATE NOCASE NOT NULL DEFAULT '',
   PRIMARY KEY (config_name)
);

CREATE TABLE phpbb_confirm (
   confirm_id char(32) COLLATE NOCASE DEFAULT '' NOT NULL,
   session_id char(32) COLLATE NOCASE DEFAULT '' NOT NULL,
   code char(6) COLLATE NOCASE DEFAULT '' NOT NULL,
   PRIMARY KEY (session_id, confirm_id)
);

CREATE TABLE phpbb_disallow (
   disallow_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   disallow_username varchar(25) COLLATE NOCASE DEFAULT '' NOT NULL
);

CREATE TABLE phpbb_forum_prune (
   prune_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   forum_id smallint(5) NOT NULL DEFAULT '0',
   prune_days smallint(5) NOT NULL DEFAULT '0',
   prune_freq smallint(5) NOT NULL DEFAULT '0'
);
CREATE INDEX phpbb_forum_prune_forum_id ON phpbb_forum_prune (forum_id);

CREATE TABLE phpbb_forums (
   forum_id smallint(5) NOT NULL DEFAULT '0',
   cat_id mediumint(8) NOT NULL DEFAULT '0',
   forum_name varchar(150) COLLATE NOCASE,
   forum_desc text COLLATE NOCASE,
   forum_status tinyint(4) DEFAULT '0' NOT NULL,
   forum_order mediumint(8) DEFAULT '1' NOT NULL,
   forum_posts mediumint(8) DEFAULT '0' NOT NULL,
   forum_topics mediumint(8) DEFAULT '0' NOT NULL,
   forum_last_post_id mediumint(8) DEFAULT '0' NOT NULL,
   prune_next int(11),
   prune_enable tinyint(1) DEFAULT '0' NOT NULL,
   auth_view tinyint(2) DEFAULT '0' NOT NULL,
   auth_read tinyint(2) DEFAULT '0' NOT NULL,
   auth_post tinyint(2) DEFAULT '0' NOT NULL,
   auth_reply tinyint(2) DEFAULT '0' NOT NULL,
   auth_edit tinyint(2) DEFAULT '0' NOT NULL,
   auth_delete tinyint(2) DEFAULT '0' NOT NULL,
   auth_sticky tinyint(2) DEFAULT '0' NOT NULL,
   auth_announce tinyint(2) DEFAULT '0' NOT NULL,
   auth_vote tinyint(2) DEFAULT '0' NOT NULL,
   auth_pollcreate tinyint(2) DEFAULT '0' NOT NULL,
   auth_attachments tinyint(2) DEFAULT '0' NOT NULL,
   PRIMARY KEY (forum_id)
);
CREATE INDEX phpbb_forums_forums_order ON phpbb_forums (forum_order);
CREATE INDEX phpbb_forums_cat_id ON phpbb_forums (cat_id);
CREATE INDEX phpbb_forums_forum_last_post_id ON phpbb_forums (forum_last_post_id);

CREATE TABLE phpbb_posts (
   post_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   topic_id mediumint(8) DEFAULT '0' NOT NULL,
   forum_id smallint(5) DEFAULT '0' NOT NULL,
   poster_id mediumint(8) DEFAULT '0' NOT NULL,
   post_time int(11) DEFAULT '0' NOT NULL,
   poster_ip varchar(32) COLLATE NOCASE NOT NULL DEFAULT '',
   post_username varchar(25) COLLATE NOCASE,
   enable_bbcode tinyint(1) DEFAULT '1' NOT NULL,
   enable_html tinyint(1) DEFAULT '0' NOT NULL,
   enable_smilies tinyint(1) DEFAULT '1' NOT NULL,
   enable_sig tinyint(1) DEFAULT '1' NOT NULL,
   post_edit_time int(11),
   post_edit_count smallint(5) DEFAULT '0' NOT NULL
);
CREATE INDEX phpbb_posts_forum_id ON phpbb_posts (forum_id);
CREATE INDEX phpbb_posts_topic_id ON phpbb_posts (topic_id);
CREATE INDEX phpbb_posts_poster_id ON phpbb_posts (poster_id);
CREATE INDEX phpbb_posts_post_time ON phpbb_posts (post_time);

CREATE TABLE phpbb_posts_text (
   post_id mediumint(8) DEFAULT '0' NOT NULL,
   bbcode_uid char(10) COLLATE NOCASE DEFAULT '' NOT NULL,
   post_subject char(60) COLLATE NOCASE,
   post_text text COLLATE NOCASE,
   PRIMARY KEY (post_id)
);

CREATE TABLE phpbb_privmsgs (
   privmsgs_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   privmsgs_type tinyint(4) DEFAULT '0' NOT NULL,
   privmsgs_subject varchar(255) COLLATE NOCASE DEFAULT '0' NOT NULL,
   privmsgs_from_userid mediumint(8) DEFAULT '0' NOT NULL,
   privmsgs_to_userid mediumint(8) DEFAULT '0' NOT NULL,
   privmsgs_date int(11) DEFAULT '0' NOT NULL,
   privmsgs_ip varchar(32) COLLATE NOCASE NOT NULL DEFAULT '',
   privmsgs_enable_bbcode tinyint(1) DEFAULT '1' NOT NULL,
   privmsgs_enable_html tinyint(1) DEFAULT '0' NOT NULL,
   privmsgs_enable_smilies tinyint(1) DEFAULT '1' NOT NULL,
   privmsgs_attach_sig tinyint(1) DEFAULT '1' NOT NULL
);
CREATE INDEX phpbb_privmsgs_privmsgs_from_userid ON phpbb_privmsgs (privmsgs_from_userid);
CREATE INDEX phpbb_privmsgs_privmsgs_to_userid ON phpbb_privmsgs (privmsgs_to_userid);

CREATE TABLE phpbb_privmsgs_text (
   privmsgs_text_id mediumint(8) DEFAULT '0' NOT NULL,
   privmsgs_bbcode_uid char(10) COLLATE NOCASE DEFAULT '0' NOT NULL,
   privmsgs_text text COLLATE NOCASE,
   PRIMARY KEY (privmsgs_text_id)
);

CREATE TABLE phpbb_ranks (
   rank_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   rank_title varchar(50) COLLATE NOCASE NOT NULL DEFAULT '',
   rank_min mediumint(8) DEFAULT '0' NOT NULL,
   rank_special tinyint(1) DEFAULT '0',
   rank_image varchar(255) COLLATE NOCASE
);

CREATE TABLE phpbb_search_results (
   search_id int(11) NOT NULL default '0',
   session_id char(32) COLLATE NOCASE NOT NULL default '',
   search_time int(11) DEFAULT '0' NOT NULL,
   search_array mediumtext COLLATE NOCASE NOT NULL DEFAULT '',
   PRIMARY KEY (search_id)
);
CREATE INDEX phpbb_search_results_session_id ON phpbb_search_results (session_id);

CREATE TABLE phpbb_search_wordlist (
   word_text varchar(50) COLLATE NOCASE NOT NULL default '',
   word_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   word_common tinyint(1) NOT NULL default '0',
   UNIQUE (word_text)
);
CREATE INDEX phpbb_search_wordlist_word_id ON phpbb_search_wordlist (word_id);

CREATE TABLE phpbb_search_wordmatch (
   post_id mediumint(8) NOT NULL default '0',
   word_id mediumint(8) NOT NULL default '0',
   title_match tinyint(1) NOT NULL default '0'
);
CREATE INDEX phpbb_search_wordmatch_post_id ON phpbb_search_wordmatch (post_id);
CREATE INDEX phpbb_search_wordmatch_word_id ON phpbb_search_wordmatch (word_id);

CREATE TABLE phpbb_sessions (
   session_id char(32) COLLATE NOCASE DEFAULT '' NOT NULL,
   session_user_id mediumint(8) DEFAULT '0' NOT NULL,
   session_start int(11) DEFAULT '0' NOT NULL,
   session_time int(11) DEFAULT '0' NOT NULL,
   session_ip varchar(32) COLLATE NOCASE DEFAULT '0' NOT NULL,
   session_page int(11) DEFAULT '0' NOT NULL,
   session_logged_in tinyint(1) DEFAULT '0' NOT NULL,
   session_admin tinyint(2) DEFAULT '0' NOT NULL,
   PRIMARY KEY (session_id)
);
CREATE INDEX phpbb_sessions_session_user_id ON phpbb_sessions (session_user_id);
CREATE INDEX phpbb_sessions_session_id_ip_user_id ON phpbb_sessions (session_id, session_ip, session_user_id);

CREATE TABLE phpbb_sessions_keys (
   key_id varchar(32) COLLATE NOCASE DEFAULT '0' NOT NULL,
   user_id mediumint(8) DEFAULT '0' NOT NULL,
   last_ip varchar(32) COLLATE NOCASE DEFAULT '0' NOT NULL,
   last_login int(11) DEFAULT '0' NOT NULL,
   PRIMARY KEY (key_id, user_id)
);
CREATE INDEX phpbb_sessions_keys_last_login ON phpbb_sessions_keys (last_login);

CREATE TABLE phpbb_smilies (
   smilies_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   code varchar(50) COLLATE NOCASE,
   smile_url varchar(100) COLLATE NOCASE,
   emoticon varchar(75) COLLATE NOCASE
);

CREATE TABLE phpbb_themes (
   themes_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   template_name varchar(30) COLLATE NOCASE NOT NULL default '',
   style_name varchar(30) COLLATE NOCASE NOT NULL default '',
   head_stylesheet varchar(100) COLLATE NOCASE default NULL,
   body_background varchar(100) COLLATE NOCASE default NULL,
   body_bgcolor varchar(6) COLLATE NOCASE default NULL,
   body_text varchar(6) COLLATE NOCASE default NULL,
   body_link varchar(6) COLLATE NOCASE default NULL,
   body_vlink varchar(6) COLLATE NOCASE default NULL,
   body_alink varchar(6) COLLATE NOCASE default NULL,
   body_hlink varchar(6) COLLATE NOCASE default NULL,
   tr_color1 varchar(6) COLLATE NOCASE default NULL,
   tr_color2 varchar(6) COLLATE NOCASE default NULL,
   tr_color3 varchar(6) COLLATE NOCASE default NULL,
   tr_class1 varchar(25) COLLATE NOCASE default NULL,
   tr_class2 varchar(25) COLLATE NOCASE default NULL,
   tr_class3 varchar(25) COLLATE NOCASE default NULL,
   th_color1 varchar(6) COLLATE NOCASE default NULL,
   th_color2 varchar(6) COLLATE NOCASE default NULL,
   th_color3 varchar(6) COLLATE NOCASE default NULL,
   th_class1 varchar(25) COLLATE NOCASE default NULL,
   th_class2 varchar(25) COLLATE NOCASE default NULL,
   th_class3 varchar(25) COLLATE NOCASE default NULL,
   td_color1 varchar(6) COLLATE NOCASE default NULL,
   td_color2 varchar(6) COLLATE NOCASE default NULL,
   td_color3 varchar(6) COLLATE NOCASE default NULL,
   td_class1 varchar(25) COLLATE NOCASE default NULL,
   td_class2 varchar(25) COLLATE NOCASE default NULL,
   td_class3 varchar(25) COLLATE NOCASE default NULL,
   fontface1 varchar(50) COLLATE NOCASE default NULL,
   fontface2 varchar(50) COLLATE NOCASE default NULL,
   fontface3 varchar(50) COLLATE NOCASE default NULL,
   fontsize1 tinyint(4) default NULL,
   fontsize2 tinyint(4) default NULL,
   fontsize3 tinyint(4) default NULL,
   fontcolor1 varchar(6) COLLATE NOCASE default NULL,
   fontcolor2 varchar(6) COLLATE NOCASE default NULL,
   fontcolor3 varchar(6) COLLATE NOCASE default NULL,
   span_class1 varchar(25) COLLATE NOCASE default NULL,
   span_class2 varchar(25) COLLATE NOCASE default NULL,
   span_class3 varchar(25) COLLATE NOCASE default NULL,
   img_size_poll smallint(5),
   img_size_privmsg smallint(5)
);

CREATE TABLE phpbb_themes_name (
   themes_id smallint(5) DEFAULT '0' NOT NULL,
   tr_color1_name char(50) COLLATE NOCASE,
   tr_color2_name char(50) COLLATE NOCASE,
   tr_color3_name char(50) COLLATE NOCASE,
   tr_class1_name char(50) COLLATE NOCASE,
   tr_class2_name char(50) COLLATE NOCASE,
   tr_class3_name char(50) COLLATE NOCASE,
   th_color1_name char(50) COLLATE NOCASE,
   th_color2_name char(50) COLLATE NOCASE,
   th_color3_name char(50) COLLATE NOCASE,
   th_class1_name char(50) COLLATE NOCASE,
   th_class2_name char(50) COLLATE NOCASE,
   th_class3_name char(50) COLLATE NOCASE,
   td_color1_name char(50) COLLATE NOCASE,
   td_color2_name char(50) COLLATE NOCASE,
   td_color3_name char(50) COLLATE NOCASE,
   td_class1_name char(50) COLLATE NOCASE,
   td_class2_name char(50) COLLATE NOCASE,
   td_class3_name char(50) COLLATE NOCASE,
   fontface1_name char(50) COLLATE NOCASE,
   fontface2_name char(50) COLLATE NOCASE,
   fontface3_name char(50) COLLATE NOCASE,
   fontsize1_name char(50) COLLATE NOCASE,
   fontsize2_name char(50) COLLATE NOCASE,
   fontsize3_name char(50) COLLATE NOCASE,
   fontcolor1_name char(50) COLLATE NOCASE,
   fontcolor2_name char(50) COLLATE NOCASE,
   fontcolor3_name char(50) COLLATE NOCASE,
   span_class1_name char(50) COLLATE NOCASE,
   span_class2_name char(50) COLLATE NOCASE,
   span_class3_name char(50) COLLATE NOCASE,
   PRIMARY KEY (themes_id)
);

CREATE TABLE phpbb_topics (
   topic_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   forum_id smallint(8) DEFAULT '0' NOT NULL,
   topic_title char(60) COLLATE NOCASE NOT NULL DEFAULT '',
   topic_poster mediumint(8) DEFAULT '0' NOT NULL,
   topic_time int(11) DEFAULT '0' NOT NULL,
   topic_views mediumint(8) DEFAULT '0' NOT NULL,
   topic_replies mediumint(8) DEFAULT '0' NOT NULL,
   topic_status tinyint(3) DEFAULT '0' NOT NULL,
   topic_vote tinyint(1) DEFAULT '0' NOT NULL,
   topic_type tinyint(3) DEFAULT '0' NOT NULL,
   topic_first_post_id mediumint(8) DEFAULT '0' NOT NULL,
   topic_last_post_id mediumint(8) DEFAULT '0' NOT NULL,
   topic_moved_id mediumint(8) DEFAULT '0' NOT NULL
);
CREATE INDEX phpbb_topics_forum_id ON phpbb_topics (forum_id);
CREATE INDEX phpbb_topics_topic_moved_id ON phpbb_topics (topic_moved_id);
CREATE INDEX phpbb_topics_topic_status ON phpbb_topics (topic_status);
CREATE INDEX phpbb_topics_topic_type ON phpbb_topics (topic_type);

CREATE TABLE phpbb_topics_watch (
   topic_id mediumint(8) NOT NULL DEFAULT '0',
   user_id mediumint(8) NOT NULL DEFAULT '0',
   notify_status tinyint(1) NOT NULL default '0'
);
CREATE INDEX phpbb_topics_watch_topic_id ON phpbb_topics_watch (topic_id);
CREATE INDEX phpbb_topics_watch_user_id ON phpbb_topics_watch (user_id);
CREATE INDEX phpbb_topics_watch_notify_status ON phpbb_topics_watch (notify_status);

CREATE TABLE phpbb_users (
   user_id mediumint(8) NOT NULL DEFAULT '0',
   user_active tinyint(1) DEFAULT '1',
   username varchar(25) COLLATE NOCASE NOT NULL DEFAULT '',
   user_password varchar(255) NOT NULL DEFAULT '',
   user_session_time int(11) DEFAULT '0' NOT NULL,
   user_session_page smallint(5) DEFAULT '0' NOT NULL,
   user_lastvisit int(11) DEFAULT '0' NOT NULL,
   user_regdate int(11) DEFAULT '0' NOT NULL,
   user_level tinyint(4) DEFAULT '0',
   user_posts mediumint(8) DEFAULT '0' NOT NULL,
   user_timezone decimal(5,2) DEFAULT '0' NOT NULL,
   user_style tinyint(4),
   user_lang varchar(255) COLLATE NOCASE,
   user_dateformat varchar(14) COLLATE NOCASE DEFAULT 'd M Y H:i' NOT NULL,
   user_new_privmsg smallint(5) DEFAULT '0' NOT NULL,
   user_unread_privmsg smallint(5) DEFAULT '0' NOT NULL,
   user_last_privmsg int(11) DEFAULT '0' NOT NULL,
   user_login_tries smallint(5) DEFAULT '0' NOT NULL,
   user_last_login_try int(11) DEFAULT '0' NOT NULL,
   user_passwd_tries smallint(5) DEFAULT '0' NOT NULL,
   user_last_passwd_try int(11) DEFAULT '0' NOT NULL,
   user_emailtime int(11),
   user_viewemail tinyint(1),
   user_attachsig tinyint(1),
   user_allowhtml tinyint(1) DEFAULT '1',
   user_allowbbcode tinyint(1) DEFAULT '1',
   user_allowsmile tinyint(1) DEFAULT '1',
   user_allowavatar tinyint(1) DEFAULT '1' NOT NULL,
   user_allow_pm tinyint(1) DEFAULT '1' NOT NULL,
   user_allow_viewonline tinyint(1) DEFAULT '1' NOT NULL,
   user_notify tinyint(1) DEFAULT '1' NOT NULL,
   user_notify_pm tinyint(1) DEFAULT '0' NOT NULL,
   user_popup_pm tinyint(1) DEFAULT '0' NOT NULL,
   user_rank int(11) DEFAULT '0',
   user_avatar varchar(100) COLLATE NOCASE,
   user_avatar_type tinyint(4) DEFAULT '0' NOT NULL,
   user_email varchar(255) COLLATE NOCASE,
   user_icq varchar(15) COLLATE NOCASE,
   user_website varchar(100) COLLATE NOCASE,
   user_from varchar(100) COLLATE NOCASE,
   user_sig text COLLATE NOCASE,
   user_sig_bbcode_uid char(10) COLLATE NOCASE,
   user_aim varchar(255) COLLATE NOCASE,
   user_yim varchar(255) COLLATE NOCASE,
   user_msnm varchar(255) COLLATE NOCASE,
   user_occ varchar(100) COLLATE NOCASE,
   user_interests varchar(255) COLLATE NOCASE,
   user_actkey varchar(32) COLLATE NOCASE,
   user_newpasswd varchar(255),
   PRIMARY KEY (user_id)
);
CREATE INDEX phpbb_users_user_session_time ON phpbb_users (user_session_time);

CREATE TABLE phpbb_vote_desc (
   vote_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   topic_id mediumint(8) NOT NULL DEFAULT '0',
   vote_text text COLLATE NOCASE NOT NULL DEFAULT '',
   vote_start int(11) NOT NULL DEFAULT '0',
   vote_length int(11) NOT NULL DEFAULT '0'
);
CREATE INDEX phpbb_vote_desc_topic_id ON phpbb_vote_desc (topic_id);

CREATE TABLE phpbb_vote_results (
   vote_id mediumint(8) NOT NULL DEFAULT '0',
   vote_option_id tinyint(4) NOT NULL DEFAULT '0',
   vote_option_text varchar(255) COLLATE NOCASE NOT NULL DEFAULT '',
   vote_result int(11) NOT NULL DEFAULT '0'
);
CREATE INDEX phpbb_vote_results_vote_option_id ON phpbb_vote_results (vote_option_id);
CREATE INDEX phpbb_vote_results_vote_id ON phpbb_vote_results (vote_id);

CREATE TABLE phpbb_vote_voters (
   vote_id mediumint(8) NOT NULL DEFAULT '0',
   vote_user_id mediumint(8) NOT NULL DEFAULT '0',
   vote_user_ip varchar(32) COLLATE NOCASE NOT NULL DEFAULT ''
);
CREATE INDEX phpbb_vote_voters_vote_id ON phpbb_vote_voters (vote_id);
CREATE INDEX phpbb_vote_voters_vote_user_id ON phpbb_vote_voters (vote_user_id);
CREATE INDEX phpbb_vote_voters_vote_user_ip ON phpbb_vote_voters (vote_user_ip);

CREATE TABLE phpbb_words (
   word_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
   word char(100) COLLATE NOCASE NOT NULL DEFAULT '',
   replacement char(100) COLLATE NOCASE NOT NULL DEFAULT ''
);

