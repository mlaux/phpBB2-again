<?php
/***************************************************************************
 *                           usercp_sendpasswd.php
 *                            -------------------
 *   begin                : Saturday, Feb 13, 2001
 *   copyright            : (C) 2001 The phpBB Group
 *   email                : support@phpbb.com
 *
 *   $Id: usercp_sendpasswd.php 5204 2005-09-14 18:14:30Z acydburn $
 *
 *
 ***************************************************************************/

/***************************************************************************
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 2 of the License, or
 *   (at your option) any later version.
 *
 *
 ***************************************************************************/

if ( !defined('IN_PHPBB') )
{
	die('Hacking attempt');
	exit;
}

if ( isset($_POST['submit']) )
{
	$username = ( !empty($_POST['username']) ) ? phpbb_clean_username($_POST['username']) : '';
	$email = ( !empty($_POST['email']) ) ? trim(strip_tags(htmlspecialchars($_POST['email'], ENT_COMPAT, 'ISO-8859-1'))) : '';

	$sql = "SELECT user_id, username, user_email, user_active, user_lang, user_actkey, user_passwd_tries, user_last_passwd_try 
		FROM " . USERS_TABLE . " 
		WHERE user_email = '" . str_replace("\'", "''", $email) . "' 
			AND username = '" . str_replace("\'", "''", $username) . "'";
	if ( $result = $db->sql_query($sql) )
	{
		if ( $row = $db->sql_fetchrow($result) )
		{
			if ( !$row['user_active'] )
			{
				message_die(GENERAL_MESSAGE, $lang['No_send_account_inactive']);
			}

			$reset_window = $board_config['login_reset_time'] * 60;
			$passwd_tries = $row['user_passwd_tries'];

			if ( $row['user_last_passwd_try'] && $reset_window && $row['user_last_passwd_try'] < (time() - $reset_window) )
			{
				$passwd_tries = 0;
			}
			else if ( $board_config['max_login_attempts'] && $passwd_tries >= $board_config['max_login_attempts'] )
			{
				message_die(GENERAL_MESSAGE, sprintf($lang['Passwd_attempts_exceeded'], $board_config['max_login_attempts'], $board_config['login_reset_time']));
			}
			else if ( trim($row['user_actkey']) != '' && $row['user_last_passwd_try'] )
			{
				message_die(GENERAL_MESSAGE, $lang['Passwd_reset_pending']);
			}

			$username = $row['username'];
			$user_id = $row['user_id'];

			$user_actkey = gen_rand_string(true);
			// Floor was 6 hex chars (24 bits), which is brute forceable.
			$key_len = 54 - strlen($server_url);
			$key_len = ($key_len > 16) ? $key_len : 16;
			$user_actkey = substr($user_actkey, 0, $key_len);
			$user_password = gen_rand_string(false);
			
			$sql = "UPDATE " . USERS_TABLE . " 
				SET user_newpasswd = '" . phpbb_hash_password($user_password) . "', user_actkey = '$user_actkey', user_passwd_tries = " . ($passwd_tries + 1) . ", user_last_passwd_try = " . time() . "  
				WHERE user_id = " . $row['user_id'];
			if ( !$db->sql_query($sql) )
			{
				message_die(GENERAL_ERROR, 'Could not update new password information', '', __LINE__, __FILE__, $sql);
			}

			include($phpbb_root_path . 'includes/emailer.'.$phpEx);
			$emailer = new emailer($board_config['smtp_delivery']);

			$emailer->from($board_config['board_email']);
			$emailer->replyto($board_config['board_email']);

			$emailer->use_template('user_activate_passwd', $row['user_lang']);
			$emailer->email_address($row['user_email']);
			$emailer->set_subject($lang['New_password_activation']);

			$emailer->assign_vars(array(
				'SITENAME' => $board_config['sitename'], 
				'USERNAME' => $username,
				'PASSWORD' => $user_password,
				'EMAIL_SIG' => (!empty($board_config['board_email_sig'])) ? str_replace('<br />', "\n", "-- \n" . $board_config['board_email_sig']) : '', 

				'U_ACTIVATE' => $server_url . '?mode=activate&' . POST_USERS_URL . '=' . $user_id . '&act_key=' . $user_actkey)
			);
			$emailer->send();
			$emailer->reset();

			$template->assign_vars(array(
				'META' => '<meta http-equiv="refresh" content="15;url=' . append_sid("index.$phpEx") . '">')
			);

			$message = $lang['Password_updated'] . '<br /><br />' . sprintf($lang['Click_return_index'],  '<a href="' . append_sid("index.$phpEx") . '">', '</a>');

			message_die(GENERAL_MESSAGE, $message);
		}
		else
		{
			message_die(GENERAL_MESSAGE, $lang['No_email_match']);
		}
	}
	else
	{
		message_die(GENERAL_ERROR, 'Could not obtain user information for sendpassword', '', __LINE__, __FILE__, $sql);
	}
}
else
{
	$username = '';
	$email = '';
}

//
// Output basic page
//
include($phpbb_root_path . 'includes/page_header.'.$phpEx);

$template->set_filenames(array(
	'body' => 'profile_send_pass.tpl')
);
make_jumpbox('viewforum.'.$phpEx);

$template->assign_vars(array(
	'USERNAME' => $username,
	'EMAIL' => $email,

	'L_SEND_PASSWORD' => $lang['Send_password'], 
	'L_ITEMS_REQUIRED' => $lang['Items_required'],
	'L_EMAIL_ADDRESS' => $lang['Email_address'],
	'L_SUBMIT' => $lang['Submit'],
	'L_RESET' => $lang['Reset'],
	
	'S_HIDDEN_FIELDS' => '', 
	'S_PROFILE_ACTION' => append_sid("profile.$phpEx?mode=sendpassword"))
);

$template->pparse('body');

include($phpbb_root_path . 'includes/page_tail.'.$phpEx);

?>
